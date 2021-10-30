import 'dart:convert';
import 'dart:typed_data';

import 'package:aasha/blockchain_service.dart';
import 'package:aasha/register.dart';
import 'package:flutter/material.dart';

class OtpPage extends StatefulWidget {
  final UserModel model;
  const OtpPage({Key? key, required this.model}) : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool loading = false;

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
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 42,
                    ),
                    Text(
                      'Verification',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please enter the OTP sent to registered mobile number",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _textFieldOTP(true, false, context),
                              _textFieldOTP(false, false, context),
                              _textFieldOTP(false, false, context),
                              _textFieldOTP(false, true, context)
                            ],
                          ),
                          const SizedBox(
                            height: 22,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                //TODO: Get IPFS HASH
                                try {
                                  await BlockchainService.instance.registerUser(
                                      "QmXwF1otuvKu5LtumFhHGrPkJUDvbV3x82JFCahkHF9sCT", widget.model.adhaar);
                                      debugPrint('PROCESSED');
                                } catch (e) {
                                  setState(() {
                                    loading = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Unable to process request: ${e.toString()}')));
                                }
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFFB998FF)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Text(
                                  'Verify and register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Text(
                      "Didn't you receive any code?",
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: Colors.white70,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "Resend New Code",
                        style: Theme.of(context).textTheme.subtitle2?.copyWith(
                              color: const Color(0xFFB998FF),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _textFieldOTP(bool first, bool last, BuildContext context) {
  return SizedBox(
    height: 60,
    child: AspectRatio(
      aspectRatio: 1.0,
      child: TextField(
        autofocus: true,
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
        showCursor: false,
        readOnly: false,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counter: const Offstage(),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.black12),
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Color(0xFFB998FF)),
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
  );
}
