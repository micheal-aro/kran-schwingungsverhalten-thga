import 'package:flutter/material.dart';
import 'package:schwingung_app/utils/platform.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// hardcoded model config and normalization data based on training data stats
class NeuralNetModelConfig {
  static const String modelPath =
      'assets/models/SGD_lr_0.01_mse_mm_0.9_model.keras.tflite';
  static NeuralNetNormalisationData mean = NeuralNetNormalisationData(
    hubgeschwindigkeit: 0.05774112307692307,
    charakteristischeVerformung: 0.05,
    spannweite: 24.995032538461537,
    anschlagmittel: 0.5,
    messWert: 1.282704630769231,
  );
  static NeuralNetNormalisationData stdDev = NeuralNetNormalisationData(
    hubgeschwindigkeit: 7.483314773547883,
    charakteristischeVerformung: 0.023530637599003163,
    spannweite: 8.658889241798041,
    anschlagmittel: 0.5,
    messWert: 0.20696525231233823,
  );
}

class NeuralNet {
  // only one interpreter instance for the whole app, to save resources
  static Interpreter? interpreter;
  final bool isIsolate;
  IsolateInterpreter? isolateInterpreter;

  NeuralNet({this.isIsolate = false});

  Future<void> predictRandom(
    List<NeuralNetData> inputs, {
    void Function(int i, int total)? onProgress,
  }) async {
    if (inputs.isEmpty) {
      return;
    }
    final int total = inputs.length;
    for (int i = 0; i < total; i++) {
      final NeuralNetData sample = inputs[i];
      double rowTotal = 0.0;
      final row = sample.toPredictionMatrix();
      for (var col in row) {
        rowTotal += col * 0.5;
      }
      // Durchschnitt der Spaltenwerte als Vorhersage
      sample.setMessWert(rowTotal / 4);
      onProgress?.call(i, total);
    }
  }

  Future<void> predict(
    List<NeuralNetData> inputs, {
    void Function(int i, int total)? onProgress,
  }) async {
    if (AppPlatform.isWeb) {
      // tflite_flutter unterstützt Web nicht, daher hier eine Dummy-Vorhersage
      return predictRandom(inputs, onProgress: onProgress);
    }

    int total = inputs.length;
    for (int i = 0; i < total; i++) {
      await predictSingle(inputs[i]);
      onProgress?.call(i, total);
    }
  }

  Future<void> predictSingle(NeuralNetData sample) async {
    if (AppPlatform.isWeb) {
      // tflite_flutter unterstützt Web nicht, daher hier eine Dummy-Vorhersage
      return predictRandom([sample]);
    }
    interpreter ??= await Interpreter.fromAsset(NeuralNetModelConfig.modelPath);
    // isolate interpreter is only used for heavy computations, so we initialize it lazily
    isolateInterpreter ??= await IsolateInterpreter.create(
      address: interpreter!.address,
    );
    await isolateInterpreter!.run(
      sample.toPredictionMatrix(),
      sample.predictionOutputMatrix,
    );
    sample.setMessWert(sample.predictionOutputMatrix[0][0]);
  }
}

class NeuralNetNormalisationData {
  final double hubgeschwindigkeit;
  final double charakteristischeVerformung;
  final double spannweite;
  final double anschlagmittel;
  final double messWert;

  NeuralNetNormalisationData({
    required this.hubgeschwindigkeit,
    required this.charakteristischeVerformung,
    required this.spannweite,
    required this.anschlagmittel,
    this.messWert = 0.0,
  });
}

class NeuralNetData {
  final double hubgeschwindigkeit;
  final double charakteristischeVerformung;
  final double spannweite;
  final double anschlagmittel;
  // for table display and sorting
  final int entryIndex;
  double? messWert;
  NeuralNetData? _normalizedCache;

  // create output object
  final predictionOutputMatrix = [
    [0.0],
  ];
  NeuralNetData({
    required this.hubgeschwindigkeit,
    required this.charakteristischeVerformung,
    required this.spannweite,
    required this.anschlagmittel,
    this.messWert,
    this.entryIndex = -1,
  });

