import 'package:chakh_ley_delivery_boy/entity/order.dart';
import 'package:chakh_ley_delivery_boy/entity/transaction.dart';
import 'package:chakh_ley_delivery_boy/pages/transaction_post_page.dart';
import 'package:chakh_ley_delivery_boy/utils/color_loader.dart';
import 'package:chakh_ley_delivery_boy/utils/error_widget.dart';
import 'package:chakh_ley_delivery_boy/utils/transaction_saved_card.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();

  final Order order;
  final Future<GetTransactions> transaction;

  TransactionPage({
    @required this.transaction,
    @required this.order,
  });
}

class _TransactionPageState extends State<TransactionPage> {
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    paymentDoneCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: isVisible,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) =>
                  TransactionPostPage(order: widget.order))),
          child: Icon(Icons.add),
        ),
      ),
      body: FutureBuilder<GetTransactions>(
        future: widget.transaction,
        builder: (context, response) {
          if (response.hasData) {
            return ListView.builder(
              itemCount: response.data.count,
              itemBuilder: (BuildContext context, int index) {
                return transactionCard(
                    context, response.data.transactions[index]);
              },
            );
          } else if (response.hasError) {
            return getErrorWidget(context);
          } else {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: ColorLoader(),
              ),
            );
          }
        },
      ),
    );
  }

  void paymentDoneCheck() {
    if (widget.order.paymentDone == true) {
      isVisible = false;
    } else {
      isVisible = true;
    }
  }
}
