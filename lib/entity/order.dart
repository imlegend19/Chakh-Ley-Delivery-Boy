import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_static.dart';

class Order {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final Map<String, dynamic> restaurant;
  final String preparationTime;
  final String status;
  final String orderDate;
  final double total;
  final bool paymentDone;
  final List<dynamic> suborderSet;
  final Map<String, dynamic> delivery;

  Order({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.restaurant,
    this.preparationTime,
    this.status,
    this.orderDate,
    this.total,
    this.paymentDone,
    this.suborderSet,
    this.delivery,
  });
}

class GetOrders {
  List<Order> orders;
  int count;

  GetOrders({this.orders, this.count});

  factory GetOrders.fromJson(Map<String, dynamic> response) {
    List<Order> orders = [];
    int count = response[APIStatic.keyCount];

    List<dynamic> results = response[APIStatic.keyResult];

    for (int i = 0; i < results.length; i++) {
      Map<String, dynamic> jsonOrder = results[i];
      orders.add(
        Order(
          id: jsonOrder[APIStatic.keyID],
          name: jsonOrder[APIStatic.keyName],
          mobile: jsonOrder[RestaurantStatic.keyMobile],
          email: jsonOrder[RestaurantStatic.keyEmail],
          restaurant: jsonOrder[RestaurantStatic.keyRestaurant],
          preparationTime: jsonOrder[OrderStatic.keyPreparationTime],
          status: jsonOrder[OrderStatic.keyStatus],
          orderDate: jsonOrder[OrderStatic.keyOrderDate],
          total: jsonOrder[OrderStatic.keyTotal],
          paymentDone: jsonOrder[OrderStatic.keyPaymentDone],
          suborderSet: jsonOrder[OrderStatic.keySuborderSet],
          delivery: jsonOrder[OrderStatic.keyDelivery],
        ),
      );
    }

    count = orders.length;

    return GetOrders(orders: orders, count: count);
  }
}

Future<GetOrders> fetchOrder(String status) async {
  final response = await http.get(OrderStatic.keyOrderListURL + status);

  if (response.statusCode == 200) {
    int count = jsonDecode(response.body)[APIStatic.keyCount];
    int execute = count ~/ 10 + 1;

    GetOrders order = GetOrders.fromJson(jsonDecode(response.body));
    execute--;

    while (execute != 0) {
      GetOrders tempOrder = GetOrders.fromJson(jsonDecode(
          (await http.get(jsonDecode(response.body)[APIStatic.keyNext])).body));
      order.orders += tempOrder.orders;
      order.count += tempOrder.count;
      execute--;
    }

    return order;
  } else {
    throw Exception('Failed to load get');
  }
}