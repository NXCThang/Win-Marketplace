import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

import '../../services/ContractFactoryServies.dart';
import '../../services/Models/ProductModel.dart';
import '../../utils/Constants.dart';
import '../Product/ProductDetailsPage.dart';
import '../Profile/ProfileOtherPage.dart';
import '../Profile/ProfilePage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  Constants constants = Constants();
  late final ContractFactoryServies _contractFactoryServies =
      ContractFactoryServies();
  DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Authors');
  List<Map<dynamic, dynamic>> _author = [];

  List<ProductModel> searchResults = [];

  Future<void> _searchProducts() async {
    String keyword = _searchController.text.toLowerCase();
    searchResults.clear();
    for (var product in _contractFactoryServies.allProducts) {
      if (product.name.toLowerCase().contains(keyword)) {
        searchResults.add(product);
        // } else if (!product.description
        //     .toLowerCase()
        //     .contains(keyword.toLowerCase())) {
        //   searchResults.add(product);
      }
    }
    setState(() {
      print(searchResults.length);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchAuthors() async {
    String keyword = _searchController.text.toLowerCase();
    _dbRef.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      _author.clear();
      Map<dynamic, dynamic> values = snapshot.value as Map;
      if (values != null) {
        values.forEach((key, value) {
          if (value['address'].toLowerCase().contains(keyword)) {
            _author.add({
              'key': key,
              'address': value['address'],
              'link_facebook': value['link_facebook'],
              'link_other': value['link_other'],
            });
          }
        });
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        backgroundColor: constants.brandColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    await _searchProducts();
                    _searchAuthors();
                    setState(() {});
                  },
                ),
              ),
              onSubmitted: (value) async {
                await _searchProducts();
                _searchAuthors();
                setState(() {});
              },
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Products: "+searchResults.length.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            (searchResults.isNotEmpty)
                ? Container(
                  height: searchResults.length * 50.0,
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsPage(
                                              product: searchResults[index],
                                            )));
                              },
                              child: Text(searchResults[index].name)),
                        );
                      },
                    ),
                  )
                : Text('No product'),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Authors: ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            (_author.isNotEmpty)
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _author.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            if (_author[index]['address'] ==
                                contractFactory.myAccount) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Profile()));
                            } else {
                              contractFactory.getUserOtherProducts(
                                  _author[index]['address']);
                              print(contractFactory.allUserProducts.length);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileOther(
                                          account: _author[index]['address'])));
                            }
                          },
                          child: ListTile(
                            title: Row(
                              children: [
                                Row(
                                  children: [
                                    RandomAvatar(_author[index]['address'],
                                        height: 50, width: 50),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      _author[index]['address'],
                                      style: TextStyle(
                                          color: constants.mainGrayColor,
                                          fontSize: 10),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Text('No author'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
