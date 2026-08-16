import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class ArithmeticQuestion {
  const ArithmeticQuestion._({required this.prompt, required this.answer});

  factory ArithmeticQuestion.generate(Random random) {
    final operation = random.nextInt(105) % 7;

    switch (operation) {
      case 0:
      case 1:
        final operand = random.nextInt(30) + 2;
        return ArithmeticQuestion._(
          prompt: '$operand²',
          answer: (operand * operand).toString(),
        );
      case 2:
        final operand = random.nextInt(10) + 2;
        return ArithmeticQuestion._(
          prompt: '$operand³',
          answer: (operand * operand * operand).toString(),
        );
      case 3:
        final operand = random.nextInt(28) + 2;
        final percentage = 10000 / operand;
        final answer = percentage.roundToDouble() / 100;
        return ArithmeticQuestion._(
          prompt: 'Reciprocal of $operand in %age',
          answer: answer.toString(),
        );
      default:
        final firstOperand = random.nextInt(30) + 2;
        final secondOperand = random.nextInt(20) + 2;
        return ArithmeticQuestion._(
          prompt: '$firstOperand × $secondOperand',
          answer: (firstOperand * secondOperand).toString(),
        );
    }
  }

  final String prompt;
  final String answer;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.random});

  final Random? random;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Endless Arithmetic',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black, size: 24),
        ),
      ),
      home: MyHomePage(random: random),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.random});

  final Random? random;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  late final Random _random;
  late ArithmeticQuestion _question;

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? Random();
    _question = ArithmeticQuestion.generate(_random);
  }

  void _handleAnswerChanged(String value) {
    if (value != _question.answer) {
      return;
    }

    _controller.clear();
    setState(() {
      _question = ArithmeticQuestion.generate(_random);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Endless Arithmetic',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _question.prompt,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelText: 'Answer',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                onChanged: _handleAnswerChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
