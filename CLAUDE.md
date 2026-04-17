# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # установить зависимости
flutter run              # запуск на подключённом устройстве/эмуляторе
flutter run -d chrome    # запуск в браузере
flutter test             # все тесты
flutter test test/path/to_test.dart  # один тестовый файл
flutter analyze          # статический анализ (lint)
dart format lib/         # форматирование кода
flutter build apk        # сборка Android
flutter build ios        # сборка iOS
flutter build web        # сборка Web
```

## Architecture

Код приложения находится в `lib/`. Рекомендуемая структура:

```
lib/
  main.dart          # точка входа, MaterialApp / WidgetsApp
  screens/           # полноэкранные виджеты (одна страница = один файл)
  widgets/           # переиспользуемые виджеты
  models/            # data-классы, сериализация (json_serializable)
  services/          # HTTP-клиенты, локальное хранилище, бизнес-логика
  providers/         # стейт-менеджмент (Riverpod / Provider / Bloc)
test/                # widget- и unit-тесты (зеркало структуры lib/)
pubspec.yaml         # зависимости, assets, шрифты
```

## Current Implementation

Реализованные экраны: `LoginScreen` (форма логина + биометрия) → `HomeScreen` (приветствие + выход).

- **Навигация:** `Navigator.pushReplacement()` без именованных маршрутов.
- **Стейт-менеджмент:** только локальный (`StatefulWidget`); глобальный не подключён.
- **Биометрия:** пакет `local_auth ^2.3.0`, вызов через `LocalAuthentication.authenticate()` в `initState` + кнопка на экране логина.
- **Тема:** Material 3, seed color `Colors.deepPurple`.
- **Язык UI:** русский, строки хардкодированы, i18n не используется.
- **Тесты:** `test/widget_test.dart` — заглушка из шаблона Flutter (тест счётчика), реальные экраны не покрыты. Новые тесты размещать в `test/screens/`, `test/widgets/` и т.д., зеркалируя структуру `lib/`.

## Key Conventions

- Виджеты — `StatelessWidget` по умолчанию; `StatefulWidget` только при наличии локального состояния.
- Именование файлов: `snake_case.dart`; классов и виджетов: `PascalCase`.
- `pubspec.yaml`: все сторонние пакеты добавляются через `flutter pub add <package>`.
- Тесты для виджетов используют `WidgetTester`; unit-тесты не зависят от Flutter-фреймворка.
- После асинхронных операций проверять `mounted` перед вызовом `setState()`.
- `TextEditingController` и другие ресурсы освобождать в `dispose()`.
