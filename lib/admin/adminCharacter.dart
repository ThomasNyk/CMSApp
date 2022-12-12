import 'dart:developer';

import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';


class AdminCharacter extends StatefulWidget {
  final String playerId;
  final String characterId;
  const AdminCharacter({Key? key, required this.playerId, required this.characterId,}) : super(key: key);

  @override
  State<AdminCharacter> createState() => _AdminCharacterState();
}

late Future adminCharacter;
bool adminCharOnce = true;

Future<Map> getAdminCharacterFuture(String playerId, String characterId) async {
  Map response = await webRequest(true, "/getCharacter", {"playerId": playerId, "characterId": characterId});
  //return Future.value(response);
  return Future.value(response);
}

class _AdminCharacterState extends State<AdminCharacter> {
  @override
  Widget build(BuildContext context) {
    if(adminCharOnce) {
      adminCharOnce = false;
      adminCharacter = getAdminCharacterFuture(widget.playerId, widget.characterId);
    }
    return FutureBuilder(
        future: adminCharacter,
        builder: (BuildContext context, AsyncSnapshot adminCharacterSnapshot) {
          if (adminCharacterSnapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              body: Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    Text("Loading player data")
                  ],
                ),
              ),
            );
          } else {
            return FutureBuilder(
                future: gameDataFuture,
                builder: (BuildContext context, AsyncSnapshot gameDataSnapshot) {
                  if(gameDataSnapshot.connectionState != ConnectionState.done) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          children: const [
                            CircularProgressIndicator(),
                            Text("Loading player data")
                          ],
                        ),
                      ),
                    );
                  } else {
                    log(adminCharacterSnapshot.toString());
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(adminCharacterSnapshot.data["name"]),
                      ),
                      body: Padding(
                        padding: EdgeInsets.only(left: 5, top: 10, right: 5),
                        child: ListView.builder(
                            itemCount: gameDataSnapshot.data["ResList"].length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          gameDataSnapshot.data["ResList"][index]["Amount"] -= 1;
                                        });
                                      },
                                        icon: const Icon(Icons.remove),
                                    ),
                                    Text('${gameDataSnapshot!["Name"].toString()}:  ${playerResource!["Amount"].toString()}'),
                                    IconButton(
                                        onPressed: () {
                                          gameDataSnapshot.data["ResList"][index]["Amount"] += 1;
                                        },
                                        icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    );
                  }
                });


          }
        }
      );
  }
}