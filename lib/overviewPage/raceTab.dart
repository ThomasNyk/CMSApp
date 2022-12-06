import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

Widget RaceTab() {
  return FutureBuilder(
    future: playerDataFuture,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if(!snapshot.hasData) {
        return const Center(
          child: Text("Loading Player Data"),
        );
      } else {
        Map? localCharacter = getObjectByAttribute(snapshot.data["characters"], selectedCharacter, "id");
        if(localCharacter == null) {
          return const Center(
            child: Text("Could not find character"),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  localCharacter["race"],
                  style: const TextStyle(fontSize: 30),
                ),
              )
            ),
            FutureBuilder(
              future: gameDataFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text("Loading Game Data"),
                  );
                } else {
                  Map? race = getObjectByAttribute(snapshot.data["races"], localCharacter["race"], "name");
                  if(race == null) {
                    return const Text("No Race Information");
                  } else {
                    return Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SingleChildScrollView(
                            child: Text(race["description"]),
                          ),
                        ),
                      ),
                    );
                  }
                }
              }
            )
          ],
        );
      }
    },
  );
}
