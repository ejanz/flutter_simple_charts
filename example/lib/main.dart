import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/flutter_simple_charts.dart';

void main() {
  runApp(const MyApp());
}

List<Color> customColors = [
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

List<DataItem> itens = [
  DataItem(id: 0, label: 'Oranges', value: 210),
  DataItem(id: 1, label: 'Apples', value: 195),
  DataItem(id: 2, label: 'Bananas', value: 65),
  DataItem(id: 3, label: 'Pears', value: 155, color: Colors.black),
  DataItem(id: 4, label: 'Strawberries', value: 97),
  DataItem(id: 5, label: 'Watermelons', value: 52),
  DataItem(id: 6, label: 'Pineapples', value: 119),
];

class MyApp extends StatelessWidget {
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

class MainPage extends StatelessWidget {
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
      bottomNavigationBar: SizedBox(height: 80),
    );
  }
}

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
