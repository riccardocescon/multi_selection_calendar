<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Multi Selection Calendar

A highly customizable Flutter package that provides a calendar widget with multi-selection support for date ranges. It supports both Override and Overlap range selection modes.

## Features

- ✅ Multi-date range selection
- ✅ Override and Overlap range modes
- ✅ Highly customizable appearance
- ✅ Easy to integrate
- ✅ Smooth animations and interactions

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

Add this package to your Flutter project:

```yaml
dependencies:
  multi_selection_calendar: ^1.0.0
```

Then run:

```bash
flutter pub get
```

TODO: List prerequisites and provide or point to information on how to start using the package.

## Usage

Import the package and use the MultiSelectionCalendar widget:

```dart
import 'package:multi_selection_calendar/multi_selection_calendar.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Multi Selection Calendar')),
        body: MultiSelectionCalendar(
          onSelectionAdded: (selection) {
            print('Selected range: $selection');
          },
        ),
      ),
    );
  }
}
```

TODO: Include short and useful examples for package users. Add longer examples to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to contribute to the package, how to file issues, what response they can expect from the package authors, and more.