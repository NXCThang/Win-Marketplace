
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  final APP_NAME = "Win Marketplace Tech";
  //=======>Blockchain Data

  //Contract Data
  //final CONTRACT_ADDRESS = "0xAFf626E85EbB7021DF2AA7994E33194CCeb268Be";
  // "0x37369b8a6befccc4c5d4a6d0e9284e5b002e795f";
  final ADMIN_ADDRESS = "0xb9ecbee524c2467d88a30e2d929bd19ea938e5ca";
  final CONTRACT_ADDRESS = "0xC24df8d1538748696AbA13FEFE6AE567Efd53707";
  final CONTRACT_ABI_PATH = "images/abis/MarketplaceTech.json";
  final WALLET_ADDRESS = "0xb9ecbeE524c2467d88a30e2d929bD19eA938E5ca";
  final WALLET_ADDRESS_02 = "0x18882A13495b1f594B4d0e40F9a2e729930E3cA3";
  final PRIVATE_KEY="28207ee2afae70d9bdca19334e29c9f80b4f27bacc5419c476a07367e13baaf7";
  final WALLET_ADDRESS_03 = "0xEbb353347C9b632E38c1AE3D4AcD3D651Cf7fD05";

  //Blockchain Network Data
  final NETWORK_HTTPS_RPC = "https://sepolia.infura.io/v3/24517b325a5c46d8b8e02d72ab4b9000";
  final  NETWORK_WSS_RPC = "wss://sepolia.infura.io/ws/v3/24517b325a5c46d8b8e02d72ab4b9000";
  final CHAIN_ID =11155111;
  final imageMoke = "https://images.unsplash.com/photo-1618042164219-62c820f10723?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1374&q=80";

  //PINATA DATA
  final PINATA_API_KEY ='a966f01f8747a36bdef6';
  final PINATA_SECRET_API_KEY = '9aa51a9361041b8302fadf496cccca394b6d578fb61fa00d20a44986a586de45';
  final PINATA_END_POINT_API ="https://api.pinata.cloud/pinning/pinFileToIPFS";
  final PINATA_FETCH_IMAGE_URL = "https://gateway.pinata.cloud/ipfs/";
  // final PINATA_API_KEY = "2de3703bc07f4980a6b7";
  // final PINATA_API_SECRET_KEY ="7604844091d8a0c3d74930d8847eed12e85bf33db479b44792e7bec211d836a3";
  // // final PINATA_API_KEY = "269bcbc265d98a3e894f";
  // // final PINATA_API_SECRET_KEY ="381719c690cfb02732633f069b7a5f74d2142784bcbcfbd769b138365e0820f7";
  // final PINATE_END_POINT_API ="https://api.pinata.cloud/pinning/pinFileToIPFS";
  // final PINATE_FETCH_IMAGE_URL = "https://gateway.pinata.cloud/ipfs/";


  //========>
  final mainYellowColor =  Color(0xffF1B026);
  final mainBlackColor =  Color(0xff08090B);
  final mainGrayColor =  Color(0xffA2A9C2);
  final mainBGColor =  Color(0xffF4F4F5);
  final mainWhiteGColor =  Color(0xffF8F1FC);
  final mainButttonColor =  Color(0xffF8F0FD);
  final mainRedColor =  Color(0xffC2161E);

  final brandColor = Color(0xff38b6ff);
  final themeColor = Color(0xff02457a);
  final secondaryColor = Color(0xff3c3d46);
  final plainColor = Color(0xffffffff);
  final dShadeColor = Color(0xff545454);
  final dangerColor = Color(0xff800200);
  final darkColor = Color(0xff545454);

  String? bodyFont = GoogleFonts.quicksand().fontFamily;

  final List<String> categoryList = <String>[
    "Games","Art","AI", "IOT","Sport","3D","Photograpghy","Green Tech","Collectables"
  ];

  final List<Map<String, dynamic>> bottomMenu = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.search, 'label': 'Search'},
    {'icon': Icons.calendar_month_outlined, 'label': 'Calendar'},
    {'icon': Icons.account_circle_outlined, 'label': 'My Profile'},
  ];

  final linklogo = 'https://gateway.pinata.cloud/ipfs/QmU5QXLAnPrLFdZTKHcfMJH6vr9CYnnhiovyRv8ZYMtFDy';
  final qr = "https://amber-peaceful-puma-873.mypinata.cloud/ipfs/QmcyxdycqyeGUgM69Dx7uUJovuCpRheSwNFWcpjKrdgME8?pinataGatewayToken=mGDsveD8W5HMnxy4z5a4go62-gHn2ZXWILNsRyd_NpDdLVMHCiXNEW0_RIXlaZ7_";
  final mokeParagraph = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries,";
}