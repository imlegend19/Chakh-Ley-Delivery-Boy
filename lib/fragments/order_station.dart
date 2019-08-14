import 'package:chakhle_delivery_boy/entity/order.dart';
import 'package:chakhle_delivery_boy/pages/order_page.dart';
import 'package:flutter/material.dart';

class OrderStation extends StatefulWidget {
  @override
  _OrderStationState createState() => _OrderStationState();
}

class _OrderStationState extends State<OrderStation> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          actions: <Widget>[],
          title: TabBar(
            tabs: [
              Tab(text: "Ongoing"),
              Tab(text: 'Delivered'),
            ],
            indicatorColor: Colors.white,
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: [
            OrderPage(status: "O"),
            OrderPage(status:'D'),
          ],
        ),
      ),
    );
  }
}
