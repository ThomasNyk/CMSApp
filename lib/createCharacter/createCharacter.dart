import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateCharacter extends StatefulWidget {
  const CreateCharacter({Key? key}) : super(key: key);

  @override
  State<CreateCharacter> createState() => _CreateCharacterState();
}

class _CreateCharacterState extends State<CreateCharacter> {

  List<TextEditingController> controllers = [];
  final ImagePicker _picker = ImagePicker();
  XFile? image;

  final Completer<XFile> imageCompleter = Completer();
  StreamController imageStream = StreamController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new Character"),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: gameDataFuture,
              builder: (BuildContext context, AsyncSnapshot gameInfo) {
                if (gameInfo.connectionState != ConnectionState.done) {
                  return Center(
                    child: Column(
                      children: const [
                        CircularProgressIndicator(),
                        Text("Loading GameData"),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: createRows(gameInfo),
                  );
                }
              },
            ),
          )
      ),
    );
  }


  List<Widget> createRows(dynamic gameInfo) {
    List<Widget> rowList = [];

    rowList.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Image"),
        Expanded(
          child: StreamBuilder(
            stream: imageStream.stream,
            builder: (BuildContext context, AsyncSnapshot imageSnapshot) {
              if(!imageSnapshot.hasData) {
                return TextButton(
                  child: const Text("Upload"),
                  onPressed: () async {
                    image = await pickImage();
                    setState(() {
                      imageStream.add(image);
                    });
                  }
                );
              } else {
                return SizedBox(
                  height: 200,
                  child: GestureDetector(
                    onTap: () async {
                      image = await pickImage();
                      setState(() {
                        imageStream.add(image);
                      });
                    },
                    child: Image.file(
                        File(image!.path)
                    ),
                  ),
                );
              }
            },
          ),
        )
      ],
    ));

    rowList.add(createRowAndController("Name*"));

    rowList.add(createDropDownSelectorRow("Race*", gameInfo.data["RacList"]));

    rowList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              if(controllers[0].text == "" || selectedRace == null) {
                showToast("You have not filled out all required fields");
              } else {
                Map obj = {
                  "id": (ModalRoute.of(context)!.settings.arguments as idCarrier).id,
                  "name": controllers[0].text,
                  "race": selectedRace,
                };
                webRequest(true, "newCharacter", obj).then((value) {
                  Navigator.pop(context, obj);
                }).catchError((e) {
                  log(e.toString());
                  showToast(e.toString());
                });
              }
            },
            child: const Text("Save"))
        ],
      )
    );

    rowList.add(
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [Text("*Required", style: TextStyle(color: Colors.grey),)]
        )
    );

    return rowList;
  }

  String? selectedRace;
  Row createDropDownSelectorRow(String text, List<dynamic> names) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        DropdownButton(
          alignment: Alignment.centerRight,
          value: selectedRace,
          onChanged: (value) => setState(() => {
            selectedRace = value,
          }),
          items: getDropDownItems(names),
        ),

      ],
    );
  }

  List<DropdownMenuItem> getDropDownItems(List<dynamic> names) {
    List<DropdownMenuItem> items = [];
    for(dynamic name in names) {
      //log(name["UID"].toString());
      items.add(DropdownMenuItem(
        value: name["UID"].toString(),
        child: Text(
          name["Name"].toString(),
        ),
      ));
    }
    return items;
  }

  Future<XFile?> pickImage() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 2000,
      maxWidth: 2000,
    );
  }

  int i = 0;
  Row createRowAndController(String text) {
    controllers.add(TextEditingController());
    return createRow(text, controllers[i]);
  }

  Row createRow(String name, TextEditingController controller) {
    return Row(
      children: [
        Text(name),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: TextField(
              controller: controller,
            ),
          ),
        ),
      ],
    );
  }
}