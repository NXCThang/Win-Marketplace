import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:win_marketplace_tech/pages/Calendar/CalendarPage.dart';
import 'package:win_marketplace_tech/pages/Home/CategoryProductsPage.dart';
import 'package:win_marketplace_tech/pages/Product/CreateProductPage.dart';
import 'package:win_marketplace_tech/pages/Profile/ProfilePage.dart';
import 'package:win_marketplace_tech/pages/Search/SearchPage.dart';
import 'package:win_marketplace_tech/utils/Constants.dart';
import 'package:win_marketplace_tech/widgets/HeadingCoverWidget.dart';

import '../../services/ContractFactoryServies.dart';
import '../../widgets/CustomLoaderWidget.dart';
import '../../widgets/CustomProductCardWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  Constants constants = Constants();

  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    var account = contractFactory.myAccount;
    return Scaffold(
      body:(currentIndex == 0)
          ? DisCoveryPage()
          : (currentIndex == 1)
          ? const SearchPage()
      :(currentIndex ==2)
        ? const Calendar()
          : const Profile(),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(constants.bottomMenu[0]['icon']),
            title: Text(constants.bottomMenu[0]['label']),
            activeColor: constants.brandColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(constants.bottomMenu[1]['icon']),
            title: Text(constants.bottomMenu[1]['label']),
            activeColor: constants.brandColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(constants.bottomMenu[2]['icon']),
            title: Text(constants.bottomMenu[2]['label']),
            activeColor: constants.brandColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(constants.bottomMenu[3]['icon']),
            title: Text(constants.bottomMenu[3]['label']),
            activeColor: constants.brandColor,
            textAlign: TextAlign.center,
          )
        ],
        onItemSelected: (index) async {
          if (index == 0) {
            //nft.getSubscriptions();
          } else if (index == 2) {
            //status.setProfile(true);
            //nft.getMyProfile();
            // nft.getMyNfts(dummyAddress);
            // nft.getCollectables(dummyAddress);
          }
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class DisCoveryPage extends StatefulWidget {
  const DisCoveryPage({super.key});

  @override
  State<DisCoveryPage> createState() => _DisCoveryPageState();

}

class _DisCoveryPageState extends State<DisCoveryPage> {
  @override
  void initState() {
    super.initState();
  }
  Constants constants = Constants();
  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constants.brandColor,
        title: Text("Win Market Tech"),
      ),
      backgroundColor: constants.mainBGColor,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     //contractFactory.getUserProducts();
      //     // print(contractFactory.allUserProducts.length);
      //     //contractFactory.CreateProduct("Product Test 2", constants.mokeParagraph, constants.imageMoke, "0.2", "Games", constants.qr);
      //     //Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateProductPage()));
      //   },
      //   backgroundColor: constants.brandColor,
      //   child: Icon(
      //     Icons.add,
      //     size: 40,
      //     color: constants.mainBlackColor,
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //HeadingCoverWidget(),
            Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 10),
              child: Text(
                "Categories",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Container(
              height: 40,
              child: ListView.builder(
                  itemCount: constants.categoryList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 8),
                      child: InkWell(
                        onTap: (){
                          contractFactory.getCategoryProducts(constants.categoryList[index]);
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryProductsPage(categoryName: constants.categoryList[index])));
                        },
                        child: Text(
                          constants.categoryList[index],
                          style: TextStyle(
                              fontSize: 15, color: constants.mainGrayColor),
                        ),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Newest Products",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  contractFactory.storeNameLoading?customLoaderWidget():Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: Text(
                      "Win Tech",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: AlignedGridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  padding: EdgeInsets.all(15),
                  itemCount: contractFactory.allProducts.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 2,
                  itemBuilder: (context, index) {
                    return customProductCardWidget(
                        context,contractFactory.allProducts[index].image, "# "+contractFactory.allProducts[index].id.toString(), contractFactory.allProducts[index].price.toString(),contractFactory.allProducts[index]);
                  }),
            )
          ],
        ),
      ),
    );
  }
}


