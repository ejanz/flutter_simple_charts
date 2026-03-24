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
# flutter_simple_charts

A very simple donut and bar chart package, lightweight and easy to use

## Features

The flutter_simple_charts offers two types of charts: donut and bar charts.

- **Donut chart** - Very simple donut widget, that visualises categorical data as arc sectors;

- **Bar chart** - Very simple bar chart widget, that visualises categorical data as vertical bars.;

### Screenshots

<div align="center">

![Donut chart](images/donut.gif) | ![Bar chart](images/bar.jpg) | ![Custom donut](images/custom_donut.jpg) | ![Custom bar](images/custom_bar.jpg)
:---:|:---:|:---:|:---:

</div>

## Getting started

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_simple_charts: latest
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/flutter_simple_charts.dart';

/// Entry point for the example application.
void main() {
  runApp(const MyApp());
}

/// A custom palette to demonstrate overriding the default chart colors.
final List<Color> customColors = [
  Colors.orange.shade50,
  Colors.orange.shade100,
  Colors.orange.shade200,
  Colors.orange.shade300,
  Colors.orange.shade400,
  Colors.orange,
  Colors.orange.shade600,
  Colors.orange.shade700,
  Colors.orange.shade800,
  Colors.orange.shade900,
];

/// Sample dataset used by both charts.
///
/// Each [DataItem] represents a category label and a numeric value.
final List<DataItem> itens = [
  DataItem(id: 0, label: 'Oranges', value: 210),
  DataItem(id: 1, label: 'Apples', value: 195),
  DataItem(id: 2, label: 'Bananas', value: 65),
  DataItem(id: 3, label: 'Pears', value: 155),
  DataItem(id: 4, label: 'Strawberries', value: 97),
  DataItem(id: 5, label: 'Watermelons', value: 52),
  DataItem(id: 6, label: 'Pineapples', value: 119),
];

/// Root widget for the example app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charts Demo',
      // Basic theme so the charts look decent out of the box.
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const MainPage(),
    );
  }
}

/// Demonstrates both [DonutChart] and [BarChart] configurations.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Simple Charts'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Donut chart using default palette, legend enabled.
              DonutChart(
                title: 'Fruits Donut chart',
                dataset: itens,
                showLabels: false,
                showLegend: true,
                datasetOrdering: DatasetOrdering.decrescent,
                // Tapping a sector shows a small dialog with the selected item.
                onSectorTap: (sectorValue) => _showDialog(
                  'Item: ${sectorValue.label} - Quantity: ${sectorValue.value}',
                  context,
                ),
              ),

              // Bar chart using default palette, labels + legend enabled.
              BarChart(
                title: 'Fruits Bar chart',
                dataset: itens,
                showLabels: true,
                showLegend: true,
                datasetOrdering: DatasetOrdering.decrescent,
                // Tapping a bar shows the selected item.
                onBarTap: (barValue) => _showDialog(
                  'Item: ${barValue.label} - Quantity: ${barValue.value}',
                  context,
                ),
              ),

              // Donut chart demonstrating custom palette, background, and sizing.
              DonutChart(
                title: 'Fruits Donut chart',
                customColors: customColors.reversed.toList(),
                backGroundColor: Colors.amber.shade100,
                width: 300,
                height: 500,
                dataset: itens,
                showLabels: false,
                showLegend: true,
                datasetOrdering: DatasetOrdering.decrescent,
                onSectorTap: (sectorValue) => _showDialog(
                  'Item: ${sectorValue.label} - Quantity: ${sectorValue.value}',
                  context,
                ),
              ),

              // Bar chart demonstrating the same customisations.
              BarChart(
                title: 'Fruits Bar chart',
                customColors: customColors.reversed.toList(),
                backGroundColor: Colors.amber.shade100,
                width: 350,
                height: 500,
                dataset: itens,
                showLabels: true,
                showLegend: true,
                datasetOrdering: DatasetOrdering.decrescent,
                onBarTap: (barValue) => _showDialog(
                  'Item: ${barValue.label} - Quantity: ${barValue.value}',
                  context,
                ),
              ),
            ],
          ),
        ),
      ),
      // Adds a bit of bottom padding so the legend doesn't feel cramped.
      bottomNavigationBar: const SizedBox(height: 80),
    );
  }
}

/// Shows a simple dialog with [message].
void _showDialog(String message, BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Flutter Single Chart'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
```

## Animation

Both `DonutChart` and `BarChart` animate by default.

You can control (or disable) the entry animation with:

- `animate` (bool, default: `true`)
- `animationDuration` (default: `Duration(milliseconds: 900)`)
- `animationCurve` (default: `Curves.easeOutCubic`)

Example:

```dart
DonutChart(
  title: 'Expenses',
  dataset: itens,
  animationDuration: const Duration(milliseconds: 1200),
  animationCurve: Curves.easeOutQuart,
);

BarChart(
  title: 'Expenses',
  dataset: itens,
  animate: false, // render instantly
);
```

## Hover (desktop/web)

On desktop and web, charts can highlight elements when the mouse hovers over a
bar/sector.

- `enableHover` (bool, default: `true`)
- `onBarHover` / `onSectorHover` (called with a `DataItem?`)

Example:

```dart
BarChart(
  title: 'Fruits',
  dataset: itens,
  onBarHover: (item) {
    // item == null means the pointer left the bars
    debugPrint('hover: ${item?.label}');
  },
);

DonutChart(
  title: 'Fruits',
  dataset: itens,
  onSectorHover: (item) => debugPrint('hover: ${item?.label}'),
);
```

## Tap highlight (mobile)

On mobile (Android/iOS), hover does not exist, so charts can highlight elements
when the user taps them.

- `enableTapHighlight` (bool, default: `true`)
- `toggleTapHighlight` (bool, default: `true`)

Tapping a different bar/sector moves the highlight; tapping the same one again
can clear it (when `toggleTapHighlight: true`).

