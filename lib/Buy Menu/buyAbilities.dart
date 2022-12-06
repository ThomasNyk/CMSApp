import 'dart:developer';
import 'dart:ffi';

import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

class BuyAbilities extends StatefulWidget {
  final String playerID;
  final Map character;
  final Map gameData;
  const BuyAbilities({Key? key, required this.playerID, required this.character, required this.gameData}) : super(key: key);

  @override
  State<BuyAbilities> createState() => _BuyAbilitiesState();
}

class _BuyAbilitiesState extends State<BuyAbilities> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy abilities for ${widget.character["name"]}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildAbilityList(widget.playerID, widget.character, widget.gameData, context)
      ),
    );
  }
}

List<Widget> buildAbilityList(String playerID, Map character, Map gameData, BuildContext context) {
  //log("Character:");
  //log(character["AbiList"].toString());
  //log(gameData["AbiList"][0].toString());
  character["AbiList"] ??= [];
  List<Widget> output = [];
  List<Widget> notMetList = [];
  List<Widget> boughtList = [];
  for(int i = 0; i < gameData["AbiList"].length; i++) {
    bool bought = character["AbiList"].contains(gameData["AbiList"][i]["UID"]);
    if(meetsRequirements(gameData["AbiList"][i], gameData, character) && !bought) {
      output.add(buildAbilityEntry(playerID, character["id"], gameData["AbiList"][i], context, true, false));
    } else if(!bought){
      notMetList.add(buildAbilityEntry(playerID, character["id"], gameData["AbiList"][i], context, false, false));
    } else {
      boughtList.add(buildAbilityEntry(playerID, character["id"], gameData["AbiList"][i], context, false, true));
    }
  }
  if(output.isNotEmpty) {
    output.add(Container(
      color: Colors.black,
      height: 25,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Center(
          child: Text("Can't afford",
            style: TextStyle(color: Colors.white),),
        ),
      ),
    ),
    );
  }

  if(notMetList.isNotEmpty) {
    output.add(Container(
      color: Colors.black,
      height: 25,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Center(
          child: Text("Can't afford",
            style: TextStyle(color: Colors.white),),
        ),
      ),
    ),
    );
    output += notMetList;
  }

  if(boughtList.isNotEmpty) {
    output.add(Container(
      color: Colors.black,
      height: 25,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Center(
          child: Text("Purchased",
            style: TextStyle(color: Colors.white),),
        ),
      ),
    ),
    );
    output += boughtList;
  }


  return output;
}

Widget buildAbilityEntry(String playerId, String characterId, Map ability, BuildContext context, bool canAfford, bool bought) {
  return GestureDetector(
    onTap: () => {
      if(!bought) {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: Text("Are you sure you want to buy: " + ability["Name"]),
          content: const Text("The ability costs: " + "Something"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  Map requestObj = {
                    "id": playerId,
                    "characterId": characterId,
                    "objectId": ability["UID"],
                  };
                  webRequest(true, "buy", requestObj);
                  Navigator.pop(context);
                },
                child: const Text("Buy"))
          ],
        ))
      }
    },
    child: Card(
      child: Padding(
          padding: const EdgeInsets.only(top: 2.0, bottom: 5.0),
          child: Text(ability["Name"])
      ),
    ),
  );
}

bool meetsRequirements(Map object, Map gameData, character) {
  for(List dependencyOr in object["Dependency"]) {
    bool orLine = false;
    log(dependencyOr.toString());
    for(String dependency in dependencyOr) {
      String type = dependency.split("-/")[0];
      if(character[type] == null) return false;
      if(containsAttribute(character[type], dependency, "UID")) orLine = true;
    }
    if(!orLine) return false;
  }
  return true;
}


bool containsAttribute(List arr, String target, String attribute) {
  for(Map dependency in arr) {
    if(dependency[attribute] == target) {
      return true;
    }
  }
  return false;
}

