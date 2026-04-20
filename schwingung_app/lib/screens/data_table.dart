import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:schwingung_app/models/enum_sets.dart';
import 'package:schwingung_app/utils/csv_file_content.dart';
import 'package:schwingung_app/utils/neural_net.dart';
import 'package:schwingung_app/utils/platform.dart';
import 'package:schwingung_app/widgets/progress.dart';
import 'package:schwingung_app/widgets/refresh_widget.dart';
import 'package:share_plus/share_plus.dart';

class DataTableScreenData {
  final CSVFileContent csvFileContent;

  DataTableScreenData({required this.csvFileContent});
}

class DataTableScreen extends StatefulWidget {
  static const routeName = '/datei-tabelle';

  const DataTableScreen({super.key});

  @override
  State<DataTableScreen> createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  final NeuralNet neuralNet = NeuralNet();
  NeuralNetDataSource dataSource = NeuralNetDataSource([]);
  DataTableScreenData? screendata;
  String csvContent = '';
  String _progressText = '';
  bool _disposed = false;
  final AppRefreshWidgetController _controller = AppRefreshWidgetController();
  AppState _appState = AppState.none;

  @override
  Widget build(BuildContext context) {
    screendata =
        ModalRoute.of(context)?.settings.arguments as DataTableScreenData?;

    if (screendata == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schwingung App')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Text(
                  'Keine Datei ausgewählt. Zurückgehen und neue Datei auswählen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(onPressed: () {}, child: const Text('Zurück')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schwingungsapp'),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: _share)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<bool>(
            future: _runPrediction(screendata!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  children: [
                    const SizedBox(height: 50),
                    const AppProgressIndicator(),
                    const SizedBox(height: 30),
                    const Text(
                      'Der Messwert wird geladen...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    AppRefreshWidget(
                      controller: _controller,
                      builder: (ctx) {
                        return Text(
                          _progressText,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Fehler beim Lesen der Datei: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || dataSource.data.isEmpty) {
                return const Center(
                  child: Text('Keine gültigen Daten in der Datei gefunden.'),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      '**Hubgeschwindigkeit v (m/min), Charakteristische Verformung d (m), Spannweite S (m), Anschlagmittel Riemen r (m), Messwert p. Klicken Sie auf eine Spalte, um die Tabelle danach zu sortieren.',
                    ),
                    const SizedBox(height: 10),
                    // use Table for better formatting, and efficiency
                    PaginatedDataTable(
                      header: const Text('Vorhersageergebnisse'),
                      rowsPerPage: 10,
                      sortAscending: dataSource.sortAscending,
                      sortColumnIndex: dataSource.sortColumnIndex,
                      columns: [
                        DataColumn(
                          label: Text('i'),
                          onSort: (i, asc) => _sort('i', i, asc),
                        ),
                        DataColumn(
                          label: Text('v'),
                          onSort: (i, asc) => _sort('v', i, asc),
                        ),
                        DataColumn(
                          label: Text('d'),
                          onSort: (i, asc) => _sort('d', i, asc),
                        ),
                        DataColumn(
                          label: Text('S'),
                          onSort: (i, asc) => _sort('S', i, asc),
                        ),
                        DataColumn(
                          label: Text('r'),
                          onSort: (i, asc) => _sort('r', i, asc),
                        ),
                        DataColumn(
                          label: Text('p'),
                          onSort: (i, asc) => _sort('p', i, asc),
                        ),
                      ],
                      source: dataSource,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _sort(String columnName, int columnIndex, bool ascending) {
    setState(() {
      dataSource.sortByColumn(columnName, columnIndex, ascending);
    });
  }

  Future<bool> _runPrediction(DataTableScreenData screendata) async {
    if (_appState == AppState.loaded || _appState == AppState.loading) {
      return true;
    }
    if (!await screendata.csvFileContent.isValid()) {
      _appState = AppState.error;
      throw Exception(
        'Ungültiges Dateiformat. Bitte eine CSV-Datei hochladen.',
      );
    }

    _appState = AppState.loading;
    _progressText = '';
    _controller.refresh();
    // Run heavy computation in a background isolate
    final dataList = await screendata.csvFileContent.parseCSV();
    final int total = dataList.length;
    for (int i = 0; i < total; i++) {
      await neuralNet.predictSingle(dataList[i]);
      if (_disposed) {
        _appState = AppState.error;
        return false;
      }
      if (i % 50 == 0) {
        double progress = (i / total) * 100;
        _progressText = '${progress.toStringAsFixed(2)} %';
        _controller.refresh();
      }
    }

    for (NeuralNetData row in dataList) {
      // smart way to avoid blocking the UI thread on csv demand,
      // we prebuild the csv content while processing the data
      csvContent +=
          '${row.hubgeschwindigkeit},${row.charakteristischeVerformung},${row.spannweite},${row.anschlagmittel},${row.messWert ?? '-'}\n';
    }

    // update data
    dataSource = NeuralNetDataSource(dataList);
    _appState = AppState.loaded;
    return true;
  }

  void _share() async {
    if (screendata == null || _appState != AppState.loaded) {
      return;
    }
    String fileName = screendata!.csvFileContent.fileName;

    // selector does not work on android,
    // so we use share_plus for that platform
    if (AppPlatform.isAndroid) {
      // Create a temporary file
      final tempDir = await path_provider.getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvContent);

      // Share the file
      await SharePlus.instance.share(
        ShareParams(text: fileName, files: [XFile(file.path)]),
      );
      return;
    }
    final file_selector.FileSaveLocation? result = await file_selector
        .getSaveLocation(suggestedName: fileName);
    if (result == null) {
      // Operation was canceled by the user.
      return;
    }

    final Uint8List fileData = Uint8List.fromList(csvContent.codeUnits);
    const String mimeType = 'text/plain';
    final XFile textFile = XFile.fromData(
      fileData,
      mimeType: mimeType,
      name: fileName,
    );
    await textFile.saveTo(result.path);
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }
}
