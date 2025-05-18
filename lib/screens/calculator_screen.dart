import 'package:flutter/material.dart';
import 'history_screen.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';

  @override
  void initState() {
    super.initState();
    DatabaseService().initDB();
  }

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = _evaluate(_expression);
          final time = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
          DatabaseService().insertHistory('$_expression = $_result', time);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += value;
      }
    });
  }

  String _evaluate(String expr) {
    try {
      final exp = expr.replaceAll('×', '*').replaceAll('÷', '/');
      final tokens = RegExp(r'(\d+(\.\d+)?|[+\-*/])').allMatches(exp).map((m) => m.group(0)!).toList();
      final stack = <double>[];
      final ops = <String>[];

      int precedence(String op) => (op == '+' || op == '-') ? 1 : 2;
      double apply(String op, double b, double a) =>
        op == '+' ? a + b : op == '-' ? a - b : op == '*' ? a * b : a / b;

      for (var t in tokens) {
        if (double.tryParse(t) != null) {
          stack.add(double.parse(t));
        } else {
          while (ops.isNotEmpty && precedence(ops.last) >= precedence(t)) {
            var op = ops.removeLast();
            var b = stack.removeLast();
            var a = stack.removeLast();
            stack.add(apply(op, b, a));
          }
          ops.add(t);
        }
      }

      while (ops.isNotEmpty) {
        var op = ops.removeLast();
        var b = stack.removeLast();
        var a = stack.removeLast();
        stack.add(apply(op, b, a));
      }

      return stack.single.toStringAsFixed(2);
    } catch (_) {
      return 'Error';
    }
  }

  Widget _btn(String value) => Expanded(
    child: ElevatedButton(
      onPressed: () => _onPressed(value),
      child: Text(value, style: const TextStyle(fontSize: 24)),
    )
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_expression, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(_result, style: const TextStyle(fontSize: 24, color: Colors.grey)),
            ],
          ),
        )),
        Row(children: [_btn('7'), _btn('8'), _btn('9'), _btn('÷')]),
        Row(children: [_btn('4'), _btn('5'), _btn('6'), _btn('×')]),
        Row(children: [_btn('1'), _btn('2'), _btn('3'), _btn('-')]),
        Row(children: [_btn('0'), _btn('.'), _btn('='), _btn('+')]),
        Row(children: [_btn('C')]),
      ]),
    );
  }
}