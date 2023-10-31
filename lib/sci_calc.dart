import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

const numcolor = Color(0xFF2B2B2B);
const buttonColor = Color(0xFF121212);
const orangecolor = Color(0xFFBABABA);

class Calculator_App extends StatefulWidget {
  const Calculator_App({Key? key}) : super(key: key);

  @override
  State<Calculator_App> createState() => _Calculator_AppState();
}

class _Calculator_AppState extends State<Calculator_App> {
  // Variables
  var input = '';
  var output = '';
  var hideInput = false;
  var outputSize = 24.0;
onButtonClick(value) {
  if (value == 'AC') {
    input = '';
    output = '';
  } else if (value == '<') {
    if (input.isNotEmpty) {
      input = input.substring(0, input.length - 1);
    }
  } else if (value == '=') {
    if (input.isNotEmpty) {
      try {
        String userInput = input
            .replaceAll('X', '*')  // Replace 'X' with '*' for multiplication
            .replaceAll('π', '3.14159265');  // Replace 'π' with its approximate value

        Parser p = Parser();
        Expression expression = p.parse(userInput);
        ContextModel cm = ContextModel();
        var finalValue = expression.evaluate(EvaluationType.REAL, cm);
        output = finalValue.toString();
        if (output.endsWith(".0")) {
          output = output.substring(0, output.length - 2);
        }
      } catch (e) {
        output = 'Error';
      }
      input = output;
      hideInput = true;
      outputSize = 52.0;
    }
  } else if (value == 'DEL') {
    if (input.isNotEmpty) {
      input = input.substring(0, input.length - 1);
    }
  } else if (value == 'x!') {
    // Handle factorial operation
    input = 'factorial(' + input + ')';
  } else if (value == '%') {
    // Handle percentage operation
    input = '(' + input + ')/100';
  } else if (value == 'x') {
    // Handle multiplication
    input = input + '*';
  } else {
    if (value == 'sin' ||
        value == 'cos' ||
        value == 'tan' ||
        value == 'log' ||
        value == 'ln') {
      // Handle scientific operations by appending them to the input
      input = input + value + '(';
    } else {
      input = input + value;
      hideInput = false;
      outputSize = 34.0;
    }
  }

  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 524,
      width: 738,
      decoration: ShapeDecoration(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        shadows: [
          const BoxShadow(
            color: Color(0x2B000000),
            blurRadius: 8,
            offset: Offset(15, 15),
            spreadRadius: -5,
          )
        ],
      ),
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Input and output area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF656565),
                      shape: OvalBorder(),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: const Icon(
                      Icons.exit_to_app_sharp,
                      color: Color(0xFF656565),
                      size: 32,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
          Container(
            height: 133,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hideInput ? '' : input,
                  style: const TextStyle(
                    fontSize: 34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  output,
                  style: TextStyle(
                    fontSize: outputSize,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Add the new buttons in the appropriate rows
          Expanded(
            child: Container(
              child: SizedBox(
                width: double.infinity,
                height: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        button(text: 'sin'),
                        button(text: 'cos'),
                        button(text: 'tan'),
                        button(text: 'log'),
                        button(text: 'ln'),
                      ],
                    ),
                    Column(
                      children: [
                        button(text: 'x '),
                        button(text: 'x!'),
                        button(text: '√'),
                        button(text: '1/x'),
                        button(text: 'π'),
                      ],
                    ),
                    Column(
                      children: [
                        button(text: '7', buttonBGcolor: numcolor),
                        button(text: '4', buttonBGcolor: numcolor),
                        button(text: '1', buttonBGcolor: numcolor),
                        button(text: '0', buttonBGcolor: numcolor),
                      ],
                    ),
                    Column(
                      children: [
                        button(text: '8', buttonBGcolor: numcolor),
                        button(text: '5', buttonBGcolor: numcolor),
                        button(text: '2', buttonBGcolor: numcolor),
                        button(text: '.', buttonBGcolor: numcolor),
                      ],
                    ),
                    Column(
                      children: [
                        button(text: '9', buttonBGcolor: numcolor),
                        button(text: '6', buttonBGcolor: numcolor),
                        button(text: '3', buttonBGcolor: numcolor),
                        button(text: 'DEL', buttonBGcolor: numcolor),
                      ],
                    ),
                    Column(
                      children: [
                        button(text: 'AC'),
                        button(text: '÷'),
                        button(text: '×'),
                        button(text: '-'),
                        button(text: '+'),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 154,
                          child: Column(
                            children: [
                              button(text: '%'),
                              button(text: '('),
                              button(text: ')'),
                            ],
                          ),
                        ),
                        button(
                            text: '=',
                            buttonBGcolor: Color(0xFFBABABA),
                            tColor: Colors.black,
                            equal: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget button({text, tColor = Colors.white, buttonBGcolor = buttonColor, equal = false}) {
    return Expanded(
      child: Container(
        height: equal ? 50 : 75,
        width: 78,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.all(11),
            primary: buttonBGcolor,
          ),
          onPressed: () => onButtonClick(text),
          child: Text(
            text,
            style: TextStyle(
              fontSize: (text == "=") ? 36 : 18,
              color: tColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
