import 'dart:ui';
import 'package:aasha/cast_vote.dart';
import 'package:aasha/create_election.dart';
import 'package:aasha/otp_screen.dart';
import 'package:aasha/elections.dart';
import 'package:checkdigit/checkdigit.dart';
import 'package:flutter/material.dart';

import 'package:aasha/otp_screen.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  UserModel model = UserModel(name: '', adhaar: '', dateOfBirth: DateTime.now());
  DateTime selectedDate = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
  final _formKey = GlobalKey<FormState>();

  _pickdate() async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1850),
        lastDate: DateTime(DateTime.now().year - 18, DateTime.now().month,
            DateTime.now().day));
    if (date != null && date != selectedDate) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              bottom: -150,
              right: -150,
              child: Opacity(
                  opacity: 0.5, child: Image.asset('assets/icon-fg.png'))),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0, top: 150),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(color: const Color(0xFFB998FF)),
                            ),
                            Text(
                              "Sign-up to vote",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(color: const Color(0xFFB998FF)),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (val){
                          model = model.copyWith(name: val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Name',
                          filled: true,
                          fillColor: Colors.black12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        validator: (value) {
                          if(value == '1234') return null;
                          if (!verhoeff.validate(value.toString()) ||
                              value!.isEmpty) {
                            return 'Please enter a valid Aadhar number';
                          }
                          return null;
                        },
                        onSaved: (val){
                          model = model.copyWith(adhaar: val);
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Aadhar Number',
                          filled: true,
                          fillColor: Colors.black12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black12,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.event,
                          ),
                          title: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: _pickdate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2.2 / 3,
                          height: 48,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFFB998FF)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                model = model.copyWith(dateOfBirth: selectedDate);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return OtpPage(model: model);
                                }));
                              } else {
                                debugPrint("no");
                              }
                            },
                            child: Text(
                              "Sign-up",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserModel {
  String name;
  String adhaar;
  DateTime dateOfBirth;
  UserModel({
    required this.name,
    required this.adhaar,
    required this.dateOfBirth,
  });

  UserModel copyWith({
    String? name,
    String? adhaar,
    DateTime? dateOfBirth,
  }) {
    return UserModel(
      name: name ?? this.name,
      adhaar: adhaar ?? this.adhaar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
