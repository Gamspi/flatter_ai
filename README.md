# flatter_app

Flutter-приложение с экраном логина (включая биометрию) и главным экраном.

## Запуск на Android

### Требования

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — версия 3.x и выше
- Android Studio или Android SDK (с настроенными `ANDROID_HOME` / `ANDROID_SDK_ROOT`)
- Подключённое Android-устройство (USB-отладка включена) или запущенный эмулятор

### Установка зависимостей

```bash
flutter pub get
```

### Запуск в режиме отладки

```bash
flutter run
```

Если подключено несколько устройств, укажите нужное:

```bash
flutter devices                          # список доступных устройств
flutter run -d <device_id>              # запуск на конкретном устройстве
```

### Сборка APK

```bash
flutter build apk                        # release APK (app-release.apk)
flutter build apk --debug               # debug APK
flutter build apk --split-per-abi       # отдельные APK под каждую архитектуру (arm64, x86_64 и др.)
```

Готовый файл: `build/app/outputs/flutter-apk/app-release.apk`

### Сборка App Bundle (для Google Play)

```bash
flutter build appbundle
```

Готовый файл: `build/app/outputs/bundle/release/app-release.aab`

### Установка APK на устройство вручную

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Запуск на iPhone / iOS

> **Требуется macOS.** Сборка под iOS возможна только на компьютере с macOS и установленным Xcode.

### Требования

- macOS с [Xcode](https://developer.apple.com/xcode/) 14 и выше
- [Flutter SDK](https://docs.flutter.dev/get-started/install) — версия 3.x и выше
- CocoaPods: `sudo gem install cocoapods`
- Apple Developer аккаунт (для запуска на физическом устройстве)
- Подключённый iPhone (доверие к компьютеру подтверждено) или симулятор iOS

### Установка зависимостей

```bash
flutter pub get
cd ios && pod install && cd ..
```

### Запуск в режиме отладки

```bash
flutter run                              # запуск на подключённом iPhone или симуляторе
flutter run -d "iPhone 15"              # конкретный симулятор (имя из Xcode)
```

Список доступных устройств и симуляторов:

```bash
flutter devices
```

### Открыть проект в Xcode

```bash
open ios/Runner.xcworkspace
```

В Xcode нужно:
1. Выбрать команду разработчика: **Runner → Signing & Capabilities → Team**
2. Указать уникальный **Bundle Identifier** (например, `com.yourname.flatterapp`)
3. Подключить устройство и нажать **Run (▶)**

### Сборка release-архива (для App Store / TestFlight)

```bash
flutter build ios                        # release-сборка
flutter build ios --release
```

Затем в Xcode: **Product → Archive → Distribute App**.

### Запуск на симуляторе без Apple ID

```bash
open -a Simulator
flutter run -d "iPhone 15 Pro"
```

## Полезные команды

```bash
flutter analyze          # статический анализ
flutter test             # запуск тестов
dart format lib/         # форматирование кода
```
