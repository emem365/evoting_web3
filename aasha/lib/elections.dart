import 'package:aasha/add_election_party.dart';
import 'package:aasha/cast_vote.dart';
import 'package:aasha/create_election.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import 'package:aasha/blockchain_service.dart';

class Elections extends StatefulWidget {
  const Elections({Key? key}) : super(key: key);

  @override
  _ElectionsState createState() => _ElectionsState();
}

class _ElectionsState extends State<Elections> {
  Future<ElectionInfo> getElectionInfo(DeployedContract contract) async {
    return ElectionInfo(
        name: await BlockchainService.instance.getElectionName(contract),
        deadline: await BlockchainService.instance
            .getUserDeadlineForElection(contract));
  }

  List<DeployedContract> elections = [];
  bool loading = false;
  void loadElections() async {
    setState(() {
      loading = true;
    });
    elections = await BlockchainService.instance.getElectionsInProgress();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    loadElections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: CircleAvatar(
                radius: 75,
                backgroundImage: AssetImage('assets/icon.png'),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.download),
              title: Text(
                'Download your VoterID',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateElection()));
              },
              leading: const Icon(Icons.create),
              title: const Text(
                'Create an election',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddElectionParty()));
              },
              leading: const Icon(Icons.add),
              title: const Text(
                'Add a party',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const Spacer(),
            // const SizedBox(height: 4,),
            Text(
              'TEAM OMAE WA MOU SHINDEIRU',
              style: Theme.of(context)
                  .textTheme
                  .overline
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/icon.png'),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('AASHA'),
        actions: [
          IconButton(
              onPressed: () => loadElections(), icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 24,
          ),
          Text(
            "Upcoming elections",
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(
            height: 24,
          ),
          Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7CFDF2),
                      ),
                    )
                  : elections.isEmpty
                      ? const Center(
                          child: Text(
                            'No upcoming elections found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: elections.length,
                          itemBuilder: (BuildContext context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        Vote(contract: elections[index])));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Container(
                                  child: FutureBuilder<ElectionInfo>(
                                    future: getElectionInfo(elections[index]),
                                    builder: (context, snap) {
                                      if (snap.hasError) {
                                        return const Center(
                                          child: Text(
                                            'Something went wrong. Please try again',
                                            style: TextStyle(
                                                color: Colors.white70),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                          }))
        ],
      ),
    );
  }
}

class ElectionInfo {
  String name;
  DateTime deadline;
  ElectionInfo({
    required this.name,
    required this.deadline,
  });

  ElectionInfo copyWith({
    String? name,
    DateTime? deadline,
  }) {
    return ElectionInfo(
      name: name ?? this.name,
      deadline: deadline ?? this.deadline,
    );
  }
}
