import 'package:web3dart/credentials.dart';

class ProductModel {
  late BigInt id;
  late String name;
  late String description;
  late String desprivate;
  late String image;
  late bool sell;
  late bool bid;
  late bool active;
  late EthereumAddress owner;
  late BigInt price;
  late String category;
  late String qr;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.desprivate,
    required this.image,
    required this.sell,
    required this.bid,
    required this.active,
    required this.owner,
    required this.price,
    required this.category,
    required this.qr,
  });
}
