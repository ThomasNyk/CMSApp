import 'dart:developer';
import 'dart:ffi';

import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'buyList.dart';

Map<String, int?> costSum = {};
List<TextEditingController> controllers = [];
bool localUpdate = false;

class ConfirmBuy extends StatefulWidget {
  const ConfirmBuy({Key? key}) : super(key: key);

  @override
  State<ConfirmBuy> createState() => _ConfirmBuyState();
}

class _ConfirmBuyState extends State<ConfirmBuy> {
  @override
  Widget build(BuildContext context) {
    if(!localUpdate) costSum = {};
    localUpdate = false;
    Map object = (ModalRoute.of(context)!.settings.arguments as BuyObjectCarrier).object;
    Map gameData = (ModalRoute.of(context)!.settings.arguments as BuyObjectCarrier).gameData;
    Map character = (ModalRoute.of(context)!.settings.arguments as BuyObjectCarrier).character;
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy ${object["Name"]}'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("This item costs ${(ModalRoute.of(context)!.settings.arguments as BuyObjectCarrier).discountCost}", style: const TextStyle(fontSize: 20)),
              const Text("How do you want to pay?", style: TextStyle(fontSize: 20)),
              Text("Total so far: ${getSum()}"),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: buildCostWidgetList(gameData, character, object, (ModalRoute.of(context)!.settings.arguments as BuyObjectCarrier).playerId, context, setState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int getSum() {
  int sum = 0;
  for(MapEntry<String, int?> entry in costSum.entries) {
    //log(entry.runtimeType.toString());
    int? temp = entry.value;
    temp ??= 0;
    sum += temp;
  }
  return sum;
}

List<Row> buildCostWidgetList(Map gameData, Map character, Map object, String playerId, BuildContext context, Function _setState) {
  List<Row> rowList = [];
  //log(ability.toString());
  int i = 0;
  for(String costTypeId in object["CostTypes"]) {
    if(controllers.length <= i) controllers.add(TextEditingController());
    Map? costType = getObjectByUID(gameData, costTypeId);
    if(costType == null) {
      rowList.add(Row(
        children: [
          Text("Cannot find costType: " + costTypeId),
        ],
      ));
    } else {
      TextEditingController tempController = controllers[i];
      rowList.add(Row(
        children: [
          Text(costType!["Name"]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 10),
              child: TextField(
                textAlign: TextAlign.center,
                maxLines: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: tempController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _setState(() {
                    localUpdate = true;
                    String temp = value;
                    if(temp == "") temp = "0";
                    if(int.parse(temp) > costType["Amount"]) {
                      value = costType["Amount"].toString();
                      temp = costType["Amount"].toString();
                    }
                      costSum[costTypeId] = int.parse(temp);
                      tempController.text = value;
                      tempController.selection = TextSelection.fromPosition(TextPosition(offset: tempController.text.length));
                  });
                },
              ),
            ),
          ),
        ],
      ));
    }
    i++;
  }
  rowList.add(Row(
    children: [
      Expanded(
        child: Center(
          child: ElevatedButton(
              onPressed: () async {
                if(getSum() == (ModalRoute.of(context)!.settings.arguments as BuyObjectCarrier).discountCost) {
                  Map obj = {
                    "playerId": playerId,
                    "characterId": character["id"],
                    "UID": object["UID"],
                    "costs": costSum,
                  };
                  Map response = await webRequest(true, "/buy", obj);
                  //log(response.toString());
                  if(response["statusCode"] == 200) {
                    showToast("Bought");
                  } else {
                    showToast("Failed to buy");
                  }
                  playerDataFuture = getPlayerDataFuture((ModalRoute.of(context)!.settings.arguments as BuyObjectCarrier).playerId);
                  Navigator.pop(context);
                } else {
                  showToast("Total must add up to Cost");
                }
              },
              child: const Text("Buy")),
        ),
      ),
    ],
  ));
  return rowList;
}