import 'dart:developer';

import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

/*
class BackstoryTab extends StatelessWidget {
  //const BackstoryTab({Key? key}) : super(key: key);

  BackstoryTab({super.key}) {
    getBackStory();
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
          Padding(padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
          child: Column(
            children: [
              TextField(
                controller: backstoryController,
                keyboardType: TextInputType.multiline,
                maxLines: 25
              ),
              const Padding(padding: EdgeInsets.fromLTRB(10, 0, 30, 0),
                child: TextButton(onPressed: updateBackStory,
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.black54)
                ),
                  child: Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  void getBackStory() async {
    var localPlayerData = await playerDataFuture;
    backstoryController.text = getCharacterByName(localPlayerData, selectedCharacter)["backstory"];
  }

}*/

ListView BackstoryTab(BuildContext context, Function mainSetState, {String? listName}) {
  getBackStory(playerDataFuture);
  return ListView(
    children: [
      Padding(padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
        child: Column(
          children: [
            TextField(
                decoration: const InputDecoration(
                  hintText: "Not the creative type, huh?",
                  filled: true,
                  fillColor: Colors.black12,
                ),
                controller: backstoryController,
                keyboardType: TextInputType.multiline,
                maxLines: 25
            ),
            Padding(padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
              child: TextButton(onPressed: () {
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("Sure?"),
                  content: const Text("Are you sure you want to update your backstory\nChanging the past is dangerous, don't you know?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Too scary")),
                    TextButton(onPressed: () {updateBackStory(playerDataFuture);}, child: Text("I'm brave"))
                  ],
                ));
              },
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.black54)
                ),
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

void getBackStory(Future playerDataFuture) async {
  var localPlayerData = await playerDataFuture;
  Map? localCharacter = getObjectByAttribute(localPlayerData!["characters"], selectedCharacter, "id");
  if(localCharacter == null) {
    backstoryController.text = "Could not find Character";
  } else {
    backstoryController.text = localCharacter!["backstory"] ?? "";
  }
}

void updateBackStory(Future playerDataFuture) async {
  var playerId = (await playerDataFuture)!["playerInfo"]["id"];
  Map requestObj = {
    "id": playerId,
    "trait": "backstory",
    "data": backstoryController.text,
    "characterName": selectedCharacter
  };
  //log(requestObj.toString());
  var response = await webRequest(true, "client/cms/changeCharacterTrait", requestObj);
  if(response["statusCode"] == 200) {
    showToast("Updated Backstory");
  }
}

TextEditingController backstoryController = TextEditingController();