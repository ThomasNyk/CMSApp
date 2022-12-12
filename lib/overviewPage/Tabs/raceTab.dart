import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

Widget RaceTab(BuildContext context, Function mainSetState, {String? listName}) {
  return FutureBuilder(
    future: gameDataFuture,
    builder: (BuildContext context, AsyncSnapshot gameDataSnapshot) {
      if(gameDataSnapshot.connectionState != ConnectionState.done) {
        return Center(
          child: Column(
            children: const [
              CircularProgressIndicator(),
              Text("Loading Game data"),
            ],
          ),
        );
      } else {
        return FutureBuilder(
          future: compiledCharacterFuture,
          builder: (BuildContext context, AsyncSnapshot characterSnapshot) {
            if(characterSnapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Text("Loading Player Data"),
              );
            } else {
              if(compiledCharacterFuture == null) {
                return const Center(
                  child: Text("Could not find character"),
                );
              }
              Map? obj = getObjectByUID(gameDataSnapshot.data, characterSnapshot.data[listName][0]);
              if(obj == null) {
                return const Text("No Information Information");
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: Text(
                            obj["Name"],
                            style: const TextStyle(fontSize: 30),
                          ),
                        )
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SingleChildScrollView(
                            child: Text(obj["Description"]),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
          },
        );
      }
    },
  );
}
