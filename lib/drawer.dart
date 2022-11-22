import 'package:flutter/material.dart';

import 'main.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 55.0,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.grey),
              margin: const EdgeInsets.all(0.0),
              padding: const EdgeInsets.all(0.0),
              child: Center(
                child:  Center(
                  child: Text('Buy'),
                ),
              ),
            ),
          ),
          StreamBuilder(
              stream: sidebarStream.stream,
              builder: (BuildContext context, AsyncSnapshot _snapshot) {
                if (!_snapshot.hasData) {
                  //log(_snapshot.toString());
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  //log(_snapshot.toString());
                  return RefreshIndicator(
                    onRefresh: () async => false,
                    child: ListView.builder(
                        itemCount: _snapshot.data.length + 1,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          if(index >= _snapshot.data.length){
                            return Center(
                              child: MaterialButton(
                                onPressed: () async => populateSidebar(playerDataFuture),
                                child: const Text("hello"),
                              ),
                            );
                          } else {
                            return sideBarItem(data: _snapshot.data[index]);
                          }
                        }
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
