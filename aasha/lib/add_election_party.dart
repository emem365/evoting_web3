import 'package:aasha/blockchain_service.dart';
import 'package:aasha/cast_vote.dart';
import 'package:aasha/elections.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class AddElectionParty extends StatelessWidget {
  const AddElectionParty({Key? key}) : super(key: key);
  Future<ElectionInfo> getElectionInfo(DeployedContract contract) async {
    return ElectionInfo(
        name: await BlockchainService.instance.getElectionName(contract),
        deadline: await BlockchainService.instance
            .getUserDeadlineForElection(contract),
        hasVoted:
            await BlockchainService.instance.getHasVotedOnContract(contract));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 56,
          ),
          Text(
            "Create party for election",
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(
            height: 24,
          ),
          Expanded(
            child: FutureBuilder<List<DeployedContract>>(
                future: BlockchainService.instance.getElectionsInProgress(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7CFDF2),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  return ListView.builder(
                      itemCount: snap.data!.length,
                      itemBuilder: (BuildContext context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    CreateParty(contract: snap.data![index])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              child: FutureBuilder<ElectionInfo>(
                                future: getElectionInfo(snap.data![index]),
                                builder: (context, snap) {
                                  if (snap.hasError) {
                                    return const Center(
                                      child: Text(
                                        'Something went wrong. Please try again',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  }
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF7CFDF2),
                                      ),
                                    );
                                  }
                                  return Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        snap.data?.name ?? 'Election',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            ?.copyWith(
                                              color: Colors.white70,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "Deadline: ${snap.data?.deadline.toString()}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            ?.copyWith(
                                              color: Colors.white54,
                                            ),
                                      ),
                                    ],
                                  ));
                                },
                              ),
                              height: 90,
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  border: Border.all(
                                      color: const Color(0xFF7CFDF2)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                            ),
                          ),
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}

class CreateParty extends StatefulWidget {
  final DeployedContract contract;
  const CreateParty({Key? key, required this.contract}) : super(key: key);

  @override
  _CreatePartyState createState() => _CreatePartyState();
}

class _CreatePartyState extends State<CreateParty> {
  String name = '';
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              bottom: -150,
              left: -150,
              child: Opacity(
                  opacity: 0.5, child: Image.asset('assets/icon-fg.png'))),
          Positioned.fill(
            child: !loading
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 80),
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
                              padding:
                                  const EdgeInsets.only(bottom: 50.0, top: 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Create Party",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(
                                            color: const Color(0xFFB998FF),
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a valid name';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                name = val ?? '';
                              },
                              decoration: InputDecoration(
                                hintText: 'Election Name',
                                filled: true,
                                fillColor: Colors.black12,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 2.2 / 3,
                                height: 48,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFFB998FF)),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState?.save();
                                      setState(() {
                                        loading = true;
                                      });
                                      try {
                                        await BlockchainService.instance
                                            .createParty(widget.contract, name);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Successfully created Election')));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Unable to process: ${e.toString()}')));
                                      } finally {
                                        setState(() {
                                          loading = false;
                                        });
                                      }
                                    } else {}
                                  },
                                  child: Text(
                                    "Create",
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
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
