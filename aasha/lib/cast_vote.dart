import 'dart:math';
import 'dart:ui';

import 'package:aasha/blockchain_service.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Vote extends StatefulWidget {
  final DeployedContract contract;
  const Vote({
    Key? key,
    required this.contract,
  }) : super(key: key);

  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  int selected = -1;
  bool loading = false;
  List<dynamic> partiesHashes = [];
  Map<dynamic, String> partyNames = {};

  @override
  void initState() {
    loadParties();
    super.initState();
  }

  void loadParties() async {
    setState(() {
      loading = true;
    });
    partiesHashes =
        await BlockchainService.instance.getParties(widget.contract);
    await Future.wait(partiesHashes.map((e) async {
      if (partyNames.containsKey(e)) {
        return;
      }
      partyNames[e] =
          await BlockchainService.instance.getPartyName(widget.contract, e);
    }));
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, top: 25),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Voting",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    "Choose the party you want to vote ",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : partiesHashes.isEmpty
                        ? const Center(
                            child: Text('No parties have registered yet'))
                        : ListView.builder(
                            itemCount: partiesHashes.length,
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
                                      partyNames[partiesHashes[index]]
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(color: Colors.white70),
                                    )),
                                    height: 75,
                                    decoration: BoxDecoration(
                                        color: selected == index
                                            ? const Color(0xFFB998FF)
                                            : Colors.black54,
                                        border: Border.all(
                                          color: selected == index
                                              ? const Color(0xFFB998FF)
                                              : const Color(0xFF7CFDF2),
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
                                ),
                              );
                            })),
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton(
                    onPressed: () async {
                      if (selected == -1) {
                        return;
                      }
                      Dialog confirmation = Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12.0)), //this right here
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Are you sure you want to vote for ${partyNames[partiesHashes[selected]]} party?',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              Image.asset(
                                'assets/hand-holding-a-phone.png',
                                width: 128,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text(
                                      'No',
                                      style: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text(
                                      'Yes!',
                                      style: TextStyle(
                                        color: Color(0xFFB998FF),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                      final response = await showDialog(
                          context: context,
                          builder: (BuildContext context) => confirmation);
                      if (response) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => RegisterVote(
                                  contract: widget.contract,
                                  partyHash: partiesHashes[selected],
                                )));
                      }
                    },
                    child: const Text(
                      "Cast Vote",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFB998FF)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterVote extends StatelessWidget {
  final DeployedContract contract;
  final dynamic partyHash;
  const RegisterVote(
      {Key? key, required this.contract, required this.partyHash})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(),
        ),
        body: FutureBuilder<String>(
            future: BlockchainService.instance.voteParty(contract, partyHash),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF7CFDF2)));
              }
              if (snap.hasError) {
                return Center(
                    child: Text('Unable to vote. Try again.\n${snap.error}'));
              }
              return VoteRegistered(
                transactionId: snap.data!,
              );
            }));
  }
}

class VoteRegistered extends StatelessWidget {
  final String transactionId;
  const VoteRegistered({Key? key, required this.transactionId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TopCenterConfetti(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Congratulations!',
                  style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: const Color(0xFFB998FF),
                      fontWeight: FontWeight.bold),
                ),
                Image.asset('assets/fist-bump.png'),
                Text(
                  'You\'ve successfully cast your vote!',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'This transaction ID is proof of your vote:',
                  style: TextStyle(color: Colors.white70),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Text(
                      'Txn id: $transactionId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),),
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(
                                  const ClipboardData(text: 'Some Text'))
                              .then((value) => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Text('Copied to clipboard'))));
                        },
                        icon: const Icon(Icons.copy))
                  ],
                )
              ],
            ),
          )),
    );
  }
}

class TopCenterConfetti extends StatefulWidget {
  final Widget child;
  const TopCenterConfetti({Key? key, required this.child}) : super(key: key);

  @override
  _TopCenterConfettiState createState() => _TopCenterConfettiState();
}

class _TopCenterConfettiState extends State<TopCenterConfetti> {
  late ConfettiController controller;
  @override
  void initState() {
    controller = ConfettiController(duration: const Duration(seconds: 2));
    controller.play();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.orange,
              Colors.purple
            ],
            blastDirection: pi / 2,
            numberOfParticles: 20,
          ),
        ),
        widget.child,
      ],
    );
  }
}
