import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/flutter_simple_charts.dart';

void main() {
  runApp(const MyApp());
}

/// Sample data for chart demonstration.
/// Contains fruit names with their corresponding quantities.
List<DataItem> itens = [
  DataItem(id: 0, label: 'Oranges', value: 210),
  DataItem(id: 1, label: 'Apples', value: 195),
  DataItem(id: 2, label: 'Bananas', value: 65),
  DataItem(id: 3, label: 'Pears', value: 155),
  DataItem(id: 4, label: 'Strawberries', value: 97),
  DataItem(id: 5, label: 'Watermelons', value: 52),
  DataItem(id: 6, label: 'Pineapples', value: 119),
];

/// Root widget of the application.
/// Sets up the Material Design theme and navigation.
class MyApp extends StatelessWidget {
  /// Root widget of the application.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charts Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.indigo)),
      home: MainPage(),
    );
  }
}

/// Main page displaying chart examples.
/// Shows both DonutChart and BarChart widgets with interactive features.
class MainPage extends StatelessWidget {
  /// Main page displaying chart examples.
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Single Charts'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Donut chart displaying fruit quantities
              /// - Shows legend but hides labels
              /// - Sorted in descending order
              /// - Tapping a sector shows item details in a dialog
              DonutChart(
                title: 'Fruits Donut chart',
                dataset: itens,
                showLabels: false,
                showLegend: true,
                datasetOrdering: DatasetOrdering.decrescent,
                onSectorTap: (sectorValue) => _showDialog(
                  'Item: ${sectorValue.label} - Quantity: ${sectorValue.value}',
                  context,
                ),
              ),

              /// Bar chart displaying fruit quantities
              /// - Shows both legend and labels
              /// - Sorted in descending order
              /// - Tapping a bar shows item details in a dialog
              BarChart(
                title: 'Fruits Bar chart',
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
      bottomNavigationBar: SizedBox(height: 80),
    );
  }
}

/// Displays an alert dialog with the provided message.
///
/// Parameters:
///   - [message]: The text content to display in the dialog
///   - [context]: The build context used to show the dialog
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
