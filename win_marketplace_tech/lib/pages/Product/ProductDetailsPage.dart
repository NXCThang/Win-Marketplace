import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:win_marketplace_tech/pages/Calendar/BidDetails.dart';
import 'package:win_marketplace_tech/pages/Product/UpdateProduct.dart';
import 'package:win_marketplace_tech/pages/Profile/ProfileOtherPage.dart';
import 'package:win_marketplace_tech/pages/Profile/ProfilePage.dart';
import '../../services/ContractFactoryServies.dart';
import '../../services/Models/ProductModel.dart';
import '../../utils/Constants.dart';
import '../../widgets/CustomButtonWidget.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({required this.product, Key? key}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final ContractFactoryServies _contractFactoryServies =
      ContractFactoryServies();

  @override
  void initState() {
    print('Account' + _contractFactoryServies.myAccount.toString());
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Transactions');
    dbRef1 = FirebaseDatabase.instance.ref().child('Bids');
  }

  bool isValidUrl(String url) {
    final RegExp urlRegExp = RegExp(
      r'^(http|https):\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegExp.hasMatch(url);
  }

  Future<void> EndBid() async {
    String currentPrice = "";
    String currentAuthor = "";
    String key = "";
    bool _sendTokenCalled = false;
    DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Bids');

    bool _bidEnded = false; // Khởi tạo biến để kiểm tra endbid đã được thực hiện hay chưa

    _dbRef.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> values = snapshot.value as Map;
      if (values != null) {
        bool found = false;
        values.forEach((k, value) {
          if (!found && value['id_product'] == widget.product.id.toString()) {
            print(value['time_end']);
            print(value['current_price']);
            currentPrice =
                value['current_price'] ?? ""; // Gán giá trị mặc định ""
            currentAuthor =
                value['current_author'] ?? ""; // Gán giá trị mặc định ""
            key = k;
            found = true;
          }
        });
        late int newprice = (double.parse(currentPrice) * 1000000000).toInt();
        TextEditingController privateKeyController = TextEditingController();
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Enter Private Key'),
              content: TextField(
                controller: privateKeyController,
                decoration: InputDecoration(hintText: 'Enter private key'),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () async {
                    String privateKey = privateKeyController.text;
                    await _contractFactoryServies.EndBid(
                        privateKey,
                        _contractFactoryServies.w3mService.session!.address
                            .toString(),
                        widget.product.id,
                        currentPrice,
                        currentAuthor);

                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
        if (isValidUrl(_contractFactoryServies.endBid)) {
          if (!_bidEnded) { // Kiểm tra xem endbid đã được thực hiện hay chưa
            await _contractFactoryServies.sendToken(
                constants.PRIVATE_KEY,
                constants.ADMIN_ADDRESS,
                _contractFactoryServies.w3mService.session!.address.toString(),
                BigInt.parse(newprice.toString()));
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('HH:mm:ss dd-MM-yyyy').format(now);
            DatabaseReference dbRef =
            FirebaseDatabase.instance.ref().child('Bids');
            await dbRef.child(key).update({'time_end': formattedDate});
            addTransaction(
                'End Bid',
                constants.ADMIN_ADDRESS,
                _contractFactoryServies.w3mService.session!.address.toString(),
                '',
                widget.product.name,
                currentPrice,
                '',
                '',
                '',
                '',
                '',
                _contractFactoryServies.resultSend,
                currentPrice,
                '1',
                '1');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: constants.brandColor,
                  content: Text('Successful.'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
            );
            _bidEnded = true; // Đặt cờ để biết rằng endbid đã được thực hiện
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text('Transaction failed'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
          );
        }
      }
    });

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

  late DatabaseReference dbRef;
  late DatabaseReference dbRef1;
  late String convertedPrice =
      (double.parse(widget.product.price.toString()) / 1000000000).toString();
  late String fee =
      (double.parse(widget.product.price.toString()) / 1000000000 * 0.02)
          .toString();
  late int fee1 =
      (double.parse(widget.product.price.toString()) * 0.02).toInt();
  Constants constants = Constants();

  Future<void> _showPlaceBidDialog(BuildContext context) async {
    Map<String, String>? time = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => CallDialog(
        onPressed: (time) {
          Navigator.pop(context, time);
        },
      ),
    );
    if (time != null) {
      TextEditingController privateKeyController = TextEditingController();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Private Key'),
            content: TextField(
              controller: privateKeyController,
              decoration: InputDecoration(hintText: 'Enter private key'),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () async {
                  String privateKey = privateKeyController.text;
                  await _contractFactoryServies.BidProduct(
                      privateKey,
                      _contractFactoryServies.w3mService.session!.address
                          .toString(),
                      widget.product.id,
                      true);
                  _contractFactoryServies.sendToken(
                      privateKey,
                      _contractFactoryServies.w3mService.session!.address
                          .toString(),
                      constants.ADMIN_ADDRESS,
                      widget.product.price + BigInt.parse(fee1.toString()));
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      if (isValidUrl(_contractFactoryServies.resultBid)) {
        _addBidAndNavigate(context, time);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: constants.brandColor,
              content: Text('Successful!!!'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text('Transaction failed!!!'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        );
      }
    }
  }

  Future<void> _addBidAndNavigate(
      BuildContext context, Map<String, String> time) async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('HH:mm:ss dd-MM-yyyy').format(now);

      // Kiểm tra và xử lý giá trị null của time['hour']
      int hour = int.tryParse(time['hour']!) ?? 0;
      int minute = int.tryParse(time['minute']!) ?? 0;
      int second = int.tryParse(time['second']!) ?? 0;

      // Tính toán timeEnd chỉ khi giá trị không null
      if (hour != null && minute != null && second != null) {
        DateTime timeStart =
            DateFormat('HH:mm:ss dd-MM-yyyy').parse(formattedDate);
        DateTime timeEnd = timeStart
            .add(Duration(hours: hour, minutes: minute, seconds: second));

        // Format timeEnd to string
        String formattedEndTime =
            DateFormat('HH:mm:ss dd-MM-yyyy').format(timeEnd);

        // Tạo một bid mới với các giá trị cần thiết
        Map<String, String> bidData = {
          'id_product': widget.product.id.toString(),
          'name': widget.product.name.toString(),
          'description': widget.product.description,
          'image': widget.product.image,
          'qr': widget.product.qr,
          'category': widget.product.category,
          'time': time['hour']! + ':' + time['minute']! + ':' + time['second']!,
          'time_start': formattedDate,
          'time_end': formattedEndTime,
          'current_price': convertedPrice,
          'current_author': widget.product.owner.toString(),
        };
        DatabaseReference bidsRef =
            FirebaseDatabase.instance.ref().child('Bids');
        DatabaseReference newBidRef = bidsRef.push();
        await newBidRef.set(bidData);
        // Lấy key của bid vừa được tạo
        String bidKey = newBidRef.key ?? '';
        addTransaction(
            'Create Aution',
            _contractFactoryServies.w3mService.session!.address.toString(),
            constants.CONTRACT_ADDRESS,
            '',
            widget.product.name,
            convertedPrice,
            '',
            '',
            '',
            '',
            '',
            _contractFactoryServies.resultBid,
            fee,
            '1',
            '1');
        // Chuyển đến trang BidsDetails để hiển thị thông tin về bid vừa được tạo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BidsDetails(bidKey: bidKey),
          ),
        );
      } else {
        // Xử lý trường hợp giá trị null của time['hour']
        print('Invalid time value');
        // Hiển thị thông báo cho người dùng hoặc thực hiện hành động phù hợp khác
      }
    } catch (error) {
      print('Error adding bid: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    // var cutPrice = convertedPrice.toString().substring(0,6);
    return Scaffold(
      backgroundColor: constants.mainBGColor,
      appBar: AppBar(
        backgroundColor: constants.brandColor,
        elevation: 0,
        title: Center(
          child: Text(
            '#' + widget.product.id.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.40,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.product.image),
                      fit: BoxFit.cover,
                      scale: 1)),
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
                                widget.product.category,
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
                          convertedPrice.length > 3
                              ? Text(
                                  " ${convertedPrice.substring(0, 4)} ETH",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white),
                                )
                              : Text(
                                  " ${convertedPrice} ETH ",
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
                "Name",
                style: TextStyle(
                    color: constants.mainBlackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 18),
              child: Column(
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(
                        color: constants.mainBlackColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 15),
                    textAlign: TextAlign.justify,
                  ),
                ],
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
              child: Column(
                children: [
                  Text(
                    widget.product.description,
                    style: TextStyle(
                        color: constants.mainBlackColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 15),
                    textAlign: TextAlign.justify,
                  ),
                  widget.product.owner.toString() == contractFactory.myAccount
                      ? Text(
                          widget.product.desprivate,
                          style: TextStyle(
                              color: constants.mainBlackColor,
                              fontWeight: FontWeight.normal,
                              fontSize: 15),
                          textAlign: TextAlign.justify,
                        )
                      : SizedBox(),
                ],
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
                      image: NetworkImage(widget.product.qr),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () {
                  if (widget.product.owner.toString() ==
                      contractFactory.myAccount) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profile()));
                  } else {
                    contractFactory
                        .getUserOtherProducts(widget.product.owner.toString());
                    print(contractFactory.allUserProducts.length);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileOther(
                                account: widget.product.owner.toString())));
                  }
                },
                child: Container(
                  color: constants.mainWhiteGColor,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            RandomAvatar(widget.product.owner.toString(),
                                height: 50, width: 50)
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Seller",
                                style:
                                    TextStyle(color: constants.mainBlackColor),
                              ),
                              Text(
                                widget.product.owner.toString(),
                                style: TextStyle(
                                    color: constants.mainGrayColor,
                                    fontSize: 10),
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
              children: [
                widget.product.owner.toString() != contractFactory.w3mService.session!.address
                    ? (widget.product.sell)
                        ? customButtonWidget(() async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Purchase?'),
                                content: Text(
                                    'Are you sure you want to buy this product?'),
                                actions: [
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Đóng hộp thoại xác nhận mua sản phẩm
                                      },
                                      child: Text('Cancel',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        if (double.parse(convertedPrice) *
                                                1.02 >
                                            double.parse(contractFactory
                                                .w3mService.chainBalance)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(
                                                    'Insufficient balance.'),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                          );
                                        } else {
                                          TextEditingController
                                              privateKeyController =
                                              TextEditingController();
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    Text('Enter Private Key'),
                                                content: TextField(
                                                  controller:
                                                      privateKeyController,
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          'Enter private key'),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Đóng hộp thoại nhập private key
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Confirm'),
                                                    onPressed: () async {
                                                      String privateKey =
                                                          privateKeyController
                                                              .text;
                                                      if (double.parse(
                                                                  convertedPrice) *
                                                              102 >
                                                          double.parse(
                                                              contractFactory
                                                                  .w3mService
                                                                  .chainBalance)) {
                                                        await contractFactory
                                                            .BuyProduct(
                                                                privateKey,
                                                                contractFactory
                                                                    .w3mService
                                                                    .session!
                                                                    .address
                                                                    .toString(),
                                                                widget
                                                                    .product.id,
                                                                widget.product
                                                                    .price);
                                                        Navigator.of(context)
                                                            .pop(); // Đóng hộp thoại nhập private key
                                                        Navigator.of(context)
                                                            .pop(); // Đóng cả hộp thoại xác nhận mua sản phẩm
                                                      } else {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                            title:
                                                                Text('Error'),
                                                            content: Text(
                                                                'Insufficient balance'),
                                                          ),
                                                        );
                                                        Future.delayed(
                                                            Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .pop(); // Đóng hộp thoại thông báo lỗi
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (isValidUrl(
                                              contractFactory.resultBuy)) {
                                            addTransaction(
                                                'Buy Product',
                                                contractFactory.myAccount
                                                    .toString(),
                                                widget.product.owner.toString(),
                                                '',
                                                widget.product.name,
                                                convertedPrice,
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                contractFactory.resultBuy,
                                                convertedPrice,
                                                '1',
                                                '1');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  backgroundColor:
                                                      constants.brandColor,
                                                  content: Text('Successful.'),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0))),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  content: Text(
                                                      'Transaction failed'),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0))),
                                            );
                                          }
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Text('Confirm',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }, 15, constants.brandColor, "BUY NOW",
                            constants.mainWhiteGColor, 200)
                        : (widget.product.bid)
                            ? customButtonWidget(
                                () {},
                                15,
                                constants.brandColor,
                                "BIDDING",
                                constants.mainWhiteGColor,
                                200)
                            : customButtonWidget(
                                () {},
                                15,
                                constants.brandColor,
                                "LOCKED",
                                constants.mainWhiteGColor,
                                200)
                    : (widget.product.sell)
                        ? customButtonWidget(
                            () async {},
                            15,
                            constants.brandColor,
                            "SELLING",
                            constants.mainWhiteGColor,
                            200)
                        : (widget.product.bid)
                            ? customButtonWidget(() async {
                                await EndBid();
                              }, 15, constants.brandColor, "END BID",
                                constants.mainWhiteGColor, 200)
                            : Row(
                                children: [
                                  Column(
                                    children: [
                                      customButtonWidget(() async {
                                        TextEditingController
                                            privateKeyController =
                                            TextEditingController();
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Enter Private Key'),
                                              content: TextField(
                                                controller:
                                                    privateKeyController,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Enter private key'),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Confirm'),
                                                  onPressed: () async {
                                                    String privateKey =
                                                        privateKeyController
                                                            .text;
                                                    await contractFactory
                                                        .SellProduct(
                                                            privateKey,
                                                            contractFactory
                                                                .w3mService
                                                                .session!
                                                                .address
                                                                .toString(),
                                                            widget.product.id,
                                                            true);
                                                    await contractFactory
                                                        .sendToken(
                                                            privateKey,
                                                            contractFactory
                                                                .w3mService
                                                                .session!
                                                                .address
                                                                .toString(),
                                                            constants
                                                                .ADMIN_ADDRESS,
                                                            BigInt.parse(fee1
                                                                .toString()));
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (isValidUrl(
                                            contractFactory.resultSell)) {
                                          addTransaction(
                                              'Sell Product',
                                              contractFactory.myAccount
                                                  .toString(),
                                              constants.CONTRACT_ADDRESS,
                                              '',
                                              widget.product.name,
                                              convertedPrice,
                                              '',
                                              '',
                                              '',
                                              '',
                                              '',
                                              contractFactory.resultSell,
                                              fee,
                                              '1',
                                              '1');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                backgroundColor:
                                                    constants.brandColor,
                                                content: Text('Successful.'),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content:
                                                    Text('Transaction failed'),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                          );
                                        }
                                      }, 15, constants.brandColor, "SELL",
                                          Colors.white, 150),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      customButtonWidget(() {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateProduct(
                                                        product:
                                                            widget.product)));
                                      }, 15, constants.brandColor, "EDIT",
                                          Colors.white, 150),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      customButtonWidget(() async {
                                        await _showPlaceBidDialog(context);
                                      }, 15, constants.brandColor,
                                          "CREATE AUTION", Colors.white, 150),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      customButtonWidget(() async {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                CallDialogDelete(onPressed:
                                                    (value, privateKey) async {
                                                  await contractFactory
                                                      .DeleteProduct(
                                                          privateKey,
                                                          contractFactory
                                                              .w3mService
                                                              .session!
                                                              .address
                                                              .toString(),
                                                          widget.product.id);
                                                  Navigator.of(context).pop();
                                                  if (isValidUrl(
                                                        contractFactory
                                                            .resultDelete)) {
                                                      addTransaction(
                                                          'Delete Product',
                                                          contractFactory
                                                              .w3mService
                                                              .session!
                                                              .address
                                                              .toString(),
                                                          constants
                                                              .CONTRACT_ADDRESS,
                                                          '',
                                                          widget
                                                              .product.name,
                                                          convertedPrice,
                                                          '',
                                                          '',
                                                          '',
                                                          '',
                                                          '',
                                                          contractFactory
                                                              .resultDelete,
                                                          '0',
                                                          '1',
                                                          '1');
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            backgroundColor:
                                                                constants
                                                                    .brandColor,
                                                            content: Text(
                                                                'Successful.'),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        10.0))),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                            content: Text(
                                                                'Transaction failed'),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        10.0))),
                                                      );
                                                    }
                                                }));
                                      }, 15, Colors.redAccent, "DELETE",
                                          Colors.white, 150),
                                    ],
                                  ),
                                ],
                              )
              ],
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}

