import 'dart:async';

import 'package:chakhle_delivery_boy/entity/order.dart';
import 'package:chakhle_delivery_boy/static_variables/static_variables.dart';
import 'package:chakhle_delivery_boy/utils/color_loader.dart';
import 'package:chakhle_delivery_boy/utils/order_card.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();

  final String status;
  final int deliveryBoy;

  OrderPage({@required this.status,@required this.deliveryBoy});
}

class _OrderPageState extends State<OrderPage> {

  StreamController _orderController;

  loadOrders() async {
    fetchOrderDeliveryBoy(widget.status,widget.deliveryBoy).then((res) async {
      _orderController.add(res);
      return res;
    });
  }

  @override
  void initState() {
    super.initState();
    _orderController = StreamController();
    Timer.periodic(Duration(seconds: 3), (_) => loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _orderController.stream,
        builder: (context, response) {
          if(response.data != null) {
            if (response.hasData) {
              if (response.data.count != 0) {
                return ListView.builder(
                  itemCount: response.data.count,
                  itemBuilder: (BuildContext context, int index) {
                    return orderCard(context, response.data.orders[index]);
                  },
                );
              } else {
                return Center(
                  child: Container(
                      child: Text(
                        'No ${ConstantVariables.codeOrder[widget
                            .status]} Orders Yet',
                        style: TextStyle(fontSize: 30.0),
                      )),
                );
              }
            } else {
              return Container(
                child: Center(child: ColorLoader()),
              );
            }
          }else{
            return getErrorWidget(context);
          }
        },
      ),
    );
  }

  Widget getErrorWidget(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Color(0xfff1f2f6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image(
                image: AssetImage('assets/error.png'),
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            Text(
              "OOPS",
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w400,
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.84,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Sorry, something went wrong! A team of highly trained monkeys "
                    "has been dispatched to deal with this situation.",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.grey.shade500,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
