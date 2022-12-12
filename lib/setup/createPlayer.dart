import 'dart:developer';

import 'package:flutter/material.dart';

import '../main.dart';

class CreatePlayer extends StatefulWidget {
  const CreatePlayer({Key? key}) : super(key: key);

  @override
  State<CreatePlayer> createState() => _CreatePlayerState();
}

class _CreatePlayerState extends State<CreatePlayer> {

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About you"),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Full Name"),
                  TextField(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    controller: nameController,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("Age"),
                  ),
                  TextField(
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: ageController,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: ElevatedButton(
                      onPressed: () {
                        if(nameController.text == "" || ageController.text == "" ) {
                          showToast("You have not filled out all required fields");
                        } else {
                          Map obj = {
                            "id": (ModalRoute.of(context)!.settings.arguments as idCarrier).id,
                            "name": nameController.text,
                            "age": ageController.text,
                          };
                          webRequest(true, "newPlayer", obj).then((value) {
                            log(value.toString());
                          }).catchError((e) {
                            log("error:");
                            log(e.toString());
                            showToast(e.toString());
                          }).then((value) {
                            Navigator.pop(context, obj);
                            return obj;
                          });
                        }
                      },
                      child: const Text("Save"),
                    ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}
