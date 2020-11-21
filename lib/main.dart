import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme().copyWith(
          iconTheme: IconThemeData(color: Colors.black, size: 24.0),
          color: Colors.white,
          elevation: 0.0,
        ),
        brightness: Brightness.light,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String operation;
  int _operandfirst = 0;
  int _operandsecond = 0;
  String _operationresult;
  int _opint = 0;
  var rng = new Random();
  final TextEditingController _controller = new TextEditingController();
  void _incrementCounter() {
    setState(() {
      _opint = ((rng.nextInt(105)) % 7);
      print('$_opint');
      switch (_opint) {
        case 0:
          {
            operation = 'square';
            _operandfirst = rng.nextInt(30) + 2;
            _operandsecond = 2;
            _operationresult = (_operandfirst * _operandfirst).toString();
            break;
          }
        case 1:
          {
            operation = 'square';
            _operandfirst = rng.nextInt(30) + 2;
            _operandsecond = 2;
            _operationresult = (_operandfirst * _operandfirst).toString();
            break;
          }
        case 2:
          {
            operation = 'cube';
            _operandfirst = rng.nextInt(10) + 2;
            _operandsecond = 3;
            _operationresult =
                (_operandfirst * _operandfirst * _operandfirst).toString();
            break;
          }
        case 3:
          {
            operation = 'fraction';
            _operandfirst = rng.nextInt(28) + 2;
            _operandsecond = 3;
            double _percentage = (10000 / _operandfirst);
            _operationresult =
                (((_percentage.round()).toDouble()) / 100).toString();
            print(_operationresult);
            break;
          }
        default:
          {
            operation = '×';
            _operandfirst = rng.nextInt(30) + 2;
            _operandsecond = rng.nextInt(20) + 2;
            _operationresult = (_operandfirst * _operandsecond).toString();
            break;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _incrementCounter();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Endless Arithmetic",
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
                _opint == 0
                    ? '$_operandfirst' + '²'
                    : _opint == 1
                        ? '$_operandfirst' + '²'
                        : _opint == 2
                            ? '$_operandfirst' + '³'
                            : _opint == 3
                                ? 'Reciprocal of $_operandfirst in %age'
                                : '$_operandfirst × $_operandsecond',
                style: Theme.of(context).textTheme.display1,
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  labelText: 'Answer',
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _controller,
                onChanged: (String value) async {
                  if (value != '$_operationresult') {
                    return;
                  } else {
                    _controller.clear();
                    _incrementCounter();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
