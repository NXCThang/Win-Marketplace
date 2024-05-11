import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win_marketplace_tech/services/ContractFactoryServies.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';
import 'package:win_marketplace_tech/widgets/CustomProductCardWidget.dart';

import '../Transaction/TransactionsDetails.dart';

class ProfileOther extends StatefulWidget {
  String account;

  ProfileOther({required this.account, super.key});

  @override
  State<ProfileOther> createState() => _ProfileOtherState();
}

class _ProfileOtherState extends State<ProfileOther> {
  Constants constants = Constants();
  late final ContractFactoryServies _contractFactoryServies =
      ContractFactoryServies();

  late DatabaseReference dbRef1;
  Query dbRef = FirebaseDatabase.instance.ref().child('Transactions');
  DatabaseReference reference = FirebaseDatabase.instance.ref().child('Transactions');
  DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Authors');

  Map<String, Map<String, dynamic>> _author = {};
  bool _isLoading = true;

  void _searchAuthors() {
    if (widget.account.isNotEmpty) {
      String keyword = widget.account.toLowerCase();
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
            _addNewAuthor(widget.account);
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
      });
    }
  }

  void _searchTransactions(){
    reference.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        for (DataSnapshot childSnapshot in snapshot.children) {
          Map transaction = childSnapshot.value as Map;
          if (transaction['from'] == widget.account) {
            _listTrans.add(listItem(transaction: transaction));
          }
        }
        _listTrans = List.from(_listTrans.reversed);
        setState(() {}); // Update UI with _transactionCountFrom1 (optional)
      }
    });
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

  List<Widget> _listTrans=[];
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
                (transaction['from'] == widget.account)
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
                            widget.account)
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
                            widget.account)? '- ' + transaction['value'] + ' ETH': '+ ' + transaction['value'] + ' ETH'),
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


  @override
  void initState() {
    super.initState();
    dbRef1 = FirebaseDatabase.instance.ref().child('Authors');
    _searchAuthors();
    _contractFactoryServies.getUserOtherProducts(widget.account);
    _searchTransactions();
    print(widget.account);
  }

  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    double h = MediaQuery.of(context).size.height / 844;
    double w = MediaQuery.of(context).size.width / 390;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constants.brandColor,
        title: Center(child: const Text("Profile")),
      ),
      body: Container(
        width: double.maxFinite,
        child: Column(
          children: [
            _buildProfiledetails(context),
            //Connected

            DefaultTabController(
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
                            Text(contractFactory.allUserOtherProducts.length
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
                          (!contractFactory.allUserOtherProducts.isEmpty)
                              ? SingleChildScrollView(
                                  child: Container(
                                    child: AlignedGridView.count(
                                        physics: NeverScrollableScrollPhysics(),
                                        mainAxisSpacing: 15,
                                        crossAxisSpacing: 15,
                                        padding: EdgeInsets.all(15),
                                        itemCount: contractFactory
                                            .allUserOtherProducts.length,
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
                                                        .allUserOtherProducts[
                                                            index]
                                                        .image,
                                                    contractFactory
                                                        .allUserOtherProducts[
                                                            index]
                                                        .name,
                                                    contractFactory
                                                        .allUserOtherProducts[
                                                            index]
                                                        .price
                                                        .toString(),
                                                    contractFactory
                                                            .allUserOtherProducts[
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
                                      subTitle: 'You do not own any nfts yet!',
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
                            reverse: true,
                            itemBuilder: (BuildContext context,
                                DataSnapshot snapshot,
                                Animation<double> animation,
                                int index) {
                              Map transaction =
                              snapshot.value as Map;
                              transaction['key'] = snapshot.key;
                              if (transaction['from'] ==
                                  widget.account) {
                                return listItem(
                                    transaction: transaction);
                              } else {
                                return Container(
                                  height: 0,
                                );
                              }
                            },
                          )
                          :Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 40.0, top: 16),
                            child: EmptyWidget(
                              image: null,
                              packageImage: PackageImage.Image_3,
                              title: 'No Activities',
                              subTitle: 'No  activities available yet',
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
            // customButtonWidget((){
            //   showSheet(context);
            // }, 20, constants.brandColor, "Login", Colors.white, 200),
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
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/cover_connected.png"),
                            fit: BoxFit.cover,
                            scale: 1)),
                  ),
                ],
              ),
            ),
          ),
          Align(
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
                          alignment: Alignment.bottomRight,
                          children: [
                            RandomAvatar(widget.account.toString(),
                                height: 100, width: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Text(widget.account),
                      ],
                    ),
                  ),
                  SizedBox(height: 2 * h),
                  Row(
                    children: _author.values.map((author){
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text('Contact: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),),
                          ),
                          InkWell(
                            onTap: ()  {
                              setState(() {
                                print(author['link_facebook'].toString());
                                Uri fblink = Uri.parse(author['link_facebook']);
                                if(author['link_facebook'].toString()!='') {
                                  if(isValidUrl(author['link_facebook'])){
                                    launchUrl(fblink, mode: LaunchMode.externalApplication);
                                  }else{
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
                                }else{
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      Future.delayed(Duration(seconds: 2), () {
                                        Navigator.of(context).pop();
                                      });
                                      return AlertDialog(
                                        title: Text('Error',style: TextStyle(color: Colors.red),),
                                        content: Text('User has not added this contact'),
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
                          SizedBox(width: 4,),
                          InkWell(
                            onTap: ()  {
                              setState(() {
                                print(author['link_other'].toString());
                                Uri otherlink = Uri.parse(author['link_other']);
                                if(otherlink.toString()!='') {
                                  if(isValidUrl(otherlink.toString())){
                                    launchUrl(otherlink, mode: LaunchMode.externalApplication);
                                  }else{
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        Future.delayed(Duration(seconds: 2), () {
                                          Navigator.of(context).pop();
                                        });
                                        return AlertDialog(
                                          title: Text('Error',style: TextStyle(color: Colors.red),),
                                          content: Text('Failed to open this link'),
                                        );
                                      },
                                    );
                                  }
                                }else{
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      Future.delayed(Duration(seconds: 2), () {
                                        Navigator.of(context).pop();
                                      });
                                      return AlertDialog(
                                        title: Text('Error',style: TextStyle(color: Colors.red),),
                                        content: Text('User has not added this contact'),
                                      );
                                    },
                                  );
                                }
                              });
                            },
                            child: Icon(
                              Icons.link,),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
