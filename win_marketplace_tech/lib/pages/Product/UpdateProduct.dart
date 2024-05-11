import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:win_marketplace_tech/services/Models/ProductModel.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';
import 'package:win_marketplace_tech/widgets/CustomButtonWidget.dart';
import 'package:win_marketplace_tech/widgets/CustomTextFieldWidgets.dart';

import '../../services/ContractFactoryServies.dart';

class UpdateProduct extends StatefulWidget {
  UpdateProduct({required this.product,super.key});
  ProductModel product;
  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  Constants constants = Constants();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController desprivateController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  late String dropMenuValue = widget.product.category;
  String ipfsImageHash = "";
  String ipfsQRHash = "";
  File? imageFile;
  File? imageQRFile;
  late String convertedPrice =
  (double.parse(widget.product.price.toString()) / 1000000000).toString();

  @override
  void initState() {
    super.initState();
    _getDataProduct();
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
  void _getDataProduct(){
    nameController.text = widget.product.name;
    descriptionController.text = widget.product.description;
    desprivateController.text = widget.product.desprivate;
    priceController.text = convertedPrice;
    ipfsImageHash = widget.product.image;
    ipfsQRHash = widget.product.qr;
  }
  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "UPDATE PRODUCT",
        ),
        centerTitle: true,
        backgroundColor: constants.brandColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('Name: ', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  customTextFieldWidget(1, "Product Name", nameController),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Text('Price: ', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  customTextFieldWidget(1, "Product Price", priceController),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('Description: ', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  customTextFieldWidget(
                      3, "Product Description", descriptionController),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('Private Description: ', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  customTextFieldWidget(
                      4, "Product Description private", desprivateController),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.7,
                    )),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Select Category",
                        style: TextStyle(
                          color: constants.mainBlackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0)),
                        border: Border(
                          top: BorderSide(
                            color: Colors.black, // Màu của đường viền trên
                            width: 1, // Độ dày của đường viền trên
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            value: dropMenuValue,
                            items: constants.categoryList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                dropMenuValue = value!;
                              });
                            }
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Image: ', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.40,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                        image: NetworkImage(widget.product.image),
                        fit: BoxFit.cover,
                        scale: 1)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('QR: ', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ],
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
              padding: const EdgeInsets.all(16.0),
              child: customButtonWidget(() async
              {
                TextEditingController privateKeyController = TextEditingController();
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Enter Private Key'),
                      content: TextField(
                        controller: privateKeyController,
                        decoration: InputDecoration(
                            hintText: 'Enter private key'),
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
                            String privateKey = privateKeyController
                                .text;
                            await contractFactory.UpdateProduct(privateKey, contractFactory.w3mService.session!.address.toString(),
                                  widget.product.id, nameController.text, descriptionController.text,
                                  desprivateController.text, ipfsImageHash, priceController.text,
                                  dropMenuValue, ipfsQRHash);
                            Navigator.of(context)
                                .pop(); // Close the dialog
                          },
                        ),
                      ],
                    );
                  },
                );
                if(isValidUrl(contractFactory.resultUpdate)){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Successful!',
                            style: TextStyle(color: Colors.red),
                          ),
                          content: InkWell(
                            onTap: (){
                              Uri transaction = Uri.parse(contractFactory.resultUpdate);
                              launchUrl(transaction, mode: LaunchMode.externalApplication);
                            },
                              child: Text(
                                contractFactory.resultUpdate,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue, // Màu của underline
                                  color: Colors.blue, // Màu của văn bản
                                ),
                              )),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  addTransaction(
                      'Update Product',
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
                      contractFactory.resultUpdate,
                      '0',
                      '1',
                      '1');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: constants.brandColor,
                        content: Text('Successful!!!'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        )
                    ),
                  );
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Transaction failed!!!'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        )
                    ),
                  );
                }
              }
                ,20, constants.brandColor, "UPDATE", Colors.white,
                  MediaQuery.of(context).size.width),
            ),
          ],
        ),
      ),
    );
  }
}
