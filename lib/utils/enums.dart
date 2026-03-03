import 'package:flutter/material.dart';

enum AccountType { check, card }

enum TransactionMode { create, copy, import, update }

enum TransactionType { recipe, expense, transfer, payment }

enum InvestmentType { buy, sell }

enum DatasetOrdering { crescent, decrescent }

enum ColorSeed {
  lightRed('Vermelho Claro', Colors.redAccent),
  red('Vermelho', Colors.red),
  pink('Rosa', Colors.pink),
  purple('Púrpura', Colors.purple),
  deepPurple('Roxo', Colors.deepPurple),
  indigo('Indigo', Colors.indigo),
  blue('Azul', Colors.blue),
  brightBlue('Azul Claro', Colors.lightBlue),
  cyan('Ciano', Colors.cyan),
  teal('Teal', Colors.teal),
  green('Verde', Colors.green),
  lightGreen('Verde Claro', Colors.lightGreen),
  lime('Lima', Colors.lime),
  yellow('Amarelo', Colors.yellow),
  amber('Ambar', Colors.amber),
  orange('Laranja', Colors.orange),
  deepOrange('Laranja Escuro', Colors.deepOrange),
  brown('Marrom', Colors.brown),
  grey('Cinza', Colors.grey),
  blueGrey('Cinza escuro', Colors.blueGrey);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}
