import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../services/ContractFactoryServies.dart';
import '../../utils/Constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/CustomButtonWidget.dart';
import '../../widgets/CustomLoaderWidget.dart';
import '../../widgets/CustomTextFieldWidgets.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({Key? key}) : super(key: key);

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  Constants constants = Constants();
  TextEditingController privateKeyController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController desprivateController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String dropMenuValue = "Games";
  String ipfsImageHash = "";
  String ipfsQRHash = "";
  File? imageFile;
  File? imageQRFile;
  late DatabaseReference dbRef;
  bool _empty = false;
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Transactions');
  }


  void _checkEmpty() async {
    // Kiểm tra các trường có trống không
    if (privateKeyController.text.isEmpty ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        desprivateController.text.isEmpty ||
        imageFile == null ||
        imageQRFile == null) {
      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[600],
          content: Text('Please fill in all required fields'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          )
        ),
      );
      _empty = true; // Kết thúc hàm nếu có trường nào đó trống
    }else _empty = false;
  }

  void _clear() {
    setState(() {
      privateKeyController.clear();
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      desprivateController.clear();
      imageFile = null;
      imageQRFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return Scaffold(
      backgroundColor: constants.mainBGColor,
      appBar: AppBar(
        title: Text(
          constants.APP_NAME,
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "Create Product",
                  style: TextStyle(
                    color: constants.mainBlackColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  customTextFieldWidget(1, "Private Key", privateKeyController),
                  customTextFieldWidget(1, "Product Name", nameController),
                  customTextFieldWidget(1, "Product Price", priceController),
                  customTextFieldWidget(
                      3, "Product Description", descriptionController),
                  customTextFieldWidget(
                      4, "Product Description private", desprivateController),

                  //Image.file(imageFile))),
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
                            items: constants.categoryList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                  value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                dropMenuValue = value!;
                              });
                            }),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () async {
                      imageFile = await uploadMagazineCover();
                      setState(() {});
                    },
                    child: DottedBorder(
                      dashPattern: const [6, 3],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: (imageFile == null)
                              ? Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  color: constants.plainColor,
                                  child: const Text(
                                    'Upload Image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : Image.file(imageFile!)),
                    ),
                  ),
                )),
            Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0),
                child: Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () async {
                      imageQRFile = await uploadMagazineCover();
                      setState(() {});
                    },
                    child: DottedBorder(
                      dashPattern: const [6, 3],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        child: (imageQRFile == null)
                            ? Container(
                                alignment: Alignment.center,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                color: constants.plainColor,
                                child: const Text(
                                  "Upload QR",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Image.file(imageQRFile!),
                        //     : Container(
                        //   width: MediaQuery.of(context).size.width,
                        //   height: 200,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     image: DecorationImage(
                        //       image: NetworkImage(ipfsQRHash),
                        //       fit: BoxFit.cover,
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: customButtonWidget(() async {
                print(contractFactory.myAccount);
                _checkEmpty();
                if(!_empty){
                  await uploadImageToIPFS().then((value) {
                    setState(() {});
                    if (value["status"] == 'Success') {
                      ipfsImageHash =
                          constants.PINATA_FETCH_IMAGE_URL + value["IpfsHash"];
                    }
                    print("Image " + ipfsImageHash);
                  });
                  await uploadImageQRToIPFS().then((value) {
                    setState(() {});
                    if (value["status"] == 'Success') {
                      ipfsQRHash =
                          constants.PINATA_FETCH_IMAGE_URL + value["IpfsHash"];
                    }
                    print("QR: " + ipfsQRHash);
                  });
                  DateTime now = DateTime.now();
                  // Define the format you want for the string representation
                  String formattedDate =
                  DateFormat('HH:mm:ss dd-MM-yyyy').format(now);
                  print(formattedDate); // Output: e.g., 2024-04-16 14:32:45
                  Map<String, String> transactions = {
                    'name_trans': 'Create Product',
                    'from': contractFactory.myAccount.toString(),
                    'to': constants.CONTRACT_ADDRESS,
                    'private_key': privateKeyController.text,
                    'name_product': nameController.text,
                    'price': priceController.text,
                    'description': descriptionController.text,
                    'desprivate': desprivateController.text,
                    'category': dropMenuValue,
                    'image': ipfsImageHash,
                    'qr': ipfsQRHash,
                    'accept': "0",
                    'resolve': "0",
                    "link":"",
                    "value":'0',
                    'time': formattedDate,
                  };
                  dbRef.push().set(transactions);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: Colors.grey[600],
                        content: Text('Your product creation request has been submitted to the admin for review.'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        )
                    ),
                  );
                  _clear();
                }
                // contractFactory.Text_CreateProduct(
                //     privateKeyController.text,
                //     nameController.text,
                //     descriptionController.text,
                //     desprivateController.text,
                //     ipfsImageHash,
                //     priceController.text,
                //     dropMenuValue,
                //     ipfsQRHash);
              }, 20, constants.brandColor, "Create", Colors.white,
                  MediaQuery.of(context).size.width),
            ),
            // ElevatedButton(
            //     onPressed: () {
            //       // await uploadImageQRToIPFS().then((value) {
            //       //   setState(() {});
            //       //   if (value["status"] == 'Success') {
            //       //     ipfsQRHash = constants.PINATA_FETCH_IMAGE_URL +
            //       //         value["IpfsHash"];
            //       //   }
            //       //   print("QR: " + ipfsQRHash);
            //       // });
            //       setState(() {
            //         imageQRFile = null;
            //         imageFile = null;
            //       });
            //     },
            //     child: Text("Clear")),
          ],
        ),
      ),
    );
  }

  Future<File> uploadMagazineCover() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    File imageFile = File(pickedFile!.path);
    return imageFile;
  }

  Future<Map<String, dynamic>> uploadImageToIPFS() async {
    // Create a multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS'),
    );

    // Add API key and secret to the headers
    // request.headers.addAll({
    //   'pinata_api_key': constants.PINATA_API_KEY,
    //   'pinata_secret_api_key': constants.PINATA_SECRET_API_KEY,
    // });

    request.headers['Content-Tyoe'] = 'multipart/form-data';
    request.headers['pinata_api_key'] = 'a966f01f8747a36bdef6';
    request.headers['pinata_secret_api_key'] =
        '9aa51a9361041b8302fadf496cccca394b6d578fb61fa00d20a44986a586de45';

    // Attach the image file to the request with the field name "file"
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile!.path,
      ),
    );

    try {
      var response = await request.send();

      // Read the response
      var responseBody = await response.stream.bytesToString();

      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      // print("Success");
      // print(jsonResponse['IpfsHash'].toString());
      // Return the IPFS hash
      return {
        "status": "Success",
        "IpfsHash": jsonResponse["IpfsHash"].toString()
      };
    } catch (error) {
      print('Error uploading to Pinata: $error');
    }
    return {"status": "Faild", "IpfsHash": "NO HAsh"};
  }

  Future<Map<String, dynamic>> uploadImageQRToIPFS() async {
    // Create a multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS'),
    );

    // Add API key and secret to the headers
    // request.headers.addAll({
    //   'pinata_api_key': constants.PINATA_API_KEY,
    //   'pinata_secret_api_key': constants.PINATA_SECRET_API_KEY,
    // });

    request.headers['Content-Tyoe'] = 'multipart/form-data';
    request.headers['pinata_api_key'] = 'a966f01f8747a36bdef6';
    request.headers['pinata_secret_api_key'] =
        '9aa51a9361041b8302fadf496cccca394b6d578fb61fa00d20a44986a586de45';

    // Attach the image file to the request with the field name "file"
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageQRFile!.path,
      ),
    );

    try {
      var response = await request.send();

      // Read the response
      var responseBody = await response.stream.bytesToString();

      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      // Return the IPFS hash
      return {
        "status": "Success",
        "IpfsHash": jsonResponse["IpfsHash"].toString()
      };
    } catch (error) {
      print('Error uploading to Pinata: $error');
    }
    return {"status": "Faild", "IpfsHash": "NO HAsh"};
  }
