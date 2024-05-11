import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web_socket_channel/io.dart';

import '../utils/Constants.dart';
import 'Models/ProductModel.dart';

class ContractFactoryServies extends ChangeNotifier {
  Constants constants = Constants();

  //SHARE DATA
  String? storeName;
  String? myAccount="";
  String myPrivateKey="";
  bool storeNameLoading = true;
  bool storeProductsLoading = true;
  bool productCreatedLoading = false;

  String? myBalance;

  List<ProductModel> allProducts = [];
  List<ProductModel> categoryProducts = [];
  List<ProductModel> allUserProducts = [];
  List<ProductModel> allOthersProducts = [];
  List<ProductModel> allBiddingProducts = [];
  List<ProductModel> oneProducts = [];

  //1-Connect to blockchain Network(https/websocktio/web3dart)

  Web3Client? _cleint;
  String? _abiCode;
  EthereumAddress? _contractAddress;
  DeployedContract? _contract;
  BigInt? _productCount;
  bool? created;

  var uri;


  ContractFactoryServies() {
    _setUpNetwork();
    _initializeWeb3Model();
  }

  saveAccountAddress(String account) {
    myAccount = account;
    notifyListeners();
  }

  _setUpNetwork() async {
    _cleint =
        Web3Client(constants.NETWORK_HTTPS_RPC, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(constants.NETWORK_WSS_RPC)
          .cast<String>();
    });
    await _fetchABIAndContractAdrress();
    await _getDeployedContract();
  }

  //2-Connect with Smart Contract
  //a-get abi and contract address
  Future<void> _fetchABIAndContractAdrress() async {
    String abiFileRoot =
        await rootBundle.loadString(constants.CONTRACT_ABI_PATH);
    var abiJsonFormat = jsonDecode(abiFileRoot);
    _abiCode = jsonEncode(abiJsonFormat["abi"]);

    //Get Address
    _contractAddress = EthereumAddress.fromHex(constants.CONTRACT_ADDRESS);
  }

  //b-take this abi and address to get teh deployed contract
  Future<void> _getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, "MarketplaceProducts"),
        _contractAddress!);
    await _getStoreName();
    await _getStoreProductCount();
    await _getAllProducts();
  }

  //3-Fetch All Functions and Data

//GET STORE NAME FROM BLOCKCHAIN
  _getStoreName() async {
    List<dynamic> storeData = await _cleint!.call(
        contract: _contract!,
        function: _contract!.function("storeName"),
        params: []);

    if (storeData[0].length > 0) {
      storeName = storeData[0];

      storeNameLoading = false;
    } else {
      storeNameLoading = true;
    }
    notifyListeners();
  }

  // File? _image;
  // File? get image => _image;
  //
  // void setImageFile(File newImage) {
  //   _image = newImage;
  //   notifyListeners();
  // }
  //
  // File? _imageQR;
  // File? get imageQR => _imageQR;
  //
  // void setImageQRFile(File newImage) {
  //   _imageQR = newImage;
  //   notifyListeners();
  // }
