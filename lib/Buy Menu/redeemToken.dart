import 'dart:convert';

import 'package:cms_for_real/main.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class RedeemToken extends StatefulWidget {
  final String playerId;
  final String characterId;
  final Map gameData;
  final Function mainSetState;
  final String listName;
  final String prettyName;
  const RedeemToken({Key? key, required this.playerId, required this.characterId, required this.gameData, required this.mainSetState, required this.listName, required this.prettyName}) : super(key: key);

  @override
  State<RedeemToken> createState() => _RedeemTokenState();
}

TextEditingController tokenController = TextEditingController();

class _RedeemTokenState extends State<RedeemToken> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redeem Token"),
      ),
      body: Column(
        children: [
          TextField(
            textAlign: TextAlign.center,
            controller: tokenController,
            maxLines: 1,
            maxLength: 10,
          ),
          ElevatedButton(
            onPressed: () async {
              http.Response response = await webRequest(true, "/redeemToken", {"playerId": widget.playerId, "characterId": widget.characterId, "UID": tokenController.text});
              //log(response.toString());
              if(response.statusCode != 200) {
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("Try again"),
                  content: const Text("Invalid Token"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
                  ],
                ));
              } else {
                Map? finalResponse = jsonDecode(utf8.decode(response.bodyBytes));
                finalResponse ??= {"Name": "Unknown", "TokenAmount": "N/A"};
                if(finalResponse["Type"] == 0) {
                  showDialog(context: context, builder: (context) => AlertDialog(
                    title: const Text("YAY!"),
                    content: Text("You have redeem a token that grants: \n${finalResponse!["Name"]}: ${finalResponse["TokenAmount"].toString()}"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
                    ],
                  ));
                }
              }
            },
            child: const Text("Redeem"))
        ],
      )
    );
  }
}