// Future<Map<String, dynamic>> uploadToIPFS() async {
//   final ImagePicker _picker = ImagePicker();
//   XFile? result = await _picker.pickImage(source: ImageSource.gallery);
//
//   print("Galary image is ${result?.path}");
//
//   if (result != null) {
//     try {
//       File file = File(result.path!);
//
//       var request = http.MultipartRequest(
//           'POST', Uri.parse(constants.PINATA_END_POINT_API));
//
//       request.headers['Content-Tyoe'] = 'multipart/form-data';
//       request.headers['pinata_api_key'] = constants.PINATA_API_KEY;
//       request.headers['pinata_secret_api_key'] = constants.PINATA_SECRET_KEY;
//
//       var filename = "${DateTime.now()}";
//
//       request.fields['names'] = filename;
//       request.files.add(await http.MultipartFile.fromPath('file', file.path));
//
//       var response = await request.send();
//
//       final res = await http.Response.fromStream(response);
//
//       if (response.statusCode != 200) {
//         return {
//           "status": "Faild to save at response",
//           "ipfsHash": "Not found"
//         };
//       } else if (response.statusCode == 200) {
//         var hash = jsonDecode(res.body);
//         // print("res.body ${res.body}");
//         return {
//           "status": "Faild to save at response",
//           "ipfsHash": hash["IpfsHash"].toString()
//         };
//       }
//     } catch (e) {
//       return {"status": "Error at catch ${e}", "ipfsHash": "Not found"};
//     }
//   } else {
//     return {"status": "No file selected", "ipfsHash": "Not found"};
//   }
//
//   return {"status": "Success", "ipfsHash": ""};
// }

// Future<String?> _uploadImageToIPFS() async {
//   // Create a multipart request
//   var request = http.MultipartRequest(
//     'POST',
//     Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS'),
//   );
//
//   // Add API key and secret to the headers
//   request.headers.addAll({
//     'pinata_api_key': "d30d41c4331b10e1b042",
//     'pinata_secret_api_key':
//     "d39931ed27c5bf956cb46c0e2e0dd292f8ea0dadf2e0b1cafa03def9a1f031e5",
//   });
//
//   // Attach the image file to the request with the field name "file"
//   request.files.add(
//     await http.MultipartFile.fromPath(
//       'file',
//       imageFile!.path,
//     ),
//   );
//
//   try {
//     var response = await request.send();
//
//     // Read the response
//     var responseBody = await response.stream.bytesToString();
//
//     Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
//
//     // Return the IPFS hash
//     return jsonResponse['IpfsHash'];
//   } catch (error) {
//     print('Error uploading to Pinata: $error');
//   }
//   return null;
// }
}
