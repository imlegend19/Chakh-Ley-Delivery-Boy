import 'package:chakhle_delivery_boy/entity/order.dart';
import 'package:chakhle_delivery_boy/entity/transaction.dart';
import 'package:chakhle_delivery_boy/pages/transaction_page.dart';
import 'package:chakhle_delivery_boy/utils/basic_details_card.dart';
import 'package:chakhle_delivery_boy/utils/suborder.dart';
import 'package:flutter/material.dart';

class ViewDetails extends StatefulWidget {
  final Order order;
  ViewDetails({
    this.order,
  });

  @override
  _ViewDetailsState createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  TextEditingController _cancelMessage = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('View Details'),
          bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(
                tabs: [
                  Tab(text: 'Basic Information'),
                  Tab(text: 'SubOrders'),
                  Tab(text: 'Transaction'),
                ],
              ),
            ),
            preferredSize: Size(0.0, 50),
          ),
        ),
        body: TabBarView(
          children: [
            checkToCancel(),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                child: ListView.builder(
                  itemCount: widget.order.suborderSet.length,
                  itemBuilder: (BuildContext context, int index) {
                    return subOrderCard(context, widget.order, index);
                  },
                ),
              ),
            ),
            TransactionPage(
              transaction: fetchTransactions(widget.order.id.toString()),
              order: widget.order,
            )
          ],
        ),
      ),
    );
  }

  Widget addCancelOption(Order order, TextEditingController cancelledMessage) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        color: Colors.deepPurpleAccent,
        child: Text(
          'Cancel',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          patchOrder(order.id, 'C');
        },
      ),
    ));
  }

  Widget checkToCancel() {
    if (widget.order.status == "New" || widget.order.status == "Accepted") {
      return Column(
        children: <Widget>[
          Container(child: basicDetailsCard(widget.order)),
          Container(child: addCancelOption(widget.order, _cancelMessage))
        ],
      );
    } else {
      return Container(child: basicDetailsCard(widget.order));
    }
  }
}
