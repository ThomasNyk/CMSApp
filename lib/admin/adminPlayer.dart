import 'dart:developer';

import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

import 'adminCharacter.dart';

late Future adminPlayer;



class PlayerView extends StatelessWidget {
  final String playerId;
  const PlayerView({Key? key, required this.playerId}) : super(key: key);

  Future<Map> getAdminPlayerDataFuture(String playerId) async {
    Map response = await jsonDecodeFutureMap(webRequest(true, "/client/cms/playerData", {"id": playerId}));
    //return Future.value(response);
    return Future.value(response);
  }

  @override
  Widget build(BuildContext context) {
    adminPlayer = getAdminPlayerDataFuture(playerId);
    return FutureBuilder(
        future: adminPlayer,
        builder: (BuildContext context, AsyncSnapshot playerDataSnapshot) {
          if(playerDataSnapshot.connectionState != ConnectionState.done) {
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
            return Scaffold(
              appBar: AppBar(
                title: Text(playerDataSnapshot.data["playerInfo"]["name"]),
              ),
              body: Padding(
                padding: const EdgeInsets.only(left: 5, top: 10, right: 5),
                child: ListView.builder(
                  itemCount: playerDataSnapshot.data["characters"].length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCharacter(
                            playerId: playerDataSnapshot.data["playerInfo"]["id"],
                            characterId: playerDataSnapshot.data["characters"][index]["id"])));
                      },
                      child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Text(playerDataSnapshot.data["characters"][index]["name"]),
                          )
                      ),
                    );
                  }),
              )
            );
          }
        },
      );
  }
}