import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';
import 'package:win_marketplace_tech/widgets/CustomButtonWidget.dart';

class UpdateAuthor extends StatefulWidget {
  const UpdateAuthor({Key? key, required this.address}) : super(key: key);

  final String address;

  @override
  State<UpdateAuthor> createState() => _UpdateAuthorState();
}

class _UpdateAuthorState extends State<UpdateAuthor> {
  final addressController = TextEditingController();
  final facebookLinkController = TextEditingController();
  final otherLinkController = TextEditingController();
  late Uri fblink = Uri.parse('');
  late Uri otherlink = Uri.parse('');

  DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Authors');
  Map<String, Map<String, dynamic>> _Authors = {};
  bool _isLoading = true;
  String? _AuthorKey; // Store the key of the Author being edited

  void _searchAuthors() {
    if (widget.address.isNotEmpty) {
      String keyword = widget.address.toLowerCase();
      _dbRef.onValue.listen((event) {
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic> values = snapshot.value as Map;
        _Authors.clear();
        if (values != null) {
          bool addressFound = false;
          values.forEach((key, value) {
            if (value['address'].toLowerCase() == keyword) {
              addressFound = true;
              _Authors[key] = {
                'key': key,
                'address': value['address'],
                'link_facebook': value['link_facebook'],
                'link_other': value['link_other'],
              };
              print(value['link_facebook']);
              setState(() {
                _AuthorKey = key; // Update the Author key
                addressController.text = value['address'];
                facebookLinkController.text = value['link_facebook'];
                otherLinkController.text = value['link_other'];
              });
            }
          });
          if (!addressFound) {
            // Nếu không tìm thấy địa chỉ trên Firebase, thêm một Author mới
            _addNewAuthor(keyword);
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
      });
    }
  }

  void _addNewAuthor(String address) {
    _dbRef.push().set({
      'address': address,
      'link_facebook': '',
      'link_other': '',
    }).then((_) {
      print('New Author added');
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      print('Failed to add new Author: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _searchAuthors();
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

  Constants constants = Constants();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: addressController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  hintText: 'Enter Your Name',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: facebookLinkController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Link Facebook',
                  hintText: 'Enter Your Link',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: otherLinkController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Other Link',
                  hintText: 'Enter Your Link',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: customButtonWidget(() {
                  if (_AuthorKey != null) {
                    Map<String, String> students = {
                      'address': addressController.text,
                      'link_facebook': facebookLinkController.text,
                      'link_other': otherLinkController.text
                    };

                    _dbRef.child(_AuthorKey!).update(students).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: constants.brandColor,
                            content: Text('Successful.'),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)
                            )
                        ),
                      );
                      Navigator.pop(context);
                    }).catchError((error) {
                      print('Failed to update Author: $error');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.of(context).pop();
                          });
                          return AlertDialog(
                            title: Text(
                              'Error',
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text('Failed to update Author'),
                          );
                        },
                      );
                    });
                  }
                }, 15, constants.brandColor, "UPDATE", constants.mainWhiteGColor, 300)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
