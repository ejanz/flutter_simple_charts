import 'package:flutter/material.dart';

/// Options for sorting order for the dataset
enum DatasetOrdering {
  /// Sort dataset itens as crescent
  crescent,

  /// Sort dataset as decescent
  decrescent,
}

/// The colors to use on sectors of donut chart and bars of bar chart
enum ColorSeed {
  /// Color option
  lightRed('Vermelho Claro', Colors.redAccent),

  /// Color option
  red('Vermelho', Colors.red),

  /// Color option
  pink('Rosa', Colors.pink),

  /// Color option
  purple('Púrpura', Colors.purple),

  /// Color option
  deepPurple('Roxo', Colors.deepPurple),

  /// Color option
  indigo('Indigo', Colors.indigo),

  /// Color option
  blue('Azul', Colors.blue),

  /// Color option
  brightBlue('Azul Claro', Colors.lightBlue),

  /// Color option
  cyan('Ciano', Colors.cyan),

  /// Color option
  teal('Teal', Colors.teal),

  /// Color option
  green('Verde', Colors.green),

  /// Color option
  lightGreen('Verde Claro', Colors.lightGreen),

  /// Color option
  lime('Lima', Colors.lime),

  /// Color option
  yellow('Amarelo', Colors.yellow),

  /// Color option
  amber('Ambar', Colors.amber),

  /// Color option
  orange('Laranja', Colors.orange),

  /// Color option
  deepOrange('Laranja Escuro', Colors.deepOrange),

  /// Color option
  brown('Marrom', Colors.brown),

  /// Color option
  grey('Cinza', Colors.grey),

  /// Color option
  blueGrey('Cinza escuro', Colors.blueGrey);

  const ColorSeed(this.label, this.color);

  /// Color description
  final String label;

  /// The Color option
  final Color color;
}
