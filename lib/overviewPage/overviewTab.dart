import 'dart:developer';
import 'package:flutter/material.dart';
import '../main.dart';

/*Layout Variables*/
const double imageHeight = 100;
const double padding = 5;

FutureBuilder OverviewTab() {
  return FutureBuilder(
      future: playerDataFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Text("Loading Data..."),
              ],
            ),
          );
        } else {
          Map? localCharacter = getObjectByAttribute(snapshot.data["characters"], selectedCharacter, "id");
          //log(localCharacter.toString());
          //log((localCharacter!.containsKey("image")).toString());
          if(localCharacter == null) {
            return const Center(
              child: Text("Could not find Character"),
            );
          }
          return FutureBuilder(
            future: compiledCharacterFuture,
            builder: (BuildContext context, AsyncSnapshot character) {
              if(character.connectionState != ConnectionState.done) {
                return Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Compiling Data..."),
                    ],
                  ),
                );
              } else {

                return ListView(
                  children: [
                    Card(
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: padding, horizontal: padding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    !localCharacter.containsKey("image")
                                        ? Image.network("https://gildasclubgr.org/wp-content/uploads/2019/02/no-image.jpg", height: imageHeight,)
                                        : Image.network(
                                          localCharacter["image"],
                                          height: imageHeight,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: padding, horizontal: padding),
                                        child: FutureBuilder(
                                          future: gameDataFuture,
                                          builder: (BuildContext context, AsyncSnapshot gameInfoSnapshot) {
                                            if(gameInfoSnapshot.connectionState != ConnectionState.done) {
                                              return const Text("Loading GameInfo");
                                            } else {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: getStatsWidgets(localCharacter, gameInfoSnapshot.data),
                                              );
                                            }
                                          },
                                        )

                                    ),

                                  ],
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          const Text("XP"),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                            child: localCharacter.containsKey("xpArr") ? GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: localCharacter["xpArr"].length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Card(
                                        color: Colors.greenAccent,
                                        shape: BeveledRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        semanticContainer: false,
                                        child: GridTile(
                                          child: Center(
                                              child: Text(localCharacter["xpArr"][index]["value"].toString(), textScaleFactor: 1.25)
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(localCharacter["xpArr"][index]['name'],),
                                      ),
                                    ],
                                  );
                                })
                                : Container()
                          ),
                        ],
                      )
                    ),
                    Card(
                      child: Column(
                        children: [
                          const Text("Valutas"),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                            child: localCharacter.containsKey("valutas") ? GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: localCharacter["valutas"].length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 50,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1.25 / 1,
                                        child: Card(
                                          color: Colors.yellow,
                                          shape: BeveledRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          semanticContainer: true,
                                          child: GridTile(
                                            child: Center(
                                                child: Text(localCharacter["valutas"][index]["value"].toString(), textScaleFactor: 1.5)
                                            ), //just for testing, will fill with image later
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(localCharacter["valutas"][index]['name'],),
                                      ),
                                    ],
                                  );
                                })
                                : Container()
                          )
                        ],
                      ),
                    )
                  ],
                );
              }
            }
          );
        }
      }
  );
}

List<Widget> getStatsWidgets(localCharacter, gameInfo) {
  Map? raceObj = getObjectByUID(gameInfo, localCharacter["race"]);
  raceObj ??= {"Name": "Race not found"};

  if((localCharacter["stats"] == null || localCharacter["stats"].length < 1) && localCharacter['race'] == null) {
    return const [Text("No Stats")];
  } else if(localCharacter["stats"] == null || localCharacter["stats"].length < 1) {
    return [Text('Race: ' +  raceObj["Name"])];
  }


  List<Widget> widgets = [Text('Race: ' +  raceObj["Name"])];
  for(int i = 0; i < localCharacter["stats"].length; i++) {
    //log(localCharacter["stats"].toString());
    widgets.add(Text(localCharacter["stats"][i]["name"] + ": " + localCharacter["stats"][i]["value"].toString()));
  }
  return widgets;
}