import 'dart:async';

import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:win_marketplace_tech/pages/Product/ProductDetailsPage.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';

import '../../services/ContractFactoryServies.dart';
import '../../widgets/CustomButtonWidget.dart';
import '../Profile/ProfileOtherPage.dart';

class BidsDetails extends StatefulWidget {
  const BidsDetails({Key? key, required this.bidKey}) : super(key: key);

  final String bidKey;

  @override
  State<BidsDetails> createState() => _BidsDetailsState();
}

class _BidsDetailsState extends State<BidsDetails> {
  late String idProduct = '';
  late String time = '';
  late String currentPrice = '';
  late String currentAuthor = '';
  late String name;
  late String description;
  late String image;
  late String qr;
  late String category;
  late String time_start;
  late String time_end = '';
  late DatabaseReference dbRef;

  int _secondsRemaining = 0;
  Timer? _timer;
  bool settime = false;

  bool place = false;
  TextEditingController timeController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  late Timer timer;

  late final ContractFactoryServies _contractFactoryServies =
      ContractFactoryServies();

  bool _dataLoaded = false;
  late int newprice;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Bids');
    getBidData();
    startTimer();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  bool isValidUrl(String url) {
    final RegExp urlRegExp = RegExp(
      r'^(http|https):\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegExp.hasMatch(url);
  }

  void addTransaction(
      String name_trans,
      String from,
      String to,
      String private_key,
      String name_product,
      String price,
      String description,
      String desprivate,
      String category,
      String image,
      String qr,
      String link,
      String value,
      String accept,
      String resolve) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('HH:mm:ss dd-MM-yyyy').format(now);
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('Transactions');
    Map<String, String> transaction = {
      'name_trans': name_trans,
      'from': from,
      'to': to,
      'private_key': private_key,
      'name_product': name_product,
      'price': price,
      'description': description,
      'desprivate': desprivate,
      'category': category,
      'image': image,
      'qr': qr,
      'link': link,
      'value': value,
      'accept': accept,
      'resolve': resolve,
      'time': formattedDate,
    };

    dbRef.push().set(transaction);
  }

  Future<void> getBidData() async {
    DataSnapshot snapshot = await dbRef.child(widget.bidKey).get();
    Map? bid = snapshot.value as Map?;
    if (bid != null) {
      setState(() {
        idProduct = bid['id_product'] ?? '';
        time = bid['time'] ?? '';
        currentPrice = bid['current_price'] ?? '';
        currentAuthor = bid['current_author'] ?? '';
        // Bổ sung các tham số còn thiếu
        name = bid['name'] ?? '';
        description = bid['description'] ?? '';
        image = bid['image'] ?? '';
        qr = bid['qr'] ?? '';
        category = bid['category'] ?? '';
        // Thêm tham số time_start và time_end
        time_start = bid['time_start'] ?? '';
        time_end = bid['time_end'] ?? '';
      });
      setState(() {});
    }
  }

  Future<void> updateBidData(String price, String account) async {
    Map<String, String> bid = {
      'id_product': idProduct,
      'name': name,
      'description': description,
      'image': image,
      'qr': qr,
      'category': category,
      'time': time,
      'time_start': time_start,
      'time_end': time_end,
      'current_price': price,
      'current_author': account,
    };
    await dbRef.child(widget.bidKey).update(bid).then((value) {});
    setState(() {
      getBidData();
    });
  }

  Constants constants = Constants();

