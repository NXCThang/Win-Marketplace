import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';

import '../../services/ContractFactoryServies.dart';
import '../../widgets/CustomButtonWidget.dart';

class TransactionsDetails extends StatefulWidget {
  const TransactionsDetails({Key? key, required this.transactionKey})
      : super(key: key);

  final String transactionKey;

  @override
  State<TransactionsDetails> createState() => _TransactionsDetailsState();
}

class _TransactionsDetailsState extends State<TransactionsDetails> {
  late String nameTransaction = '';
  late String from = '';
  late String to = '';
  late String name_product = '';
  late String price = '';
  late String description = '';
  late String desprivate = '';
  late String category = '';
  late String image = '';
  late String qr = '';
  late String time = ''; // Provide an initial value
  late String accept = '';
  late String resolve = '';
  late String privatekey = '';
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef =
        FirebaseDatabase.instance.ref().child('Transactions'); // Updated here
    getTransactionData();
  }

  bool isValidUrl(String url) {
    final RegExp urlRegExp = RegExp(
      r'^(http|https):\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegExp.hasMatch(url);
  }

  Future<void> getTransactionData() async {
    DataSnapshot snapshot = await dbRef.child(widget.transactionKey).get();
    Map? transaction = snapshot.value as Map?;
    if (transaction != null) {
      setState(() {
        nameTransaction = transaction['name_trans'] ?? '';
        time = transaction['time'] ?? '';
        from = transaction['from'] ?? '';
        to = transaction['to'] ?? '';
        name_product = transaction['name_product'] ?? '';
        price = transaction['price'] ?? '';
        description = transaction['description'] ?? '';
        desprivate = transaction['desprivate'] ?? '';
        category = transaction['category'] ?? '';
        image = transaction['image'] ?? '';
        qr = transaction['qr'] ?? '';
        accept = transaction['accept'] ?? '';
        resolve = transaction['resolve'] ?? '';
        privatekey = transaction['private_key'] ?? '';
      });
    }
  }

  Constants constants = Constants();

  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(nameTransaction),
        backgroundColor: constants.brandColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'From: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                from,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'To: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                to,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Time: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                time,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Name: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                name_product,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Price: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                price + ' ETH',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Description: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                description,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Private Description:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                desprivate,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Category: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Text(
                category,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Image: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: 200,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                            scale: 1)),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'QR: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: 200,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(qr),
                            fit: BoxFit.cover,
                            scale: 1)),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.6,
            ),
            (resolve == '0')
                ? (contractFactory.w3mService.session!.address ==
                        constants.ADMIN_ADDRESS)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          customButtonWidget(() async {
                            // Gọi hàm createProduct
                            await contractFactory.CreateProduct(
                              privatekey,
                              from,
                              name_product,
                              description,
                              desprivate,
                              image,
                              price,
                              category,
                              qr,
                            );

                            // Kiểm tra kết quả của hàm createProduct trước khi so sánh isValidUrl
                            if (contractFactory.resultCreate != null) {
                              // Nếu kết quả của hàm createProduct không null, thực hiện kiểm tra isValidUrl
                              if (isValidUrl(contractFactory.resultCreate)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: constants.brandColor,
                                    content: Text('Successful!!!'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                );
                                Map<String, String> transactions = {
                                  'name_trans': nameTransaction,
                                  'from': from,
                                  'to': to,
                                  'private_key': privatekey,
                                  'name_product': name_product,
                                  'price': price,
                                  'description': description,
                                  'desprivate': desprivate,
                                  'category': category,
                                  'image': image,
                                  'qr': qr,
                                  'accept': "1",
                                  'resolve': "1",
                                  'time': time,
                                  'value': '0',
                                  'link': contractFactory.resultCreate
                                };
                                dbRef
                                    .child(widget.transactionKey)
                                    .update(transactions)
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text('Transaction failed!!!'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                );
                                Map<String, String> transactions = {
                                  'name_trans': nameTransaction,
                                  'from': from,
                                  'to': to,
                                  'private_key': privatekey,
                                  'name_product': name_product,
                                  'price': price,
                                  'description': description,
                                  'desprivate': desprivate,
                                  'category': category,
                                  'image': image,
                                  'qr': qr,
                                  'accept': "0",
                                  'resolve': "1",
                                  'time': time,
                                  'value': '0',
                                  'link': ''
                                };
                                dbRef
                                    .child(widget.transactionKey)
                                    .update(transactions)
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              }
                            } else {
                              // Nếu kết quả của hàm createProduct là null, hiển thị thông báo lỗi
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text('Transaction failed!!!'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              );
                            }
                            setState(() {});
                          }, 15, Colors.green, "ACCEPT",
                              constants.mainWhiteGColor, 150),
                          SizedBox(
                            width: 50,
                          ),
                          customButtonWidget(() {
                            Map<String, String> transactions = {
                              'name_trans': nameTransaction,
                              'from': from,
                              'to': to,
                              'private_key': privatekey,
                              'name_product': name_product,
                              'price': price,
                              'description': description,
                              'desprivate': desprivate,
                              'category': category,
                              'image': image,
                              'qr': qr,
                              'accept': "0",
                              'resolve': "1",
                              'time': time,
                            };
                            dbRef
                                .child(widget.transactionKey)
                                .update(transactions)
                                .then((value) => {Navigator.pop(context)});
                            setState(() {});
                          }, 15, Colors.redAccent, "CANCEL",
                              constants.mainWhiteGColor, 150)
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            print(contractFactory.myAccount);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              customButtonWidget(() {}, 15, Colors.orangeAccent,
                                  'Processing...', Colors.white, 360)
                            ],
                          ),
                        ),
                      )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (accept == '1')
                            ? customButtonWidget(() {}, 15, Colors.green,
                                'Accepted', Colors.white, 360)
                            : customButtonWidget(() {}, 15, Colors.redAccent,
                                'Failed', Colors.white, 360)
                      ],
                    ),
                  ),
            // (contractFactory.myAccount == constants.ADMIN_ADDRESS)
            //         ? Padding(
            //             padding: const EdgeInsets.all(10.0),
            //             child: Padding(
            //               padding: const EdgeInsets.only(left: 10.0),
            //               child: Row(
            //                 children: [
            //                   customButtonWidget(() {
            //                     contractFactory.CreateProduct(
            //                         privatekey,
            //                         from,
            //                         name_product,
            //                         description,
            //                         desprivate,
            //                         image,
            //                         price,
            //                         category,
            //                         qr);
            //
            //                     ScaffoldMessenger.of(context).showSnackBar(
            //                       SnackBar(
            //                           backgroundColor: Colors.grey[600],
            //                           content: Text(contractFactory.resultCreate),
            //                           shape: RoundedRectangleBorder(
            //                               borderRadius: BorderRadius.circular(10.0)
            //                           )
            //                       ),
            //                     );
            //                     Map<String, String> transactions = {
            //                       'name_trans': nameTransaction,
            //                       'from': from,
            //                       'to': to,
            //                       'private_key': privatekey,
            //                       'name_product': name_product,
            //                       'price': price,
            //                       'description': description,
            //                       'desprivate': desprivate,
            //                       'category': category,
            //                       'image': image,
            //                       'qr': qr,
            //                       'accept': "1",
            //                       'resolve': "1",
            //                       'time': time,
            //                     };
            //                     dbRef
            //                         .child(widget.transactionKey)
            //                         .update(transactions)
            //                         .then((value) => {Navigator.pop(context)});
            //                     setState(() {});
            //                   }, 15, Colors.green, "ACCECPT",
            //                       constants.mainWhiteGColor, 150),
            //                   SizedBox(
            //                     width: 50,
            //                   ),
            //                   customButtonWidget(() {
            //                     Map<String, String> transactions = {
            //                       'name_trans': nameTransaction,
            //                       'from': from,
            //                       'to': to,
            //                       'private_key': privatekey,
            //                       'name_product': name_product,
            //                       'price': price,
            //                       'description': description,
            //                       'desprivate': desprivate,
            //                       'category': category,
            //                       'image': image,
            //                       'qr': qr,
            //                       'accept': "0",
            //                       'resolve': "1",
            //                       'time': time,
            //                     };
            //                     dbRef
            //                         .child(widget.transactionKey)
            //                         .update(transactions)
            //                         .then((value) => {Navigator.pop(context)});
            //                     setState(() {});
            //                   }, 15, Colors.redAccent, "CANCEL",
            //                       constants.mainWhiteGColor, 150)
            //                 ],
            //               ),
            //             ),
            //           )
            //         : Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: GestureDetector(
            //               onTap: (){
            //                 print(contractFactory.myAccount);
            //               },
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 children: [
            //                   customButtonWidget(() {}, 15, Colors.orangeAccent,
            //                       'Processing...', Colors.white, 360)
            //                 ],
            //               ),
            //             ),
            //           )
            //     : Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             (accept == '1')
            //                 ? customButtonWidget(() {}, 15, Colors.green,
            //                     'Accepted', Colors.white, 360)
            //                 : customButtonWidget(() {}, 15, Colors.redAccent,
            //                     'Failed', Colors.white, 360)
            //           ],
            //         ),
            //       )
          ],
        ),
      ),
    );
  }
}
