import 'dart:ui';

import 'package:flutter/material.dart';

class Vote extends StatefulWidget {
  const Vote({Key? key}) : super(key: key);

  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  int selected = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, top: 25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Voting",
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            ?.copyWith(color: const Color(0xFFB998FF)),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Choose the party you want to vote ",
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(color: const Color(0xFFB998FF)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selected = index;
                          });
                        },
                        child: Container(
                          child: Center(
                              child: Text(
                            "PartyName",
                            style:
                                TextStyle(fontSize: 30, color: Colors.white70),
                          )),
                          height: 90,
                          decoration: BoxDecoration(
                              color: selected == index
                                  ? Color(0xFFB998FF)
                                  : Colors.black54,
                              border: Border.all(color: Color(0xFFB998FF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Dialog confirmation = Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12.0)), //this right here
                      child: Container(
                        height: 200.0,
                        width: 200.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                'Are you sure you want to vote for this party?',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 50.0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                        color: Color(0xFFB998FF),
                                        fontSize: 18.0),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Yes!',
                                    style: TextStyle(
                                        color: Color(0xFFB998FF),
                                        fontSize: 18.0),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => confirmation);
                  },
                  child: Text(
                    "Cast Vote",
                    style: TextStyle(color: Colors.white70),
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFFB998FF))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
