import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'main.dart';

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


bool secondConfirm = false;
void checkLogin (context) async {
  if(confirmation != true) {
    showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text("IMPORTANT"),
        content: const Text("DO NOT USE IMPORTANT PASSWORDS. This server does not run on a secure connection, nor is the passwords encrypted before storage."
            "You and only you take full responsibility for all the information you enter"
            "check the \"I understand...\" when you understand and try again"),
        actions: [
          TextButton(
              onPressed: () {
                secondConfirm = false;
                confirmation = false;
                Navigator.pop(context);
              },
              child: const Text("I do not understand")),
          TextButton(
              onPressed: () {
                secondConfirm = true;
                confirmation = false;
                Navigator.pop(context);
              },
              child: const Text("I understand")),
        ],
    ));
  } else if(secondConfirm != true){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("IMPORTANT"),
      content: const Text("DO NOT USE IMPORTANT PASSWORDS(or usernames). This server does not utilize a secure connection, nor are the passwords encrypted before storage. "
          "You and only you take full responsibility for all the information you enter "
          "To prove you are reading this I will now secretly uncheck the required checkmark and you will have to recheck it and press the register button again"
          "\nBy clicking ok below you confirm that you fully understand this, agree to it, and void any right to keep data entered secure"
      ),
      actions: [
        TextButton(
            onPressed: () {
              secondConfirm = false;
              confirmation = false;
              Navigator.pop(context);
            },
            child: const Text("I do not understand")),
        TextButton(
            onPressed: () {
              secondConfirm = true;
              confirmation = false;
              Navigator.pop(context);
            },
            child: const Text("I understand")),
      ],
    ));
  } else {
    var loginData = {
        "username": userController.text,
        "password": passController.text,
        "isAdmin": isAdmin,
      };
    showToast("Sending data");
    http.Response response = await webRequest(true, "registerUser", loginData);
    if(response.statusCode == 200) {
      showToast("User created");
    } else {
      showToast("Failed to create user, try again");
    }
    confirmation = false;
    secondConfirm = false;
    isAdmin = false;
    Navigator.pop(context);
  }
  //log('Response status: ${response.statusCode}');
  //log('Response body: ${response.body}');
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text("IMPORTANT"),
        content: const Text("DO NOT USE IMPORTANT PASSWORDS. This server does not run on a secure connection, nor are the passwords encrypted before storage."
            "You and only you take full responsibility for all the information you enter"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ));
    });
    userController.text = "";
    passController.text = "";
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Register'),
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
                  const Expanded(
                    child: checkboxTwo(),
                  ),
                  Padding(padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
                    child: TextButton(onPressed: () {
                      checkLogin(context);
                    }, style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(mainTheme.secondary),
                      backgroundColor: MaterialStateProperty.all<Color>(mainTheme.primary),
                    ),
                      child: const Text("Register",),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 25, 10, 0),
              child: checkbox(),
            ),
          ],
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


bool confirmation = false;

class checkbox extends StatefulWidget {
  const checkbox({Key? key}) : super(key: key);

  @override
  _checkboxState createState() => _checkboxState();
}
class _checkboxState extends State<checkbox> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
      child: Column(
        children: [
          Theme(
              data: ThemeData(unselectedWidgetColor: mainTheme.primary),
              child: Checkbox(value: confirmation, tristate: false, onChanged: (bool? value) {
                setState(() {
                  confirmation = !confirmation;
                });
              },
                activeColor: mainTheme.primary,
                checkColor: Colors.white,
              )
          ),
          Text("I take full responsibility for the information i enter here and assume other people WILL see it!", style: TextStyle(color: mainTheme.secondary, fontSize: 16))
        ],
      ),
    );
  }
}


bool isAdmin = false;
class checkboxTwo extends StatefulWidget {
  const checkboxTwo({Key? key}) : super(key: key);

  @override
  _checkboxTwoState createState() => _checkboxTwoState();
}
class _checkboxTwoState extends State<checkboxTwo> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
      child: Row(
        children: [
          Theme(
              data: ThemeData(unselectedWidgetColor: mainTheme.primary),
              child: Checkbox(value: isAdmin, tristate: false, onChanged: (bool? value) {
                setState(() {
                  isAdmin = !isAdmin;
                });
              },
                activeColor: mainTheme.primary,
                checkColor: Colors.white,
              )
          ),
          Text("Is admin?", style: TextStyle(color: mainTheme.secondary, fontSize: 16))
        ],
      ),
    );
  }
}