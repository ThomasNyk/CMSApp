import 'package:cms_for_real/main.dart';
import 'package:cms_for_real/overviewPage/Tabs/abilitiesTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

late Future<Map?> characterFuture;
TextEditingController searchController = TextEditingController();
String hideShowExclusions = "Show";

Future<Map?> getCharacterFuture(String playerId, String characterId) async {
  Map requestObj = {
    "playerId": playerId,
    "characterId": characterId
  };
  Map? character = await jsonDecodeFutureMap(webRequest(true, "getCharacter", requestObj));
  //log("abilitiesList");
  //log(character.toString());
  return Future.value(character);
}
Future<Map?> getCompiledCharacterFuture(String playerId, String characterId) async {
  //log("CharacterId");
  //log(characterId);
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
  void initState() {
    super.initState();
    characterFuture = getCompiledCharacterFuture(widget.playerId, widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
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
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: (value) => handleClick(setState),
                  itemBuilder: (BuildContext context) {
                    return {'$hideShowExclusions exclusions'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                //log("REFRESH");
                await Future.delayed(const Duration(seconds: 1));
                searchController.text = "";
                setState(() {
                  playerDataFuture = getPlayerDataFuture(widget.playerId);
                  compiledCharacterFuture = getCompiledCharacterFuture(widget.playerId, widget.characterId);
                });
              },
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search)
                    ),
                    controller: searchController,
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                      });
                    },
                  ),
                  Expanded(
                    child: ListView(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: buildBuyList(widget.playerId, characterSnapshot.data, widget.gameData, widget.listName, context, setState, widget.mainSetState)
                    ),
                  ),
                ],
              )

            )
          );
        }
      },
    );
  }
}

List<Map<String, dynamic>> Filter(List<dynamic> gameList, String filter, Map gameData, Map character) {
  List<Map<String, dynamic>> result = [];
  for (var element in gameList) {
    if (element["Name"].toLowerCase().contains(filter.toLowerCase())) {
      List<List<String>>? exclusions = getExclusions(gameData, element["UID"], character);

      if (hideShowExclusions == "Hide" || exclusions == null) {
        result.add(element);
      }
    }
  }

  return result;
}

void handleClick(Function setStater) {

  setStater(() {
    if(hideShowExclusions == "Hide") {
      hideShowExclusions = "Show";
    } else {
      hideShowExclusions = "Hide";
    }
  });
}

List<List<String>>? getExclusions(Map gameData, String uid, Map character) {
  Map? obj = getObjectByUID(gameData, uid);

  if(obj == null) return null;

  List<dynamic> exclusions = obj["Exclusions"];
  if(exclusions.isEmpty) return null;

  List<List<String>> result = [];

  for (dynamic exclusion in exclusions) {
    String listName = exclusion.toString().split("-/")[0];
    List<dynamic> list = character[listName] as List<dynamic>;
    for(String item in list) {
      if(item == exclusion) {
        Map? temp = getObjectByUID(gameData, item);
        temp ??= {"Name": "UndefinedName"};
        result.add(["Excluded: ${temp["Name"]}"]);
      }
    }
  }

  if(result.isEmpty) return null;

  return result;
}

List<Widget> buildBuyList(String playerID, Map character, Map gameData, String listName, BuildContext context, Function buyAbilitySetState, Function mainSetState) {
  character[listName] ??= [];
  List<Widget> output = [];
  List<Widget> notMetList = [];
  List<Widget> cantAffordList = [];
  List<Widget> boughtList = [];

  List<dynamic> filtered = Filter(gameData[listName], searchController.text, gameData, character);

  for(int i = 0; i < filtered.length; i++) {
    bool bought = character[listName].contains(filtered[i]["UID"]);
    List<List<String>> failedRequirements = getFailedRequirements(filtered[i], gameData, character);
    List<List<String>> cantafford = getCantAfford(filtered[i], gameData, character);
    //log(cantafford.toString());

    if((failedRequirements.isEmpty || failedRequirements[0].isEmpty) && !bought && cantafford[0].isEmpty) {
      output.add(buildItemEntry(playerID, character, filtered[i], context, true, false, gameData, buyAbilitySetState, mainSetState));
    } else if(!bought && (failedRequirements.isEmpty || failedRequirements[0].isEmpty) && cantafford[0].isNotEmpty){
      cantAffordList.add(buildItemEntry(playerID, character, filtered[i], context, false, false, gameData, buyAbilitySetState, mainSetState, failedRequirements: cantafford));
    } else if(!bought && (failedRequirements.isNotEmpty || failedRequirements[0].isNotEmpty)) {
      if(cantafford[0].isNotEmpty) {
        failedRequirements = cantafford += failedRequirements;
      }
      notMetList.add(buildItemEntry(playerID, character, filtered[i], context, false, false, gameData, buyAbilitySetState, mainSetState, failedRequirements: failedRequirements));
    } else {
      boughtList.add(buildItemEntry(playerID, character, filtered[i], context, false, true, gameData, buyAbilitySetState, mainSetState));
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

  if(cantAffordList.isNotEmpty) {
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
    output += cantAffordList;
  }

  if(notMetList.isNotEmpty) {
    output.add(Container(
      color: Colors.black,
      height: 25,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Center(
          child: Text("Requirements not met",
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
    //log(discounts.toString());
    String UIDType = discounts["UID"].split("-/")[0];
    if(containsAttribute(character[UIDType], discounts["UID"], "UID")) cost -= discounts["Amount"] as int;
  }
  //log("cost");
  //log(cost.toString());
  return cost;
}

List<List<String>> getCantAfford(Map object, Map gameData, Map character) {
  List<List<String>> failedRequirements = [];
  //Cost
  int sum = 0;
  bool clearedCost = false;

  if(!(object["CostTypes"] == null && object["CostTypes"].isEmpty)) {
    for(String costType in object["CostTypes"]) {
      Map? temp = getObjectByUID(character, costType);
      //log(temp.toString());
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

  if(clearedCost) return [[]];

  return failedRequirements;
}

List<List<String>> getFailedRequirements(Map object, Map gameData, Map character) {
  List<List<String>> failedRequirements = [];
  //log(object.toString());
  /*
  //Cost
  int sum = 0;
  bool clearedCost = false;

  if(!(object["CostTypes"] == null && object["CostTypes"].isEmpty)) {
    for(String costType in object["CostTypes"]) {
      Map? temp = getObjectByUID(character, costType);
      //log(temp.toString());
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
   */

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
          //log(character[type].toString());
          if(!containsAttribute(character[type], dependency.toString(), "UID")) {
            failedAnd.add(dependency);
            andLine = false;
          }
        }
      }
      //log('andLine: ${andLine.toString()} failed\n + ${failedAnd.toString()}');
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

  if(clearedDependencies && clearedExclusions) {
    return [[]];
  }

  return failedRequirements;
}

bool containsAttribute(List? arr, String target, String attribute) {
  //log(arr.toString());
  //log(target.toString());
  if(arr == null) return false;
  for(String dependency in arr) {
    if(dependency == target) {
      //log("Contains");
      return true;
    }
  }
  //log("Not Contain");
  return false;
}