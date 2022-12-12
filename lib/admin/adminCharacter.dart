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

Future<List<Map>> filterCharacterRes(Map adminCharacter, Map? gameData) {
  if (gameData == null) return Future.error("GameData empty");
  List<Map> resList = [];
  for(Map res in gameData["ResList"]) {
    if(res["Type"] == 0) continue;
    Map? characterRes = getObjectByUID(adminCharacter, res["UID"]);
    characterRes ??= {
      "UID": res["UID"],
      "Amount": 0,
    };
    resList.add(characterRes);
  }
  return Future.value(resList);
}
late Future<List<Map>> resList;

Future<void> getStuffDoneAsync() async {
  resList = filterCharacterRes(await adminCharacter, await gameDataFuture);
}

class _AdminCharacterState extends State<AdminCharacter> {

  @override
  void initState() {
    adminCharacter = getAdminCharacterFuture(widget.playerId, widget.characterId);
    getStuffDoneAsync();
  }

  @override
  Widget build(BuildContext context) {
    if(adminCharOnce) {
      adminCharOnce = false;

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
                      body: FutureBuilder(
                        future: resList,
                        builder: (BuildContext context, AsyncSnapshot resListFuture) {
                          if(resListFuture.connectionState != ConnectionState.done) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 5, top: 10, right: 5),
                              child: Column(
                                children: const [
                                  CircularProgressIndicator(),
                                  Text("Loading ResList"),
                                ],
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(left: 5, top: 10, right: 5),
                              child: Column(
                                children: [
                                  ListView.builder(
                                      itemCount: resListFuture.data.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Card(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    resListFuture.data[index]["Amount"] -= 1;
                                                  });
                                                },
                                                icon: const Icon(Icons.remove),
                                              ),
                                              Text('${getObjectByUID(gameDataSnapshot.data, resListFuture.data[index]["UID"])!["Name"].toString()}:  ${resListFuture.data[index]["Amount"].toString()}'),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    resListFuture.data[index]["Amount"] += 1;
                                                  });
                                                },
                                                icon: const Icon(Icons.add),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ElevatedButton(
                                    onPressed: () async {

                                      Navigator.pop(context);
                                    },
                                    child: Text("Save"))
                                ],
                              )
                            );
                          }
                        },
                      )
                    );
                  }
                });


          }
        }
      );
  }
}