  factory NeuralNetData.fromString({
    required String hubgeschwindigkeit,
    required String charakteristischeVerformung,
    required String spannweite,
    required String anschlagmittel,
    // for table display and sorting
    int entryIndex = -1,
    String? messWert,
  }) {
    return NeuralNetData(
      hubgeschwindigkeit: double.tryParse(hubgeschwindigkeit) ?? 0.0,
      charakteristischeVerformung:
          double.tryParse(charakteristischeVerformung) ?? 0.0,
      spannweite: double.tryParse(spannweite) ?? 0.0,
      anschlagmittel: double.tryParse(anschlagmittel) ?? 0.0,
      messWert: messWert != null && messWert.isNotEmpty
          ? double.tryParse(messWert) ?? 0.0
          : null,
      entryIndex: entryIndex,
    );
  }

  void setMessWert(double messWert) {
    this.messWert = double.tryParse(messWert.toStringAsFixed(4)) ?? 0.0;
  }

  // returns a normalized version of the data for better model performance
  // ensures final is used for all fields
  NeuralNetData normalized() {
    NeuralNetNormalisationData mean = NeuralNetModelConfig.mean;
    NeuralNetNormalisationData stdDev = NeuralNetModelConfig.stdDev;
    // normalize values to 0-1 range for better model performance
    // these min/max values are based on the training data
    _normalizedCache ??= NeuralNetData(
      hubgeschwindigkeit:
          (hubgeschwindigkeit - mean.hubgeschwindigkeit) /
          stdDev.hubgeschwindigkeit,
      charakteristischeVerformung:
          (charakteristischeVerformung - mean.charakteristischeVerformung) /
          stdDev.charakteristischeVerformung,
      spannweite: (spannweite - mean.spannweite) / stdDev.spannweite,
      anschlagmittel:
          (anschlagmittel - mean.anschlagmittel) / stdDev.anschlagmittel,
      messWert: messWert,
      entryIndex: entryIndex,
    );
    return _normalizedCache!;
  }

  List<double> toPredictionMatrix() {
    final normed = normalized();
    return [
      normed.hubgeschwindigkeit,
      normed.charakteristischeVerformung,
      normed.spannweite,
      normed.anschlagmittel,
    ];
  }

  List<double> toMatrix() {
    return [
      hubgeschwindigkeit,
      charakteristischeVerformung,
      spannweite,
      anschlagmittel,
    ];
  }
}

// for tables
class NeuralNetDataSource extends DataTableSource {
  final List<NeuralNetData> data;
  int sortColumnIndex = 0;
  bool sortAscending = true;

  NeuralNetDataSource(this.data);

  @override
  DataRow getRow(int index) {
    final row = data[index];

    return DataRow(
      cells: [
        DataCell(Text('${row.entryIndex + 1}')),
        DataCell(Text('${row.hubgeschwindigkeit}')),
        DataCell(Text('${row.charakteristischeVerformung}')),
        DataCell(Text('${row.spannweite}')),
        DataCell(Text('${row.anschlagmittel}')),
        DataCell(Text(row.messWert != null ? '${row.messWert}' : '-')),
      ],
    );
  }

  void sortByColumn(String columnName, int columnIndex, bool ascending) {
    sortAscending = ascending;
    sortColumnIndex = columnIndex;

    data.sort((a, b) {
      int compare;
      switch (columnName) {
        case 'i':
          compare = a.entryIndex.compareTo(b.entryIndex);
          break;
        case 'v':
          compare = a.hubgeschwindigkeit.compareTo(b.hubgeschwindigkeit);
          break;
        case 'd':
          compare = a.charakteristischeVerformung.compareTo(
            b.charakteristischeVerformung,
          );
          break;
        case 'S':
          compare = a.spannweite.compareTo(b.spannweite);
          break;
        case 'r':
          compare = a.anschlagmittel.compareTo(b.anschlagmittel);
          break;
        case 'p':
          compare = (a.messWert ?? 0.0).compareTo(b.messWert ?? 0.0);
          break;
        default:
          compare = 0;
      }
      return sortAscending ? compare : -compare;
    });
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
