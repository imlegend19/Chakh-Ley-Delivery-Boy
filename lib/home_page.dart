import 'dart:async';

import 'package:chakh_ley_delivery_boy/pages/order_page.dart';
import 'package:chakh_ley_delivery_boy/static_variables/no_internet.dart';
import 'package:chakh_ley_delivery_boy/static_variables/static_variables.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'fragments/order_station.dart';
import 'models/user_pref.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  final drawerItems = [
    DrawerItem("Delivery Boys", Icons.directions_bike),
    DrawerItem("Delivered", Icons.airplanemode_active),
    DrawerItem("Logout", Icons.power_settings_new)
  ];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();

    connectivity = Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      ConstantVariables.connectionStatus = result;
      if (result == ConnectivityResult.none) {
        setState(() {});
      } else if ((result == ConnectivityResult.mobile) ||
          (result == ConnectivityResult.wifi)) {
        setState(() {});
      }
    });
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return OrderStation();
        break;
      case 1:
        return OrderPage(
            status: 'D',
            deliveryBoy: int.parse(ConstantVariables.user["id"]) ,
                );
      case 2:
        logoutUser().then((val) {
          Navigator.pushReplacementNamed(context, '/loginpage');
        });
        break;
      default:
        return Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      if (d.title == "Logout") {
        drawerOptions.add(
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Container(
              width: 200,
              child: Divider(
                color: Colors.grey,
                height: 2.0,
              ),
            ),
          ),
        );
      }
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.dehaze),
                onPressed: () => _scaffoldKey.currentState.openDrawer()),
            Text(widget.drawerItems[_selectedDrawerIndex].title),
          ],
        ),
        titleSpacing: 1,
        automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                ),
                accountName:
                    Text(ConstantVariables.user['name'] ?? '---no name---'),
                accountEmail: ConstantVariables.user['email'] == null
                    ? Text("-- no email provided --")
                    : Text(ConstantVariables.user['email'])),
            Column(children: drawerOptions)
          ],
        ),
      ),
      body: ConstantVariables.connectionStatus == ConnectivityResult.none
          ? buildNoInternet(context)
          : _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}
