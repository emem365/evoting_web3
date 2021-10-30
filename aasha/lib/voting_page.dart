import 'package:flutter/material.dart';

class Elections extends StatefulWidget {
  const Elections({Key? key}) : super(key: key);

  @override
  _ElectionsState createState() => _ElectionsState();
}

class _ElectionsState extends State<Elections> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
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
          Text(
            "Elections",
            style: Theme.of(context).textTheme.headline5?.copyWith(
                color: Color(0xFFB998FF),
                fontWeight: FontWeight.bold,
                fontSize: 30),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
                itemCount: 4,
                itemBuilder: (BuildContext context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Center(
                          child: Text(
                        "Election",
                        style: TextStyle(fontSize: 30, color: Colors.white70),
                      )),
                      height: 90,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Color(0xFFB998FF)),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
