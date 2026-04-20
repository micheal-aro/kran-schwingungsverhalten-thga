import 'package:schwingung_app/utils/neural_net.dart';

class CSVFileContent {
  final String content;
  final bool skipFirstRow;
  final String fileName;
  List<NeuralNetData> data = [];

  CSVFileContent({
    required this.content,
    this.skipFirstRow = false,
    this.fileName = 'Unbenannt.csv',
  });

  Future<bool> isValid() async {
    // check if valid csv file content
    return content.isNotEmpty &&
        content.contains(',') &&
        content.contains('\n');
  }

  Future<List<NeuralNetData>> parseCSV() async {
    // simplified cache
    if (data.isNotEmpty) {
      return data;
    }
    try {
      int entryIndex = 0;
      List<String> lines = content.split('\n');
      for (var i = skipFirstRow ? 1 : 0; i < lines.length; i++) {
        List<String> parts = lines[i].split(',');
        if (parts.length >= 4) {
          data.add(
            NeuralNetData.fromString(
              hubgeschwindigkeit: parts[0].trim(),
              charakteristischeVerformung: parts[1].trim(),
              spannweite: parts[2].trim(),
              anschlagmittel: parts[3].trim(),
              entryIndex: entryIndex,
            ),
          );
          entryIndex++;
        }
      }
    } catch (e) {
      // print('Fehler beim Lesen der Datei: $e');
    }
    return data;
  }
}
