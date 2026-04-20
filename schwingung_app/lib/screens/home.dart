import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schwingung_app/screens/data_table.dart';
import 'package:schwingung_app/screens/manual_input.dart';
import 'package:schwingung_app/utils/csv_file_content.dart';
import 'package:schwingung_app/widgets/button.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _fileError;
  bool _skipFirstRow = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schwingung App')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Schwingungsverhalten Vorhersagen!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Verschiedene Schwingungsverhalten mithilfe eines neuronalen Netzes vorhersagen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              const Text(
'''
Wählen Sie unten eine Option aus.

Manuell eingeben: Kenndaten manuell eingeben.
Datei hochladen: Daten aus einer CSV-Datei einlesen lassen.
''',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 40),
              AppTextButton(
                icon: Icons.edit,
                onPressed: () {
                  Navigator.of(context).pushNamed(ManualInputScreen.routeName);
                },
                text: 'Manuell eingeben',
              ),
              const SizedBox(height: 10),
              Divider(),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _skipFirstRow,
                onChanged: (l) {
                  setState(() {
                    _skipFirstRow = l;
                  });
                },
                title: const Text(
                  'Erste Zeile überspringen (z.B. bei Spaltenüberschriften)',
                ),
              ),
              const SizedBox(height: 5),
              if (_fileError != null)
                Text(_fileError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 5),
              AppTextButton(
                onPressed: () async {
                  setState(() {
                    _fileError = null;
                  });
                  // https://www.tutorialpedia.org/blog/how-can-i-read-and-write-files-in-flutter-web/
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        type: .custom,
                        allowedExtensions: ['csv'],
                        allowMultiple: false,
                      );

                  if (result == null || result.files.isEmpty) {
                    setState(() {
                      _fileError = 'Keine Datei ausgewählt.';
                    });
                    return;
                  }
                  // Get the selected file
                  PlatformFile file = result.files.first;
                  String textContent = await file.xFile.readAsString();
                  CSVFileContent csvFileContent = CSVFileContent(
                    fileName: file.name,
                    content: textContent,
                    skipFirstRow: _skipFirstRow,
                  );

                  if (!(await csvFileContent.isValid())) {
                    setState(() {
                      _fileError = 'Keine gültige .csv Datei ausgewählt.';
                    });
                    return;
                  }

                  if (context.mounted) {
                    Navigator.of(context).pushNamed(
                      DataTableScreen.routeName,
                      arguments: DataTableScreenData(
                        csvFileContent: csvFileContent,
                      ),
                    );
                  }
                },
                icon: Icons.upload,
                text: 'Datei hochladen',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
