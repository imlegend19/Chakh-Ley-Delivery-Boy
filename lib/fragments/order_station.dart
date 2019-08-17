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
          title: TabBar(
            tabs: [
              Tab(text: "Ongoing"),
              Tab(text: 'Delivered'),
            ],
            indicatorColor: Colors.white,
          ),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            OrderPage(status: "O",deliveryBoy: 2,),
            OrderPage(status: 'D',deliveryBoy: 2,),
          ],
        ),
      ),
    );
  }
}
