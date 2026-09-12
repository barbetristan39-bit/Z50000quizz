# Z50000 Révision — Android

Projet Flutter prêt à être compilé en APK Android.

## Compilation

Prérequis : Flutter SDK + Android SDK + Android Studio.

```bash
flutter doctor
flutter pub get
flutter build apk --release
```

APK : `build/app/outputs/flutter-apk/app-release.apk`

Pour installer directement sur un téléphone USB avec le débogage USB activé :

```bash
flutter install --release
```

## Identité Android

Package : `com.z50000.revision`
Min SDK : 21
Target/compile SDK : configuration Flutter/Android installée localement.

## Contenu pédagogique

L'application utilise comme source le Livret d'études Z50000 Formation initiale, version 02 du 17/09/2020. Les questions et libellés doivent rester conformes au livret ; les pages de référence sont affichées dans les corrections.

## Important

Cette archive contient le code source. L'environnement de génération actuel ne dispose pas du SDK Flutter/Android, donc aucun APK binaire n'a été généré dans cette session. Une fois Flutter installé, les commandes ci-dessus produisent l'APK installable sur Android.