class CallDialog extends StatefulWidget {
  final Function(Map<String, String>) onPressed;

  CallDialog({required this.onPressed});

  @override
  _CallDialogState createState() => _CallDialogState();
}

class _CallDialogState extends State<CallDialog> {
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set time bid'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hourController,
                  decoration: InputDecoration(
                    hintText: 'Hour',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _minuteController,
                  decoration: InputDecoration(
                    hintText: 'Minute',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _secondController,
                  decoration: InputDecoration(
                    hintText: 'Second',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey,
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
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextButton(
            onPressed: () {
              int hour = int.tryParse(_hourController.text) ?? 0;
              int minute = int.tryParse(_minuteController.text) ?? 0;
              int second = int.tryParse(_secondController.text) ?? 0;

              if (hour < 0 || minute < 0 || second < 0) {
                // Nếu có bất kỳ giá trị nào là số âm hoặc không phải là số, yêu cầu nhập lại
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Invalid Input"),
                      content: Text(
                          "Please enter positive integers for hour, minute, and second."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              } else {
                Map<String, String> timeMap = {
                  'hour': hour.toString(),
                  'minute': minute.toString(),
                  'second': second.toString(),
                };

                widget.onPressed(timeMap);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Set time',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }
}

class CallDialogDelete extends StatefulWidget {
  final Function(bool, String) onPressed;

  CallDialogDelete({required this.onPressed});

  @override
  _CallDialogDeleteState createState() => _CallDialogDeleteState();
}

class _CallDialogDeleteState extends State<CallDialogDelete> {
  TextEditingController privateKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to delete this product?'),
          SizedBox(height: 20),
          TextField(
            controller: privateKeyController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Enter your private key'),
          ),
        ],
      ),
      actions: [
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey,
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
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextButton(
            onPressed: () {
              // Do something when Set time is pressed
              String privateKey = privateKeyController.text;
              widget.onPressed(true, privateKey);
              Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
