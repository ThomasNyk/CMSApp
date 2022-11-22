import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

final userController = TextEditingController();
final passController = TextEditingController();

@protected String username = "";
@protected String password = "";

TextStyle textStyle = const TextStyle(
  fontSize: 30,
  color: Colors.black,
);
TextStyle textfieldStyle = const TextStyle(
  fontSize: 20.0,
);

ColorScheme mainTheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.grey,
    onPrimary: Colors.white,
    secondary: Colors.black,
    onSecondary: Colors.blue,
    error: Colors.red,
    onError: Colors.redAccent,
    background: Colors.grey,
    onBackground: Colors.grey,
    surface: Colors.grey,
    onSurface: Colors.grey);

void checkLogin (context) async {
  Object obj = jsonEncode({
    "usr": userController.text,
    "psw": passController.text
  });
  var url = Uri.http('192.168.0.139:8000', 'login');
  var response = await http.post(url, body: obj);
  if(response.statusCode != 200) {
    Fluttertoast.showToast(
        msg: "Login Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  } else {
    var loginData = jsonEncode({
      "id": jsonDecode(response.body)["id"],
      "rememberMe": rememberMe
    });

    Navigator.pop(context, loginData);
  }
  log('Response status: ${response.statusCode}');
  log('Response body: ${response.body}');
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Padding(padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Text("Username",
                    style: textStyle,
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                child: TextField(
                  controller: userController,
                  textInputAction: TextInputAction.next,
                  onChanged: (String? value) {
                    username = value!;
                  },
                  style: textfieldStyle,
                  decoration: InputDecoration(
                      labelText: "Username",
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(
                        color: mainTheme.secondary,
                      )
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Text("Password",
                    style: textStyle,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: passwordField()
              ),
              Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: [
                    const Flexible(
                      child: checkbox(),
                    ),
                    Padding(padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
                      child: TextButton(onPressed: () {
                          checkLogin(context);
                      }, style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(mainTheme.secondary),
                          backgroundColor: MaterialStateProperty.all<Color>(mainTheme.primary),
                        ),
                        child: const Text("Log In",),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class passwordField extends StatefulWidget {
  const passwordField({Key? key}) : super(key: key);

  @override
  _passwordFieldState createState() => _passwordFieldState();
}

bool obscure = true;
Icon d = Icon(Icons.visibility, color: mainTheme.primary);

class _passwordFieldState extends State<passwordField> {
  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: passController,
      style: textfieldStyle,
      obscureText: obscure,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
          labelText: "Password",
          alignLabelWithHint: true,
          labelStyle: TextStyle(color: mainTheme.secondary),
          suffixIcon: IconButton(onPressed: () {
            setState(() {
              if(obscure){
                d = Icon(Icons.visibility, color: mainTheme.primary);
                obscure = false;
              } else {
                d = Icon(Icons.visibility_off, color: mainTheme.primary);
                obscure = true;
              }
            });
          },
            icon: d,
            color: mainTheme.secondary,
          )
      ),
    );
  }
}


bool rememberMe = false;

class checkbox extends StatefulWidget {
  const checkbox({Key? key}) : super(key: key);

  @override
  _checkboxState createState() => _checkboxState();
}
class _checkboxState extends State<checkbox> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.fromLTRB(15, 0, 20, 0),
      child: Row(
        children: [
          Theme(
              data: ThemeData(unselectedWidgetColor: mainTheme.primary),
              child: Checkbox(value: rememberMe, tristate: false, onChanged: (bool? value) {
                setState(() {
                  rememberMe = !rememberMe;
                });
              },
                activeColor: mainTheme.primary,
                checkColor: Colors.white,
              )
          ),
          Text("Remember me?", style: TextStyle(color: mainTheme.secondary, fontSize: 16))
        ],
      ),
    );
  }
}