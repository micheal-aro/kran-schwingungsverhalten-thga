import 'package:flutter/material.dart';
import 'package:schwingung_app/models/enum_sets.dart';
import 'package:schwingung_app/utils/neural_net.dart';
import 'package:schwingung_app/widgets/button.dart';
import 'package:schwingung_app/widgets/progress.dart';
import 'package:schwingung_app/widgets/text_feld.dart';

class ManualInputScreen extends StatefulWidget {
  static const routeName = '/manuelle-eingabe';
  const ManualInputScreen({super.key});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final TextEditingController _hubgeschwindigkeitController =
      TextEditingController();
  final TextEditingController _charakteristischeVerformungController =
      TextEditingController();
  final TextEditingController _spannweiteController = TextEditingController();
  final TextEditingController _anschlagmittelController =
      TextEditingController();
  final TextEditingController _messwertController = TextEditingController();
  final NeuralNet neuralNet = NeuralNet();
  AppState _appState = AppState.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schwingungsapp')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Daten manuell eingeben',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kranparameter eingeben, um eine Vorhersage zu erhalten.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFeld(
                label: 'Hubgeschwindigkeit v in m/min',
                hintText: 'Hubgeschwindigkeit eingeben',
                controller: _hubgeschwindigkeitController,
                textFeldType: TextFeldType.numeric,
              ),
              const SizedBox(height: 10),
              TextFeld(
                label: 'Charakteristische Verformung d in m',
                hintText: 'charakteristische Verformung eingeben',
                controller: _charakteristischeVerformungController,
                textFeldType: TextFeldType.numeric,
              ),
              const SizedBox(height: 10),
              TextFeld(
                label: 'Spannweite S in m',
                hintText: 'Spannweite eingeben',
                controller: _spannweiteController,
                textFeldType: TextFeldType.numeric,
              ),
              const SizedBox(height: 10),
              TextFeld(
                label: 'Anschlagmittel Riemen r',
                hintText: 'Anschlagmittel Riemen eingeben',
                controller: _anschlagmittelController,
                textFeldType: TextFeldType.numeric,
              ),
              const SizedBox(height: 10),
              TextFeld(
                label: 'Messwert p',
                hintText: 'Wird automatisch ausgefüllt',
                controller: _messwertController,
                textFeldType: TextFeldType.numeric,
                // editable: false,
              ),
              const SizedBox(height: 5),
              Text('! Der Messwert wird automatisch ausgefüllt'),
              const SizedBox(height: 10),
              if (_appState == AppState.loading) AppProgressIndicator(),
              if (_appState != AppState.loading)
                AppTextButton(
                  onPressed: _submit,
                  text: 'Generieren',
                  icon: Icons.done,
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final nData = NeuralNetData.fromString(
      hubgeschwindigkeit: _hubgeschwindigkeitController.text,
      charakteristischeVerformung: _charakteristischeVerformungController.text,
      spannweite: _spannweiteController.text,
      anschlagmittel: _anschlagmittelController.text,
    );
    setState(() {
        _messwertController.text ='';
      _appState = AppState.loading;
    });
    await neuralNet.predict([nData]);
    _appState = AppState.loaded;
    _messwertController.text = nData.messWert != null
        ? '${nData.messWert}'
        : 'Keine Vorhersage möglich';
    if (mounted) {
      setState(() {});
    }
  }
}
