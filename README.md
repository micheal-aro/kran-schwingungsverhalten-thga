# kran-schwingungsverhalten-thga
Vorhersage des Schwingungsverhaltens eines Krans mithilfe neuronaler Netze.

---
# Aufbau des Repos
Dieses Repo besteht aus 3 Ordner: schwingung_app, test-screen und neuronales-netz. Einige Python Codes wurden als ipynb-Dateien bereitgestellt, um eine schrittweise Ausführung des Codes zu ermöglichen.

## schwingung_app-Ordner
Im schwingung_app Ordner befindet sich den Code der mobilen App. 
Um die App auszuführen, muss ein Setup durchgeführt werden. 
1. Zuerst muss flutter installiert werden. Informationen dazu sind in der [Online-Dokumentation](https://docs.flutter.dev/).
2. Danach muss `flutter run` ausgeführt werden. Der Startpunkt ist die Datei `schwingung_app/lib/main.dart`.

## neuronales-netz-Ordner
Hier befindet sich der gesamte python code für das Training verschiedener Netze und der Datensatz.

### neuronales-netz/statistische-analyse.ipynb
In dieser Datei wird der Datensatz geladen und statistisch analysiert. Diese Analyse hilft dabei, wichtige Merkmale zu identifizieren, die für das Training eines neuronalen Netzes relevant sein könnten.

### neuronales-netz/netz.ipynb
In dieser Datei werden verschiedene neuronale Netze trainiert und miteinander verglichen.

## test-screen Ordner
Dieser Ordner enthält eine einzelne Datei, die den Code einer typsichen Widget-Klasse in Flutter enthält. Die Datei dient lediglich dazu, die Struktur einer solchen Klasse darzustellen, und kann nicht ausgeführt werden.


