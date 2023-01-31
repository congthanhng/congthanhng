import 'dart:math';
import 'dart:core';

void main(List<String> arguments) {
  var dice1 = Random().nextInt(6) + 1;
  var dice2 = Random().nextInt(6) + 1;
  print('${arguments[0]}: $dice1 - $dice2');
}