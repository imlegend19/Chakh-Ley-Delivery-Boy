import 'dart:async';

import 'package:chakh_ley_delivery_boy/entity/order.dart';
import 'package:chakh_ley_delivery_boy/static_variables/static_variables.dart';
import 'package:chakh_ley_delivery_boy/utils/color_loader.dart';
import 'package:chakh_ley_delivery_boy/utils/error_widget.dart';
import 'package:chakh_ley_delivery_boy/utils/order_card.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();

  final String status;
  final int deliveryBoy;

  OrderPage({@required this.status, @required this.deliveryBoy});
}

class _OrderPageState extends State<OrderPage> {
  StreamController _orderController;

  loadOrders() async {
    Future.sync(() {
      fetchOrderDeliveryBoy(widget.status, widget.deliveryBoy)
          .then((res) async {
        _orderController.add(res);
        return res;
      }).catchError((error) {
        _orderController = StreamController();
        loadOrders();
      });
    }).catchError((error) {
      _orderController = StreamController();
      loadOrders();
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
          if (response.data != null) {
            if (response.hasData) {
              if (response.data.count != 0) {
                return ListView.builder(
                  itemCount: response.data.count,
                  itemBuilder: (BuildContext context, int index) {
                    return orderCard(context, response.data.orders[index]);
                  },
                );
              } else {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No ${ConstantVariables.codeOrder[widget.status]} Orders Yet',
                        style: TextStyle(fontSize: 25.0),
                        maxLines: 3,
                      ),
                    ),
                  ),
                );
              }
            } else if (response.hasError) {
              return getErrorWidget(context);
            } else {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(child: ColorLoader()),
              );
            }
          } else {
            return Container(
              child: Center(child: ColorLoader()),
            );
          }
        },
      ),
    );
  }
}