//GET STORE PRODUCT COUT FROM BLOCKCHAIN
  _getStoreProductCount() async {
    List<dynamic> storeData = await _cleint!.call(
        contract: _contract!,
        function: _contract!.function("count"),
        params: []);

    _productCount = storeData[0];
    print("THE PRODUCT COUNT IS ${_productCount}");
    notifyListeners();
  }

  //GET ALL PRODUCTs DATA FROM BLOCKCHAIN
  _getAllProducts() async {
    try {
      int count = int.parse(_productCount.toString());
      allProducts.clear();
      for (int i = count; i >=1; i--) {
        List<dynamic> product = await _cleint!.call(
            contract: _contract!,
            function: _contract!.function("storeProducts"),
            params: [BigInt.from(i)]);
        if (product[7] == true && product[5]== true) {
          allProducts.add(ProductModel(
            id: product[0],
            name: product[1],
            description: product[2],
            desprivate: product[3],
            image: product[4],
            sell: product[5],
            bid: product[6],
            active: product[7],
            owner: product[8],
            price: product[9],
            category: product[10],
            qr: product[11],
          ));
        }
      }
      storeProductsLoading = false;
    } catch (e) {
      storeProductsLoading = true;
    }
    notifyListeners();
  }

  List<ProductModel> searchProducts(String keyword) {
    List<ProductModel> results = [];

    for (var product in allProducts) {
      if (!product.name.toLowerCase().contains(keyword.toLowerCase())) {
        results.add(product);
      }
    }
    return results;
  }

  ProductModel? oneProduct;
  getOneProducts(String id) async {
    try {
      int count = int.parse(_productCount.toString());
      oneProduct = null;
      for (int i = 1; i <= count; i++) {
        List<dynamic> product = await _cleint!.call(
            contract: _contract!,
            function: _contract!.function("storeProducts"),
            params: [BigInt.from(i)]);

        if (product[0].toString() == id) {
          oneProduct = (ProductModel(
            id: product[0],
            name: product[1],
            description: product[2],
            desprivate: product[3],
            image: product[4],
            sell: product[5],
            bid: product[6],
            active: product[7],
            owner: product[8],
            price: product[9],
            category: product[10],
            qr: product[11],
          ));
          break;
        }
      }
      storeProductsLoading = false;
    } catch (e) {
      storeProductsLoading = true;
    }
    notifyListeners();
    print(oneProduct?.owner.toString());
  }
  _getAllBiddingProducts() async {
    try {
      int count = int.parse(_productCount.toString());
      allBiddingProducts.clear();
      for (int i = count; i >=1; i--) {
        List<dynamic> product = await _cleint!.call(
            contract: _contract!,
            function: _contract!.function("storeProducts"),
            params: [BigInt.from(i)]);

        if (product[6] == true && product[7] == true) {
          allBiddingProducts.add(ProductModel(
            id: product[0],
            name: product[1],
            description: product[2],
            desprivate: product[3],
            image: product[4],
            sell: product[5],
            bid: product[6],
            active: product[7],
            owner: product[8],
            price: product[9],
            category: product[10],
            qr: product[11],
          ));
        }
      }
      storeProductsLoading = false;
    } catch (e) {
      storeProductsLoading = true;
    }

    notifyListeners();
  }

  String resultCreate = "";
  CreateProduct(String privatekey, String account, String name, String description, String desprivate, String image, String price,
      String category, String qr) async {
    final gasPrice =
    EtherAmount.inWei(BigInt.from(50000000000)); // adjust as needed
    try {
      final createFunction = _contract!.function("createProduct");
      EthPrivateKey credentials = EthPrivateKey.fromHex( privatekey);
      final result = await _cleint!.sendTransaction(
        credentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(account),
          contract: this._contract!,
          function: createFunction,
          parameters: [
            name,
            description,
            desprivate,
            image,
            BigInt.from(double.parse(price) * 1000000000),
            category,
            qr
          ],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );
      resultCreate = 'https://sepolia.etherscan.io/tx/'+result.toString();
    } catch (err) {
      resultCreate = err.toString();
    }
    notifyListeners();
  }

  //Buy Product Function

  String resultBuy = "";
  BuyProduct(String privatekey, String account, BigInt id,BigInt amount) async {
    // final gasPrice =
    // EtherAmount.inWei(BigInt.from(50000000000)); // adjust as needed
    // // final gasLimit = 21924; // adjust as needed
    try {
      final buyFunction = _contract!.function("buyProduct");
      EthPrivateKey credentials = EthPrivateKey.fromHex(privatekey);
      if(id!=null){
        final result = await _cleint!.sendTransaction(
          credentials,
          Transaction.callContract(
            from: EthereumAddress.fromHex(account),
            contract: this._contract!,
            function: buyFunction,
            value: EtherAmount.fromBigInt(EtherUnit.gwei, amount),
            parameters: [
              id,
            ], // Adjust parameters accordingly
          ),
          chainId: null,
          fetchChainIdFromNetworkId: true,
        );
        resultBuy = 'https://sepolia.etherscan.io/tx/'+result.toString();
      } else{
        print("Error at Buy product");
      }
    } catch (err) {
      print(err);
      resultBuy = err.toString();
    }
    notifyListeners();
  }

  String resultDelete = "";
  DeleteProduct(String privatekey, String account, BigInt id) async {
    final gasPrice =
    EtherAmount.inWei(BigInt.from(50000000000)); // adjust as needed
    // final gasLimit = 21924; // adjust as needed
    try {
      final deleteFunction = _contract!.function("deleteProduct");
      EthPrivateKey credentials = EthPrivateKey.fromHex(privatekey);

      final result = await _cleint!.sendTransaction(
        credentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(account),
          contract: this._contract!,
          function: deleteFunction,
          parameters: [
            id
          ], // Adjust parameters accordingly
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );
      resultDelete = 'https://sepolia.etherscan.io/tx/'+result.toString();
    } catch (err) {
      resultDelete = err.toString();
    }
    notifyListeners();
  }

  String resultSell = "";
  SellProduct(String privatekey, String account, BigInt id, bool sell ) async {
    try {
      final sellFunction = _contract!.function("sellProduct");
      EthPrivateKey credentials = EthPrivateKey.fromHex(privatekey);

      final result = await _cleint!.sendTransaction(
        credentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(account),
          contract: this._contract!,
          function: sellFunction,
          parameters: [
            id,
            sell
          ], // Adjust parameters accordingly
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );
      resultSell = 'https://sepolia.etherscan.io/tx/'+result.toString();
    } catch (err) {
      resultSell = err.toString();
    }
    print(resultSell);
    notifyListeners();
  }

  String resultBid = "";
  BidProduct(String privatekey, String account, BigInt id, bool bid) async {
    final gasPrice =
    EtherAmount.inWei(BigInt.from(50000000000)); // adjust as needed
    // final gasLimit = 21924; // adjust as needed
    try {
      final bidFunction = _contract!.function("bidProduct");
      EthPrivateKey credentials = EthPrivateKey.fromHex(privatekey);

      final result = await _cleint!.sendTransaction(
        credentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(account),
          contract: this._contract!,
          function: bidFunction,
          parameters: [
            id,
            bid
          ], // Adjust parameters accordingly
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );
      resultBid = 'https://sepolia.etherscan.io/tx/'+result.toString();
    } catch (err) {
      resultBid = err.toString();
    }
    notifyListeners();
  }

  String endBid = "";
  EndBid(String privatekey, String account, BigInt id, String price, String newaccount) async {
    // final gasPrice =
    // EtherAmount.inWei(BigInt.from(50000000000)); // adjust as needed
    // final gasLimit = 21924; // adjust as needed
    try {
      final endbidFunction = _contract!.function("endBid");
      EthPrivateKey credentials = EthPrivateKey.fromHex(privatekey);

      final result = await _cleint!.sendTransaction(
        credentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(account),
          contract: this._contract!,
          function: endbidFunction,
          parameters: [
            id,
            BigInt.from(double.parse(price) * 1000000000),
            EthereumAddress.fromHex(newaccount),
          ], // Adjust parameters accordingly
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );
      endBid = 'https://sepolia.etherscan.io/tx/'+result.toString();
    } catch (err) {
      endBid = err.toString();
    }
    print(endBid);
    notifyListeners();
  }

  String resultSend = "";
  sendToken(String privatekey, String account, String address, BigInt amount) async {
    try {
      EthPrivateKey credentials = EthPrivateKey.fromHex(privatekey);
      final result = await _cleint!.sendTransaction(
          credentials,
          Transaction(
            from: EthereumAddress.fromHex(account),
            to: EthereumAddress.fromHex(address),
            // gasPrice: EtherAmount.inWei(BigInt.parse('20000000000')), // Gas price (in wei)
            // maxGas: 21000, // Gas limit
            value: EtherAmount.fromBigInt(EtherUnit.gwei, amount),
          ),
          chainId: constants.CHAIN_ID);
      print("Done Sent");
      resultSend = 'https://sepolia.etherscan.io/tx/'+result.toString();// Handle the result as needed
    } catch (err) {
      resultSend = err.toString();
    }
    notifyListeners();
    print(resultSend);
  }

  getUserProducts() async {
    try {
      int count = int.parse(_productCount.toString());
      allUserProducts.clear();
      for (int i = 1; i <= count; i++) {
        List<dynamic> product = await _cleint!.call(
            contract: _contract!,
            function: _contract!.function("storeProducts"),
            params: [BigInt.from(i)]);
        if (product[8].toString() ==
            w3mService.session!.address.toString() && product[7]==true) {
          allUserProducts.add(ProductModel(
            id: product[0],
            name: product[1],
            description: product[2],
            desprivate: product[3],
            image: product[4],
            sell: product[5],
            bid: product[6],
            active: product[7],
            owner: product[8],
            price: product[9],
            category: product[10],
            qr: product[11],
          ));
        }
      }
      storeProductsLoading = false;
    } catch (e) {
      storeProductsLoading = true;
    }
    notifyListeners();
  }

  //fetch category products

  getCategoryProducts(String categoryName) async {
    try {
      categoryProducts.clear();
      for (int i = 0; i < allProducts.length; i++) {

        if(allProducts[i].category == categoryName){
          categoryProducts.add(ProductModel(
              id: allProducts[i].id,
              name: allProducts[i].name,
              description: allProducts[i].description,
              desprivate: allProducts[i].desprivate,
              image: allProducts[i].image,
              qr: allProducts[i].qr,
              owner: allProducts[i].owner,
              price: allProducts[i].price,
              category: allProducts[i].category,
              sell: allProducts[i].sell,
              bid: allProducts[i].bid,
              active: allProducts[i].active)
          );
          print(allProducts[i].id);
        }
      }
    } catch (e) {
      print("Error at getCategoryProducts ${e} ");
    }

    notifyListeners();
  }


  List<ProductModel> allUserOtherProducts = [];
  getUserOtherProducts(String account) async {
    try {
      int count = int.parse(_productCount.toString());
      allUserOtherProducts.clear();
      for (int i = 1; i <= count; i++) {
        List<dynamic> product = await _cleint!.call(
            contract: _contract!,
            function: _contract!.function("storeProducts"),
            params: [BigInt.from(i)]);

        if (product[8].toString() == account && product[7]==true) {
          allUserOtherProducts.add(ProductModel(
            id: product[0],
            name: product[1],
            description: product[2],
            desprivate: product[3],
            image: product[4],
            sell: product[5],
            bid: product[6],
            active: product[7],
            owner: product[8],
            price: product[9],
            category: product[10],
            qr: product[11],
          ));
        }
      }
      storeProductsLoading = false;
    } catch (e) {
      storeProductsLoading = true;
    }
    notifyListeners();
    print(allUserOtherProducts.length);
  }

  late String resultUpdate= '';
  UpdateProduct(String privatekey, String account, BigInt id,String name, String description, String desprivate, String image, String price,
      String category, String qr) async {
    final gasPrice =
    EtherAmount.inWei(BigInt.from(50000000000)); // adjust as needed
    try {
      final updateFunction = _contract!.function("updateProduct");
      EthPrivateKey credentials = EthPrivateKey.fromHex( privatekey);
      final result = await _cleint!.sendTransaction(
        credentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(account),
          contract: this._contract!,
          function: updateFunction,
          parameters: [
            id,
            name,
            description,
            desprivate,
            image,
            BigInt.from(double.parse(price) * 1000000000),
            category,
            qr
          ],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );
      resultUpdate ='https://sepolia.etherscan.io/tx/'+result.toString();
    } catch (err) {
      resultUpdate = err.toString();
    }
    notifyListeners();
  }
  // Connect
  late W3MService _w3mService;

  Future<void> _initializeWeb3Model() async {
    W3MChainPresets.chains.putIfAbsent("11155111", () => _sepoliaChain);
    _w3mService = W3MService(
      projectId: '6f427ccb9e72b1453b0e3c76b70a8741',
      metadata: const PairingMetadata(
        name: 'Win Marketplace Tech',
        description: 'Connect Win Marketplace Tech',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutter_blockchain_2024://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );
    await _w3mService.init();
    notifyListeners();
  }


  static const _chainId = "11155111";

  final _sepoliaChain = W3MChainInfo(
    chainName: 'Sepolia',
    namespace: 'eip155:$_chainId',
    chainId: _chainId,
    tokenName: 'Sepolia ETH',
    rpcUrl: 'https://rpc.sepolia.org/',
    blockExplorer: W3MBlockExplorer(
      name: 'Sepolia Explorer',
      url: 'https://sepolia.etherscan.io/',
    ),
  );


  W3MService get w3mService => _w3mService;

  // void signMessage() async{
  //   await _w3mService.launchConnectedWallet();
  //   var hash = await _w3mService.web3App!.request(
  //     topic: _w3mService.session?.topic??"default_topic",
  //     chainId: 'eip155:$_chainId',
  //     request: const SessionRequestParams(
  //       method: 'personal_sign',
  //       params: ['welcome NXCT', '0x63cF6B47f5b97ec97212Ae91A7aCAe7e1Be68787'],
  //     ),
  //   );
  //   debugPrint(hash);
  //   print(hash.toString());
  // }

}
