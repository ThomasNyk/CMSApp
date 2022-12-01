import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

class RaceInfo extends StatefulWidget {
  final Map character;
  final Map gameData;
  const RaceInfo({Key? key, required this.character, required this.gameData}) : super(key: key);

  @override
  State<RaceInfo> createState() => _RaceInfoState();
}

class _RaceInfoState extends State<RaceInfo> {
  @override
  Widget build(BuildContext context) {
    final race = getObjectByAttribute(widget.gameData["races"], widget.character["race"], "name");
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy abilities for ${widget.character["name"]}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              race!["playerRestrictions"]
          ),
          Text(
              race!["description"]
          ),
        ],
      )
    );
  }
}
