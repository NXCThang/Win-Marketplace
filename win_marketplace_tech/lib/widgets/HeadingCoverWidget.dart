import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/text/w3m_address.dart';
import 'package:web3modal_flutter/widgets/web3modal.dart';

import '../services/ContractFactoryServies.dart';
import '../utils/Constants.dart';
import 'CustomButtonWidget.dart';

class HeadingCoverWidget extends StatefulWidget {
  const HeadingCoverWidget({Key? key}) : super(key: key);

  @override
  State<HeadingCoverWidget> createState() => _HeadingCoverWidgetState();
}

class _HeadingCoverWidgetState extends State<HeadingCoverWidget> {
  Constants constants = Constants();
  late W3MService _w3mService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _intialzeWeb3Model();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {

      });
    });
  }

  bool connected = false;

  void _setStatus() {
    setState(() {
      connected = _w3mService.isConnected;
    });
  }

  //Intialize web3model object
  void _intialzeWeb3Model() async {
    W3MChainPresets.chains.putIfAbsent("11155111", () => _sepoliaChain);
    _w3mService = W3MService(
      projectId: '6f427ccb9e72b1453b0e3c76b70a8741',
      metadata: const PairingMetadata(
        name: 'Arabic Dapp Token',
        description: 'send erc20 or peb20 to friends',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutter_blockchain_2024://', // your own custom scheme
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );
    await _w3mService.init();
  }

  // void sigMessage() async {
  //   await _w3mService.launchConnectedWallet();
  //
  //   var hash = await _w3mService.web3App!.request(
  //     topic: _w3mService.session?.topic ?? "default_topic",
  //     chainId: 'eip155:$_chainId',
  //     request: const SessionRequestParams(
  //       method: 'personal_sign',
  //       params: ['Welcome to Win Marketplace Technology'],
  //     ),
  //   );
  //   debugPrint(hash);
  // }

  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return Stack(
      //alignment: Alignment.bottomRight,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.40,
          width: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/cover.png"),
                  fit: BoxFit.cover,
                  scale: 1)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
            ),
            // (_w3mService.isConnected)
            //     ? Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     W3MNetworkSelectButton(service: _w3mService),
            //     W3MAccountButton(service: _w3mService),
            //   ],
            // )
            //     :
            SizedBox(
              height: 80,
            ),
            //SizedBox(height: 2,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: Text(
                        "Discovery Web3 Products",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ),
                W3MConnectWalletButton(
                  service: _w3mService,
                  state: ConnectButtonState.none,
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: W3MAccountButton(
                service: _w3mService,
              ),
            ),
            // TextButton(onPressed: (){
            //   print(_w3mService.session?.address);
            //   if(_w3mService.isConnected){
            //     contractFactory.saveAccountAddress(_w3mService.session!.address.toString());
            //     print(contractFactory.myAccount);
            //   }else{
            //     contractFactory.saveAccountAddress(null.toString());
            //     print(contractFactory.myAccount);
            //   }
            // }, child: Text("Test")),
            InkWell(
              onTap: (){}, // Đây là sự kiện bạn muốn gọi khi tap vào widget này
              child: TextButton(
                onPressed: () {

                },
                child: Text(_w3mService.isConnected.toString()),
              ),
            )
          ],
        )
      ],
    );
  }
}

const _chainId = "11155111";

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
