import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/ContractFactoryServies.dart';
import '../../utils/Constants.dart';
import 'BidDetails.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Query dbRef = FirebaseDatabase.instance.ref().child('Bids');
  DatabaseReference reference =
  FirebaseDatabase.instance.ref().child('Bids');
  late final ContractFactoryServies _contractFactoryServies = ContractFactoryServies();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  Widget listItem({required Map bid}) {
    DateTime endTime = DateFormat('HH:mm:ss dd-MM-yyyy').parse(bid['time_end']);
    Duration difference = endTime.difference(DateTime.now());
    String timeDifference = _formatDuration(difference);
    return GestureDetector(
      onTap: () async{
        Navigator.push(context, MaterialPageRoute(builder: (context)=> BidsDetails(bidKey: bid['key'])));
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.20,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(bid['image']),
                  fit: BoxFit.cover,
                  scale: 1,
                )
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Current Price", style: TextStyle(fontWeight:FontWeight.bold, color: Colors.white),),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(' '+bid['current_price']+' ETH',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(timeDifference,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }

  Constants constant = Constants();
  @override
  Widget build(BuildContext context) {
    var contractFactory = Provider.of<ContractFactoryServies>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: constant.brandColor,
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
            Map bid = snapshot.value as Map;
            bid['key'] = snapshot.key;
            DateTime endTime = DateFormat('HH:mm:ss dd-MM-yyyy').parse(bid['time_end']);
            // return listItem(bid: bid);
            if (!DateTime.now().isBefore(endTime)) {
              return SizedBox();
            } else {
              Duration difference = DateTime.now().difference(endTime);
              String timeDifference = _formatDuration(difference);
              return listItem(bid: bid);
            }
          },
        ),
      ),
    );
  }

  // Hàm để định dạng Duration thành chuỗi dễ đọc
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:${twoDigitMinutes}:${twoDigitSeconds}";
  }
}
