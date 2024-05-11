import 'dart:async';
import 'dart:ui';

import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/text/w3m_address.dart';
import 'package:web3modal_flutter/widgets/w3m_connect_wallet_button.dart';
import 'package:win_marketplace_tech/pages/Product/CreateProductPage.dart';
import 'package:win_marketplace_tech/pages/Profile/UpdateAuthor.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';
import 'package:win_marketplace_tech/widgets/CustomButtonWidget.dart';
import 'package:win_marketplace_tech/widgets/HeadingCoverWidget.dart';

import '../../services/ContractFactoryServies.dart';
import '../../widgets/CustomProductCardWidget.dart';
import '../Transaction/TransactionsDetails.dart';
import '../Transaction/TransactionsPage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Constants constants = Constants();
  late final ContractFactoryServies _contractFactoryServies =
      ContractFactoryServies();

  //ConnectWallet connectWallet = ConnectWallet();

  late DatabaseReference dbRef1;
  DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Authors');
  Map<String, Map<String, dynamic>> _author = {};
  bool _isLoading = true;

  Widget listItem({required Map transaction}) {
    return InkWell(
      onTap: () {
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
                (transaction['from'] == _contractFactoryServies.w3mService.session!.address.toString())
                ?(transaction['name_trans'] == 'Create Product')
                    ? Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.black45,
                      )
                    : (transaction['name_trans'] == 'Sell Product')
                        ? Icon(
                            Icons.sell_outlined,
                            color: Colors.black45,
                          )
                        : (transaction['name_trans'] == 'Delete Product')
                            ? Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.black45,
                              )
                            : (transaction['name_trans'] == 'Buy Product')
                                ? Icon(
                                    Icons.call_made,
                                    color: Colors.black45,
                                  )
                                : (transaction['name_trans'] == 'Place Bid')
                                    ? Icon(
                                        Icons.gavel,
                                        color: Colors.black45,
                                      )
                                    : (transaction['name_trans'] ==
                                            'Create Aution')
                                        ? Icon(
                                            Icons.av_timer,
                                            color: Colors.black45,
                                          )
                                        : Icon(Icons.not_interested)
                :Icon(
                  Icons.call_received,
                  color: Colors.black45,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((transaction['from'] ==
                                _contractFactoryServies
                                    .w3mService.session!.address
                                    .toString())
                            ? transaction['name_trans']
                            : "Receive"),
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
                        child: Text((transaction['from'] ==
                            _contractFactoryServies
                                .w3mService.session!.address
                                .toString())? '- ' + transaction['value'] + ' ETH': '+ ' + transaction['value'] + ' ETH'),
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
                                ? SizedBox()
                                : (transaction['accept'] == '1')
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            Uri link =
                                                Uri.parse(transaction['link']);
                                            if (transaction['link']
                                                    .toString() !=
                                                '') {
                                              if (isValidUrl(
                                                  transaction['link'])) {
                                                launchUrl(link,
                                                    mode: LaunchMode
                                                        .externalApplication);
                                              } else {
                                                print("Error Link");
                                              }
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  Future.delayed(
                                                      Duration(seconds: 2), () {
                                                    Navigator.of(context).pop();
                                                  });
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Error',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    content: Text(
                                                        'User has not added this contact'),
                                                  );
                                                },
                                              );
                                            }
                                          });
                                        },
                                        child: Text(
                                          'view on etherscan',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.blue,
                                          ),
                                        ),
                                      )
                                    : SizedBox()),
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
                                style: TextStyle(color: Colors.orangeAccent),
                              )
                            : (transaction['accept'] == '1')
                                ? Text(
                                    'Successful',
                                    style: TextStyle(color: Colors.green),
                                  )
                                : Text(
                                    'Failed',
                                    style: TextStyle(color: Colors.redAccent),
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

  List<Widget> _listtrans = [];

  void _searchAuthors() {
    if (_contractFactoryServies.w3mService.session?.address != null) {
      String keyword =
          _contractFactoryServies.w3mService.session?.address?.toLowerCase() ??
              '';
      _dbRef.onValue.listen((event) {
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic> values = snapshot.value as Map;
        _author.clear();
        if (values != null) {
          bool addressFound = false;
          values.forEach((key, value) {
            if (value['address'].toLowerCase() == keyword) {
              addressFound = true;
              _author[key] = {
                'key': key,
                'address': value['address'],
                'link_facebook': value['link_facebook'],
                'link_other': value['link_other'],
              };
            }
          });
          if (!addressFound) {
            _addNewAuthor(
                _contractFactoryServies.w3mService.session!.address.toString());
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
      });
    }
  }

  List<Widget> _listTrans = [];
  Query dbRef = FirebaseDatabase.instance.ref().child('Transactions');

  void _searchTransactions() {
    String key = _contractFactoryServies.w3mService.session?.address.toString() ?? '';
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child('Transactions');
    reference.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        for (DataSnapshot childSnapshot in snapshot.children) {
          Map transaction = childSnapshot.value as Map;
          print(transaction['from']);
          if (transaction['from'] == key || transaction['to'] == key) {
            _listTrans.add(listItem(transaction: transaction));
          }
        }
        _listTrans = List.from(_listTrans.reversed);
        setState(() {}); // Update UI with _transactionCountFrom1 (optional)
      }
    });
    print('activity: ' + _listTrans.length.toString());
  }

  void _addNewAuthor(String address) {
    _dbRef.push().set({
      'address': address,
      'link_facebook': '',
      'link_other': '',
    }).then((_) {
      print('New client added');
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      print('Failed to add new client: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  bool isValidUrl(String url) {
    // Biểu thức chính quy kiểm tra cú pháp của đường dẫn URL
    // Đây là một biểu thức đơn giản, bạn có thể tùy chỉnh nó tùy theo yêu cầu của bạn
    final RegExp urlRegExp = RegExp(
      r'^(http|https):\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegExp.hasMatch(url);
  }

  @override
  @override
  void initState() {
    super.initState();
    // Listen for changes in _w3mServiceManager
    _contractFactoryServies.addListener(() {
      // Perform actions when _w3mService becomes available
      if (_contractFactoryServies.w3mService != null) {
        // Use the _w3mService here (e.g., call methods)
        print(_contractFactoryServies.w3mService.isConnected);
      }
    });
    _contractFactoryServies.saveAccountAddress(
        _contractFactoryServies.w3mService.session?.address.toString() ?? '');
    dbRef1 = FirebaseDatabase.instance.ref().child('Authors');
    if (_contractFactoryServies.w3mService.isConnected) {
      _contractFactoryServies.getUserProducts();
    }
    _searchAuthors();
    _searchTransactions();
    // _searchTransactions();
  }

  @override
  void dispose() {
    _contractFactoryServies.removeListener(() {}); // Remove listener on dispose
    super.dispose();
  }

  //Intialize web3model object

  bool _reloading = false;

  void _reload() {
    setState(() {
      _reloading = true;
    });

    // Simulate a reload delay
    Timer(Duration(seconds: 1), () {
      setState(() {
        _reloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // var connectWallet = Provider.of<WalletConnect>(context);
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    double h = MediaQuery.of(context).size.height / 844;
    double w = MediaQuery.of(context).size.width / 390;
    bool checkaccount = (contractFactory.myAccount == constants.ADMIN_ADDRESS);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constants.brandColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // Sử dụng Expanded cho văn bản "Profile" để nó chiếm hết không gian còn lại
              child: Text(
                "Profile",
                textAlign: TextAlign.center,
              ),
            ),
            InkWell(
                onTap: () {
                  setState() {}
                  ;
                  contractFactory.saveAccountAddress(
                      contractFactory.w3mService.session!.address.toString());
                  if (contractFactory.w3mService.isConnected) {
                    contractFactory.getUserProducts();
                  }
                  _searchAuthors();
                  _searchTransactions();
                },
                child: Icon(Icons.refresh)),
          ],
        ),
      ),
      floatingActionButton: (contractFactory.w3mService.isConnected)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateProductPage()));
              },
              backgroundColor: constants.brandColor,
              child: Icon(
                Icons.add,
                size: 40,
                color: constants.mainBlackColor,
              ),
            )
          : SizedBox(),
      body: Container(
        width: double.maxFinite,
        child: Column(
          children: [
            _buildProfiledetails(context),
            //Connected
            (contractFactory.w3mService.isConnected)
                ? DefaultTabController(
                    length: 2,
                    initialIndex: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TabBar(
                          labelColor: constants.brandColor,
                          unselectedLabelColor: Colors.black,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pages,
                                    color: Colors.lightBlue,
                                  ),
                                  SizedBox(
                                    width: 0.2,
                                  ),
                                  Text(contractFactory.allUserProducts.length
                                          .toString() +
                                      " Collected"),
                                ],
                              ),
                            ),
                            Tab(
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings_backup_restore,
                                    color: Colors.lightBlue,
                                  ),
                                  SizedBox(
                                    width: 0.2,
                                  ),
                                  Text("Activities"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.40,
                            child: TabBarView(
                              children: [
                                (!contractFactory.allUserProducts.isEmpty)
                                    ? SingleChildScrollView(
                                        child: Container(
                                          child: AlignedGridView.count(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              mainAxisSpacing: 15,
                                              crossAxisSpacing: 15,
                                              padding: EdgeInsets.all(15),
                                              itemCount: contractFactory
                                                  .allUserProducts.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              crossAxisCount: 2,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  child: Column(
                                                    children: [
                                                      customProductCardWidget(
                                                          context,
                                                          contractFactory
                                                              .allUserProducts[
                                                                  index]
                                                              .image,
                                                          contractFactory
                                                              .allUserProducts[
                                                                  index]
                                                              .name,
                                                          contractFactory
                                                              .allUserProducts[
                                                                  index]
                                                              .price
                                                              .toString(),
                                                          contractFactory
                                                                  .allUserProducts[
                                                              index]),
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 40.0, right: 40.0, top: 16),
                                          child: EmptyWidget(
                                            image: null,
                                            packageImage: PackageImage.Image_3,
                                            title: 'No Magazine NFTS',
                                            subTitle:
                                                'You do not own any nfts yet!',
                                            titleTextStyle: const TextStyle(
                                              fontSize: 22,
                                              color: Color(0xff9da9c7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            subtitleTextStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xffabb8d6),
                                            ),
                                          ),
                                        ),
                                      ),
                                (_listTrans.isNotEmpty)
                                    ? FirebaseAnimatedList(
                                        query: dbRef,
                                        itemBuilder: (BuildContext context,
                                            DataSnapshot snapshot,
                                            Animation<double> animation,
                                            int index) {
                                          Map transaction =
                                              snapshot.value as Map;
                                          transaction['key'] = snapshot.key;
                                          if (transaction['from'] ==
                                                  contractFactory.myAccount ||
                                              transaction['to'] ==
                                                  contractFactory.myAccount) {
                                            return listItem(
                                                transaction: transaction);
                                          } else {
                                            return Container(
                                              height: 0,
                                            );
                                          }
                                        },
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40.0, right: 40.0, top: 16),
                                        child: EmptyWidget(
                                          image: null,
                                          packageImage: PackageImage.Image_3,
                                          title: 'No Activities',
                                          subTitle:
                                              'No  activities available yet',
                                          titleTextStyle: const TextStyle(
                                            fontSize: 22,
                                            color: Color(0xff9da9c7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          subtitleTextStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xffabb8d6),
                                          ),
                                        ),
                                      ),
                              ],
                            ))
                      ],
                    ),
                  )
                : SizedBox(),
            // customButtonWidget((){
            //   showSheet(context);
            // }, 20, constants.brandColor, "Login", Colors.white, 200),
            (!contractFactory.w3mService.isConnected)
                ? Positioned(
                    right: 15.0,
                    top: 130.0,
                    child: W3MConnectWalletButton(
                        service: contractFactory.w3mService),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfiledetails(BuildContext context) {
    double h = MediaQuery.of(context).size.height / 844;
    double w = MediaQuery.of(context).size.width / 390;
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return SizedBox(
      height: 290 * h,
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 191 * h,
              width: double.maxFinite,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                (contractFactory.w3mService.isConnected)
                                    ? "images/cover_connected.png"
                                    : "images/cover_disconnect.png"),
                            fit: BoxFit.cover,
                            scale: 1)),
                  ),
                  (contractFactory.w3mService.isConnected)
                      ? Positioned(
                          right: 24.0,
                          top: 5.0,
                          child: Column(
                            children: [
                              W3MConnectWalletButton(
                                  service: contractFactory.w3mService),
                              (contractFactory.w3mService.session!.address ==
                                          constants.ADMIN_ADDRESS &&
                                      contractFactory.w3mService.isConnected)
                                  ? Container(
                                      height: 38,
                                      width: 110,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xff3596ff),
                                      ),
                                      child: TextButton(
                                          onPressed: () {
                                            print(contractFactory.myAccount);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TransactionPage()));
                                          },
                                          child: Text(
                                            'Admin',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )))
                                  : SizedBox(),
                            ],
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
          // Positioned(
          //   right: 5.0,
          //   top: 195.0,
          //   child: Container(
          //     width: 80,
          //     height: 30,
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(20.0),
          //         color: Colors.grey[300]),
          //     child: TextButton(
          //       onPressed: () {
          //         _reload();
          //         contractFactory.saveAccountAddress(
          //             contractFactory.w3mService.session!.address.toString());
          //         if (contractFactory.w3mService.isConnected) {
          //           contractFactory.getUserProducts();
          //         }
          //       },
          //       child: Text(
          //         (!_reloading ? "Reload" : "Reloading..."),
          //         style: TextStyle(
          //           fontSize: 11,
          //           color: Colors.black54,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          //Connected
          (contractFactory.w3mService.isConnected)
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22 * w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 92 * h,
                              width: 88 * w,
                              margin: EdgeInsets.only(bottom: 0 * h),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  RandomAvatar(
                                      contractFactory
                                          .w3mService.session!.address
                                          .toString(),
                                      height: 100,
                                      width: 100),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 48.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateAuthor(
                                        address: contractFactory.myAccount.toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  shape: MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0, top: 2),
                          child: W3MAccountButton(
                              service: contractFactory.w3mService),
                        ),
                        Row(
                          children: _author.values.map((author) {
                            return Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    'Contact: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      print(author['link_facebook'].toString());
                                      Uri fblink =
                                          Uri.parse(author['link_facebook']);
                                      if (author['link_facebook'].toString() !=
                                          '') {
                                        if (isValidUrl(
                                            author['link_facebook'])) {
                                          launchUrl(fblink,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              Future.delayed(Duration(seconds: 2),
                                                      () {
                                                    Navigator.of(context).pop();
                                                  });
                                              return AlertDialog(
                                                title: Text(
                                                  'Error',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                content: Text(
                                                    'This link is not working'),
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              Navigator.of(context).pop();
                                            });
                                            return AlertDialog(
                                              title: Text(
                                                'Error',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              content: Text(
                                                  'User has not added this contact'),
                                            );
                                          },
                                        );
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.facebook,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      print(author['link_other'].toString());
                                      Uri otherlink =
                                          Uri.parse(author['link_other']);
                                      if (otherlink.toString() != '') {
                                        if (isValidUrl(otherlink.toString())) {
                                          launchUrl(otherlink,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              Future.delayed(
                                                  Duration(seconds: 2), () {
                                                Navigator.of(context).pop();
                                              });
                                              return AlertDialog(
                                                title: Text(
                                                  'Error',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                content: Text(
                                                    'Failed to open this link'),
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              Navigator.of(context).pop();
                                            });
                                            return AlertDialog(
                                              title: Text(
                                                'Error',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              content: Text(
                                                  'User has not added this contact'),
                                            );
                                          },
                                        );
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.link,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                )
              //Disconnected
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22 * w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  image: DecorationImage(
                                      image: AssetImage("images/logo.png"),
                                      fit: BoxFit.cover,
                                      scale: 1)),
                            ),
                            // Container(
                            //   height: 90 * h,
                            //   width: 90 * h,
                            //   margin: EdgeInsets.only(bottom: 4 * h),
                            //   child: Stack(
                            //     alignment: Alignment.center,
                            //     children: [
                            //       RandomAvatar("1", height: 100, width: 100),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 2 * h),
                        Container(
                            width: 250,
                            alignment: Alignment.center,
                            child: Text(
                              "Connect wallet to see all your collection",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  showSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        var contract = Provider.of<ContractFactoryServies>(context);
        return SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 12,
                      child: Text("1")),
                  title: W3MConnectWalletButton(
                    service: _contractFactoryServies.w3mService,
                  ),
                  trailing: Padding(
                    padding: EdgeInsets.only(left: 150.0),
                    child: (contract.w3mService.isConnected)
                        ? Icon(
                            Icons.check_circle,
                            color: constants.brandColor,
                          )
                        : SizedBox(),
                  )),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 12,
                    child: Text("2")),
                title: Text("Sign Message"),
                trailing: Icon(
                  Icons.check_circle,
                  color: constants.brandColor,
                ),
              ),
              OutlinedButton(onPressed: () {}, child: Text("Continue"))
            ],
          ),
        );
      },
    );
  }
}
