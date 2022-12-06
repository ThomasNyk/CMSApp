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
Future<List<BottomNavigationBarItem>> getTabsFromData(playerData, selectedCharacter) async {
    Map localPlayerData = await playerData;
    Map? character = getObjectByAttribute(localPlayerData["characters"], selectedCharacter, "id");
    if(character == null) {
      return Future.error("Could not find Character");
    }
    int index = 1;
    List<tabItem> bottomTabs = [tabItem(
        "Home",
        const Icon(Icons.home))];

    if(character["AbiList"] != null && character["AbiList"].isNotEmpty) {
      bottomTabs.add(tabItem(
          "Abilities",
          const Icon(Icons.add_box)));
      tabIndexToNameMap[index] = 1;
      index++;
    }
    if(character["backstory"] != null) {
      bottomTabs.add(tabItem("Backstory", const Icon(Icons.hail)));
      tabIndexToNameMap[index] = 2;
      index++;
    }
    if(character["careers"] != null) {
      bottomTabs.add(tabItem("Careers", const Icon(Icons.business)));
      tabIndexToNameMap[index] = 3;
      index++;
    }

    return Future.value(getBottomTabs(bottomTabs));
}