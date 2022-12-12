import 'dart:developer';

import 'package:flutter/material.dart';

import '../main.dart';

class tabItem {
  String title;
  Icon icon;

  tabItem(this.title, this.icon);
}

//Creates Bottom NavigationBarItemList according to a tabItem list
List<BottomNavigationBarItem> getBottomTabs(List<tabItem> tabs) {
  return tabs
      .map(
        (item) =>
        BottomNavigationBarItem(
          icon: item.icon,
          label: item.title,
        ),
  ).toList();
}

int currentIndex = 0;
Future<List<BottomNavigationBarItem>> getTabsFromData(selectedCharacter) async {
    Map? localPlayerData = await playerDataFuture;
    log("NavBar");
    log(localPlayerData.toString());
    Map? character = getObjectByAttribute(localPlayerData!["characters"], selectedCharacter, "id");
    if(character == null) {
      return Future.error("Could not find Character");
    }
    int index = 1;
    List<tabItem> bottomTabs = [tabItem(
        "Home",
        const Icon(Icons.home))];

    if(character["AbiList"] != null && character["AbiList"].isNotEmpty) {
      //log("Adding AbilityNavElement");
      bottomTabs.add(tabItem(
          "Abilities",
          const Icon(Icons.add_box)));
      tabIndexToNameMap[index] = 1;
      index++;
    }
    if(character["CarList"] != null) {
      bottomTabs.add(tabItem("Careers", const Icon(Icons.business)));
      tabIndexToNameMap[index] = 3;
      index++;
    }
    if(true || character["backstory"] != null) {
      bottomTabs.add(tabItem("Story", const Icon(Icons.hail)));
      tabIndexToNameMap[index] = 2;
      index++;
    }
    if(false && character["RacList"] != null && character["RacList"].isNotEmpty) {
      bottomTabs.add(tabItem("Race", const Icon(Icons.accessibility_new_sharp)));
      tabIndexToNameMap[index] = 4;
      index++;
    }
    if(character["RelList"] != null && character["RelList"].isNotEmpty) {
      bottomTabs.add(tabItem("Religion", const Icon(Icons.church)));
      tabIndexToNameMap[index] = 5;
      index++;
    }
    if(character["IteList"] != null && character["IteList"].isNotEmpty) {
      bottomTabs.add(tabItem("Items", const Icon(Icons.view_cozy)));
      tabIndexToNameMap[index] = 6;
      index++;
    }

    return Future.value(getBottomTabs(bottomTabs));
}