  @override
  Widget build(BuildContext context) {
    if (time_end.isEmpty) {
      return CircularProgressIndicator();
    }

    var contractFactory = Provider.of<ContractFactoryServies>(context);
    DateTime now = DateTime.now();
    DateTime endTime = DateFormat('HH:mm:ss dd-MM-yyyy').parse(time_end);
    Duration difference = endTime.difference(now);
    String timeDifference = _formatDuration(difference);
    return Scaffold(
      appBar: AppBar(
        title: Text('# ' + idProduct),
        backgroundColor: constants.brandColor,
      ),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.40,
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                        scale: 1)),
              ),
              (DateTime.now().isBefore(endTime))
                  ? Positioned(
                      left: 15.0,
                      bottom: 20,
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Bidding Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              (DateTime.now().isBefore(endTime))
                  ? Positioned(
                      right: 10.0,
                      bottom: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.0),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 110,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  timeDifference,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Container(
            color: constants.mainBlackColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gamepad_rounded,
                            color: constants.mainYellowColor,
                            size: 40,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
                          children: [
                            Text(
                              "Category",
                              style:
                                  TextStyle(color: constants.mainYellowColor),
                            ),
                            Text(
                              category,
                              style: TextStyle(
                                  color: constants.mainWhiteGColor,
                                  fontSize: 20),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      print("WILL OPEN ETHERSCAN");
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          color: constants.mainYellowColor,
                          size: 40,
                        ),
                        currentPrice.length > 3
                            ? Text(
                                " " + currentPrice + " ETH",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              )
                            : Text(
                                " " + currentPrice + " ETH",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 8, bottom: 8),
            child: Text(
              "Description",
              style: TextStyle(
                  color: constants.mainBlackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18.0, left: 18),
            child: Text(
              description,
              style: TextStyle(
                  color: constants.mainBlackColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 15),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18.0, left: 18),
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(qr),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () async {
                print(contractFactory.oneProducts.length);
                print(contractFactory.oneProducts[0].owner);
                await contractFactory.getOneProducts(idProduct);
                print(contractFactory.oneProduct?.owner.toString());
                // await contractFactory.getOneProducts(idProduct);
                // await contractFactory.getUserOtherProducts(currentAuthor);
                // Navigator.push(context, MaterialPageRoute(builder: (context)
                // => ProfileOther(account: currentAuthor,)));
              },
              child: Container(
                color: constants.mainWhiteGColor,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          RandomAvatar(currentAuthor, height: 50, width: 50)
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Author",
                              style: TextStyle(color: constants.mainBlackColor),
                            ),
                            Text(
                              currentAuthor,
                              style: TextStyle(
                                  color: constants.mainGrayColor, fontSize: 10),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (!DateTime.now().isBefore(endTime))
                  ? customButtonWidget(() {}, 15, constants.brandColor,
                      "End of auction session", constants.mainWhiteGColor, 300)
                  : customButtonWidget(() async {
                      showDialog(
                        context: context,
                        builder: (context) => CallDialogSetPrice(
                            onPressed: (value, privatekey) async {
                          newprice = (double.parse(value) * 1000000000).toInt();
                          if (double.parse(value) <
                              double.parse(currentPrice)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                      'The amount must be higher than the current price.'),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                            );
                          } else if (double.parse(value) * 1.02 >
                              double.parse(
                                  contractFactory.w3mService.chainBalance)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text('Insufficient balance.'),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                            );
                          } else {
                            print('ok');
                            await contractFactory.sendToken(
                                privatekey,
                                contractFactory.w3mService.session!.address
                                    .toString(),
                                constants.ADMIN_ADDRESS,
                                BigInt.parse(newprice.toString()));
                            if (isValidUrl(contractFactory.resultSend)) {
                              print('ok1');
                              int oldprice =
                                  (double.parse(currentPrice) * 1000000000)
                                      .toInt();
                              await contractFactory.sendToken(
                                  constants.PRIVATE_KEY,
                                  constants.ADMIN_ADDRESS,
                                  currentAuthor,
                                  BigInt.parse(oldprice.toString()));
                              await updateBidData(
                                  value,
                                  _contractFactoryServies
                                      .w3mService.session!.address
                                      .toString());
                              setState(() {});
                              addTransaction(
                                  'Place Bid',
                                  contractFactory.w3mService.session!.address
                                      .toString(),
                                  constants.ADMIN_ADDRESS,
                                  '',
                                  name,
                                  '',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '',
                                  contractFactory.resultSend,
                                  value,
                                  '1',
                                  '1');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    backgroundColor: constants.brandColor,
                                    content: Text('Successful.'),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text('Transaction failed'),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                              );
                            }
                          }
                          // {
                          //   newprice =
                          //       (double.parse(value) * 1000000000).toInt();
                          //   await contractFactory.sendToken(
                          //       privatekey,
                          //       contractFactory.w3mService.session!.address
                          //           .toString(),
                          //       constants.ADMIN_ADDRESS,
                          //       BigInt.parse(newprice.toString()));
                          //
                        }
                            // {
                            //   if (double.parse(value) <
                            //       double.parse(currentPrice)) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //           backgroundColor: Colors.redAccent,
                            //           content: Text(
                            //               'The amount must be higher than the current price.'),
                            //           shape: RoundedRectangleBorder(
                            //               borderRadius: BorderRadius.circular(10.0))),
                            //     );
                            //   } else if (double.parse(value) * 1.02 >
                            //       double.parse(contractFactory
                            //           .w3mService.chainBalance)) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //           backgroundColor: Colors.redAccent,
                            //           content: Text('Insufficient balance.'),
                            //           shape: RoundedRectangleBorder(
                            //               borderRadius: BorderRadius.circular(10.0))),
                            //     );
                            //   }
                            //   else {
                            //     TextEditingController privateKeyController = TextEditingController();
                            //       await showDialog(
                            //         context: context,
                            //         builder: (BuildContext context) {
                            //           return AlertDialog(
                            //             title: Text('Enter Private Key'),
                            //             content: TextField(
                            //               controller: privateKeyController,
                            //               decoration: InputDecoration(
                            //                   hintText: 'Enter private key'),
                            //             ),
                            //             actions: <Widget>[
                            //               TextButton(
                            //                 child: Text('Cancel'),
                            //                 onPressed: () {
                            //                   Navigator.of(context).pop();
                            //                 },
                            //               ),
                            //               TextButton(
                            //                 child: Text('Confirm'),
                            //                 onPressed: () async {
                            //                   String privateKey =
                            //                       privateKeyController.text;
                            //                     newprice =
                            //                         (double.parse(value) *
                            //                                 1000000000)
                            //                             .toInt();
                            //                     await contractFactory.sendToken(
                            //                         privateKey,
                            //                         contractFactory
                            //                             .w3mService.session!.address
                            //                             .toString(),
                            //                         constants.ADMIN_ADDRESS,
                            //                         BigInt.parse(
                            //                             newprice.toString()));
                            //                 },
                            //               ),
                            //             ],
                            //           );
                            //         },
                            //       );
                            //       if (isValidUrl(contractFactory.resultSell)) {
                            //         int oldprice = (double.parse(currentPrice)*1000000000).toInt();
                            //         await contractFactory.sendToken(constants.PRIVATE_KEY, constants.ADMIN_ADDRESS, contractFactory.w3mService.session!.address.toString(), BigInt.parse(oldprice.toString()));
                            //         await updateBidData(
                            //             value, _contractFactoryServies.w3mService.session!.address.toString());
                            //         addTransaction(
                            //             'Place Bid',
                            //             contractFactory
                            //                 .w3mService.session!.address
                            //                 .toString(),
                            //             constants.ADMIN_ADDRESS,
                            //             '',
                            //             name,
                            //             '',
                            //             '',
                            //             '',
                            //             '',
                            //             '',
                            //             '',
                            //             contractFactory.resultSend,
                            //             value,
                            //             '1',
                            //             '1');
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           SnackBar(
                            //               backgroundColor: constants.brandColor,
                            //               content: Text('Successful.'),
                            //               shape: RoundedRectangleBorder(
                            //                   borderRadius:
                            //                       BorderRadius.circular(10.0))),
                            //         );
                            //       } else {
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           SnackBar(
                            //               backgroundColor: Colors.redAccent,
                            //               content: Text('Transaction failed'),
                            //               shape: RoundedRectangleBorder(
                            //                   borderRadius:
                            //                       BorderRadius.circular(10.0))),
                            //         );
                            //       }
                            //   }
                            // }
                            ),
                      );
                    }, 15, constants.brandColor, "PLACE BID NOW",
                      constants.mainWhiteGColor, 150)
            ],
          ),
        ],
      )),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _fetchData();
      _dataLoaded = true;
    }
  }

  Future<void> _fetchData() async {
    await _contractFactoryServies.getOneProducts(idProduct);
    await getBidData();
    print(_contractFactoryServies.oneProducts.length);
    setState(() {
      _dataLoaded = true;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:${twoDigitMinutes}:${twoDigitSeconds}";
  }
}

// class CallDialog extends StatefulWidget {
//   final Function(String) onPressed;
//
//   CallDialog({required this.onPressed});
//
//   @override
//   _CallDialogState createState() => _CallDialogState();
// }
//
// class _CallDialogState extends State<CallDialog> {
//   final TextEditingController _textEditingController = TextEditingController();
//   Constants constants = Constants();
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Set time bid'),
//       content: TextField(
//         controller: _textEditingController,
//         decoration: InputDecoration(
//           hintText: 'Enter your time (s)',
//         ),
//       ),
//       actions: [
//         Container(
//           width: 80,
//           decoration: BoxDecoration(
//             color: constants.mainGrayColor,
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           child: TextButton(
//             onPressed: () {
//               String message = "0";
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//         Container(
//           width: 80,
//           decoration: BoxDecoration(
//             color: constants.brandColor,
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           child: TextButton(
//             onPressed: () {
//               String message = _textEditingController.text;
//               widget.onPressed(message);
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               'Set time',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class CallDialogSetPrice extends StatefulWidget {
  final Function(String, String) onPressed;

  CallDialogSetPrice({required this.onPressed});

  @override
  _CallDialogSetPriceState createState() => _CallDialogSetPriceState();
}

class _CallDialogSetPriceState extends State<CallDialogSetPrice> {
  final TextEditingController _priceTextEditingController =
      TextEditingController();
  final TextEditingController _privateKeyTextEditingController =
      TextEditingController();
  Constants constants = Constants();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Submit bid'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _priceTextEditingController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter your price (ETH)',
            ),
            onSubmitted: (_) => _submit(),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _privateKeyTextEditingController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your private key',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: constants.mainGrayColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: constants.brandColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextButton(
            onPressed: _submit,
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    String price = _priceTextEditingController.text;
    String privateKey = _privateKeyTextEditingController.text;

    if (_isValidPrice(price) && _isValidPrivateKey(privateKey)) {
      widget.onPressed(price, privateKey);
      Navigator.of(context).pop();
    } else {
      // Hiển thị thông báo yêu cầu nhập lại
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid value'),
          content: Text('Please enter valid price and private key.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  bool _isValidPrice(String price) {
    return double.tryParse(price) != null && double.parse(price) != 0;
  }

  bool _isValidPrivateKey(String privateKey) {
    // Đây chỉ là một ví dụ đơn giản, bạn có thể thêm các điều kiện kiểm tra khác nếu cần thiết
    return privateKey.isNotEmpty;
  }
}
