import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:win_marketplace_tech/pages/Transaction/TransactionsDetails.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  Query dbRef = FirebaseDatabase.instance.ref().child('Transactions');
  DatabaseReference reference =
  FirebaseDatabase.instance.ref().child('Transactinos');

  Widget listItem({required Map transaction}) {
    return GestureDetector(
      onTap: () {
        setState() {}
        ;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    TransactionsDetails(transactionKey: transaction['key'])));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xffbbdffb),
        ),
        margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        padding: const EdgeInsets.all(10),
        // color: constants.brandColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                (transaction['name_trans'] == 'Create Product')
                    ? Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.black45,
                )
                    : (transaction['name_trans'] == 'Sell Product')
                    ? Icon(Icons.sell_outlined, color: Colors.black45,)
                    :(transaction['name_trans'] == 'Delete Product')
                    ? Icon(Icons.delete_forever_outlined, color: Colors.black45,)
                    : (transaction['name_trans'] == 'Buy Product')
                    ? Icon(Icons.call_made, color: Colors.black45,)
                    : (transaction['name_trans'] == 'Place Bid')
                    ? Icon(Icons.gavel, color: Colors.black45,)
                    :Icon(Icons.not_interested),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction['name_trans']),
                        Text(transaction['time']),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text(transaction['price'] + ' ETH'),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: (transaction['resolve'] == '0')
                                ? Text(
                              'Processing...',
                              style:
                              TextStyle(color: Colors.orangeAccent),
                            )
                                : (transaction['accept'] == '1')
                                ? Text(
                              'Accepted',
                              style: TextStyle(color: Colors.green),
                            )
                                : Text(
                              'Failed',
                              style:
                              TextStyle(color: Colors.redAccent),
                            )),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: (transaction['resolve'] == '0')
                            ? Text(
                          'Processing...',
                          style:
                          TextStyle(color: Colors.orangeAccent),
                        )
                            : (transaction['accept'] == '1')
                            ? Text(
                          'Successful',
                          style: TextStyle(color: Colors.green),
                        )
                            : Text(
                          'Failed',
                          style:
                          TextStyle(color: Colors.redAccent),
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Constants constants = Constants();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: constants.brandColor,
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map transaction = snapshot.value as Map;
            transaction['key'] = snapshot.key;
            if (transaction['resolve'] == '0') {
              return listItem(transaction: transaction);
            } else {
              // Nếu không, trả về một widget trống để bỏ qua giao dịch
              return SizedBox();
            }
          },
        ),
      ),
    );
  }

}