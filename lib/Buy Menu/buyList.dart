import 'dart:developer';

import 'package:cms_for_real/main.dart';
import 'package:cms_for_real/overviewPage/Tabs/abilitiesTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

late Future<Map?> characterFuture;

Future<Map?> getCharacterFuture(String playerId, String characterId) async {
  Map requestObj = {
    "playerId": playerId,
    "characterId": characterId
  };
  Map? character = await webRequest(true, "getCharacter", requestObj);
  log("abilitiesList");
  log(character.toString());
  return Future.value(character);
}
Future<Map?> getCompiledCharacterFuture(String playerId, String characterId) async {
  log("CharacterId");
  log(characterId);
  Map? rawCharacter = await getCharacterFuture(playerId, characterId);
  rawCharacter ??= {};
  Map? gameData = await gameDataFuture;
  gameData ??= {};
  Map? compiledCharacter = await compileCharacterData(rawCharacter, gameData);
  return Future.value(compiledCharacter);
}

class BuyList extends StatefulWidget {
  final String playerId;
  final String characterId;
  final Map gameData;
  final Function mainSetState;
  final String listName;
  final String prettyName;
  const BuyList({Key? key, required this.playerId, required this.characterId, required this.gameData, required this.mainSetState, required this.listName, required this.prettyName}) : super(key: key);

  @override
  State<BuyList> createState() => _BuyListState();
}

class _BuyListState extends State<BuyList> {



  @override
  /*
  void initState() {
    super.initState();
    characterFuture = getAbilitiesFuture(widget.playerId, widget.characterId);
  }
   */



  Widget build(BuildContext context) {
    characterFuture = getCompiledCharacterFuture(widget.playerId, widget.characterId);
    return FutureBuilder(
      future: characterFuture,
      builder: (BuildContext context, AsyncSnapshot characterSnapshot) {
        if(characterSnapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading Character Data")
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Buy ${widget.prettyName} for ${characterSnapshot.data["name"]}'),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                log("REFRESH");
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  playerDataFuture = getPlayerDataFuture(widget.playerId);
                  compiledCharacterFuture = getCompiledCharacterFuture(widget.playerId, widget.characterId);
                });
              },
              child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildBuyList(widget.playerId, characterSnapshot.data, widget.gameData, widget.listName, context, setState, widget.mainSetState)
              ),
            )
          );
        }
      },
    );
  }
}

