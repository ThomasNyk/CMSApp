import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

class BuyAbilities extends StatefulWidget {
  final Map character;
  final Map gameData;
  const BuyAbilities({Key? key, required this.character, required this.gameData}) : super(key: key);

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
        children: buildAbilityList(widget.character, widget.gameData)
      ),
    );
  }
}

List<Widget> buildAbilityList(Map character, Map gameData) {
  List<Widget> output = [];
  for(int i = 0; i < gameData["abilities"].length; i++) {
    if(meetsRequirements(gameData["abilities"][i]) && !character["abilities"].contains(gameData["abilities"][i]["name"])) {
      output.add(buildAbilityEntry(gameData["abilities"][i]));
    }
  }
  return output;
}

Widget buildAbilityEntry(Map ability) {
  return GestureDetector(
    onTap: () => {
      log("AAAAAAAAAAAA"),
    },
    child: Card(
      child: Padding(
          padding: const EdgeInsets.only(top: 2.0, bottom: 5.0),
          child: Text(ability["name"])
      ),
    ),
  );
}

bool meetsRequirements(Map ability) {
  return true;
}


