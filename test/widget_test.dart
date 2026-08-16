import 'dart:math';

import 'package:endless/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates the supported arithmetic question types', () {
    final cases = <({List<int> randomValues, String prompt, String answer})>[
      (randomValues: [0, 3], prompt: '5²', answer: '25'),
      (randomValues: [1, 3], prompt: '5²', answer: '25'),
      (randomValues: [2, 4], prompt: '6³', answer: '216'),
      (randomValues: [3, 2], prompt: 'Reciprocal of 4 in %age', answer: '25.0'),
      (randomValues: [4, 3, 5], prompt: '5 × 7', answer: '35'),
    ];

    for (final testCase in cases) {
      final question = ArithmeticQuestion.generate(
        SequenceRandom(testCase.randomValues),
      );

      expect(question.prompt, testCase.prompt);
      expect(question.answer, testCase.answer);
    }
  });

  testWidgets('entering the correct answer advances to a new question', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(random: SequenceRandom([0, 3, 2, 4])));

    expect(find.text('Endless Arithmetic'), findsOneWidget);
    expect(find.text('5²'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '24');
    await tester.pump();
    expect(find.text('5²'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '25');
    await tester.pump();
    expect(find.text('6³'), findsOneWidget);
    expect(find.text('25'), findsNothing);
  });
}

class SequenceRandom implements Random {
  SequenceRandom(this._values);

  final List<int> _values;
  int _index = 0;

  @override
  int nextInt(int max) {
    if (_index >= _values.length) {
      throw StateError('No random value configured for nextInt($max).');
    }

    final value = _values[_index++];
    if (value < 0 || value >= max) {
      throw StateError('Configured value $value is outside [0, $max).');
    }
    return value;
  }

  @override
  bool nextBool() => throw UnsupportedError('nextBool is not used');

  @override
  double nextDouble() => throw UnsupportedError('nextDouble is not used');
}