List<Widget> buildBuyList(String playerID, Map character, Map gameData, String listName, BuildContext context, Function buyAbilitySetState, Function mainSetState) {
  //log("Character:");
  //log(character["AbiList"].toString());
  //log(gameData["AbiList"][0].toString());
  character[listName] ??= [];
  List<Widget> output = [];
  List<Widget> notMetList = [];
  List<Widget> boughtList = [];
  for(int i = 0; i < gameData[listName].length; i++) {
    bool bought = character[listName].contains(gameData[listName][i]["UID"]);
    List<List<String>> failedRequirements = getFailedRequirements(gameData[listName][i], gameData, character);
    log("Failed Req: ${gameData[listName][i]}");
    log(failedRequirements.toString());
    if((failedRequirements.isEmpty || failedRequirements[0].isEmpty)&& !bought) {
      output.add(buildItemEntry(playerID, character, gameData[listName][i], context, true, false, gameData, buyAbilitySetState, mainSetState));
    } else if(!bought){
      notMetList.add(buildItemEntry(playerID, character, gameData[listName][i], context, false, false, gameData, buyAbilitySetState, mainSetState, failedRequirements: failedRequirements));
    } else {
      boughtList.add(buildItemEntry(playerID, character, gameData[listName][i], context, false, true, gameData, buyAbilitySetState, mainSetState));
    }
  }
  if(output.isNotEmpty) {
    output.insert(0, Container(
      color: Colors.black,
      height: 25,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Center(
          child: Text("Can Afford",
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

class BuyObjectCarrier {
  final Map gameData;
  final Map character;
  final Map object;
  final String playerId;
  final int discountCost;

  BuyObjectCarrier(this.gameData, this.character ,this.object, this.playerId, this.discountCost);
}

Widget buildItemEntry(String playerId, Map character, Map ability, BuildContext context, bool requirementsMet, bool bought, Map gameInfo, Function buyAbilitySetState, Function mainSetState, {List<List<String>>? failedRequirements}) {
  return GestureDetector(
    onTap: () async {
      if(!bought && requirementsMet) {
        await navigatorKey.currentState!.pushNamed("/confirmBuy", arguments: BuyObjectCarrier(gameInfo, character, ability, playerId, checkDiscounts(ability, character)));
        buyAbilitySetState(() {
          compiledCharacterFuture = getCompiledCharacterFuture(playerId, character["id"]);
        });
        mainSetState(() {
          playerDataFuture = getPlayerDataFuture(playerId);
        });
        /*
        showDialog(context: context, builder: (context) => AlertDialog(
          title: Text("Are you sure you want to buy: " + ability["Name"]),
          content: Text("The ability costs: " + ability["Cost"].toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () async {
                  Map requestObj = {
                    "id": playerId,
                    "characterId": characterId,
                    "objectId": ability["UID"],
                  };
                  await webRequest(true, "buy", requestObj);
                  reFetchData(playerId, mainSetState);
                  buyAbilitySetState(() {
                    getAbilitiesFuture(playerId, characterId);
                  });
                  Navigator.pop(context);
                },
                child: const Text("Buy"))
          ],
        ))*/
      }
    },
    child: Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: Text(
                  ability["Name"].toString(),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: Column(
                  children: buildAffectedStatsColumn(gameInfo, ability)
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: buildFailedRequirementsWidget(failedRequirements, gameInfo),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Text(ability["Description"]),
            ),
          ),

        ],
      ),
    ),
  );
}

List<Widget> buildFailedRequirementsWidget(List<List<String>>? failedRequirements, Map gameInfo) {
  List<Widget> output = [const Text("Failed Requirements:")];
  if(failedRequirements == null) return [];
  for(List list in failedRequirements) {
    String text = "";
    for(String dependencyPart in list) {
      Map? temp = getObjectByUID(gameInfo, dependencyPart);
      //log(temp.toString());
      temp ??= {"Name": dependencyPart};
      text += temp["Name"] + " ";
    }
    output.add(
        Text(text)
    );
  }

  return output;
}
/*
List<List<String>> getFailedRequirements(Map object, Map gameData, Map character) {
  List<List<String>> failedRequirements = [];
  for(List dependencyOr in object["Dependency"]) {
    bool orLine = false;
    for(String dependency in dependencyOr) {
      String type = dependency.split("-/")[0];
      if(character[type] == null) return [['No list: $type']];
      if(containsAttribute(character[type], dependency, "UID")) orLine = true;
    }
    if(!orLine) failedRequirements.add(dependencyOr.map((e) => e.toString()).toList());
  }
  if(failedRequirements.isEmpty) return [[]];
  return failedRequirements;
}*/
int checkDiscounts(Map object, character) {
  int cost = object["Cost"];
  if(object["Discounts"] == null || object["Discounts"].isEmpty) return cost;
  for(Map discounts in object["Discounts"]) {
    log(discounts.toString());
    String UIDType = discounts["UID"].split("-/")[0];
    if(containsAttribute(character[UIDType], discounts["UID"], "UID")) cost -= discounts["Amount"] as int;
  }
  log("cost");
  log(cost.toString());
  return cost;
}

List<List<String>> getFailedRequirements(Map object, Map gameData, Map character) {
  List<List<String>> failedRequirements = [];
  //log(object.toString());
  //Cost
  int sum = 0;
  bool clearedCost = false;

  if(!(object["CostTypes"] == null && object["CostTypes"].isEmpty)) {
    for(String costType in object["CostTypes"]) {
      Map? temp = getObjectByUID(character, costType);
      log(temp.toString());
      if(temp != null && temp["Amount"] != null) {
        sum += temp["Amount"] as int;
      }
    }
  }

  int cost = checkDiscounts(object, character);
  if(sum >= cost) {
    clearedCost = true;
  } else {
    failedRequirements.add(["Cost: Required: ", cost.toString(), " - In inventory: ", sum.toString()]);
  }

  //Dependencies
  bool clearedDependencies = false;
  if(!(object["Dependencies"] == null || object["Dependencies"].isEmpty || object["Dependencies"][0].isEmpty)) {
    for(List dependencyOr in object["Dependencies"]) {
      bool andLine = true;
      List<String> failedAnd = [];
      for(String dependency in dependencyOr) {
        String type = dependency.toString().split("-/")[0];
        if(character[type] == null) {
          failedAnd.add(dependency);
          andLine = false;
        } else {
          log(character[type].toString());
          if(!containsAttribute(character[type], dependency.toString(), "UID")) {
            failedAnd.add(dependency);
            andLine = false;
          }
        }
      }
      log('andLine: ${andLine.toString()} failed\n + ${failedAnd.toString()}');
      if(failedAnd.isNotEmpty) failedRequirements.add(failedAnd);
      if(andLine) clearedDependencies = true;
    }
  }

  //Exclusions
  bool clearedExclusions = true;
  for(String exclusion in object["Exclusions"]) {
    String type = exclusion.toString().split("-/")[0];
    if(containsAttribute(character[type], exclusion, "UID")) {
      Map? name = getObjectByUID(gameData, exclusion);
      name ??= {"Name": exclusion};
      failedRequirements.add(["Can't have ${name["Name"]}"]);
      clearedExclusions = false;
    }
  }

  if(clearedCost && clearedDependencies && clearedExclusions) {
    return [[]];
  }

  return failedRequirements;
}

bool containsAttribute(List? arr, String target, String attribute) {
  log(arr.toString());
  log(target.toString());
  if(arr == null) return false;
  for(String dependency in arr) {
    if(dependency == target) {
      log("Contains");
      return true;
    }
  }
  log("Not Contain");
  return false;
}