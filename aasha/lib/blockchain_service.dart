import 'package:aasha/secrets.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class BlockchainService {
  static BlockchainService? _instance;

  BlockchainService._();

  static BlockchainService get instance {
    _instance = _instance ?? BlockchainService._();
    return _instance!;
  }

  final String _rpcUrl =
      'https://ropsten.infura.io/v3/b8e3788847454d999851078493cd7800';
  final String _wsUrl =
      'wss://ropsten.infura.io/ws/v3/b8e3788847454d999851078493cd7800';

  final createElectionContractAddress =
      EthereumAddress.fromHex('0x037d0F2FBd7d983e095F7Fe4fffA0C181Df3314C');
  final registerContractAddress =
      EthereumAddress.fromHex('0xc916249D121eE1e7630DAC2921c416F9Ca9F8768');

  // Remove these somehow
  final EthPrivateKey _myPrivateKey = EthPrivateKey.fromHex(
      PRIVATE_KEY);
  final EthereumAddress _myPublicAddress =
      EthereumAddress.fromHex(PUBLIC_KEY);

  Web3Client? _client;
  DeployedContract? createElectionContract;
  DeployedContract? registerContract;

  Future<void> init() async {
    _client = _client ?? Web3Client(_rpcUrl, Client());
    await loadContracts();
  }

  Future<void> loadContracts() async {
    String createElectionContractAbi =
        await rootBundle.loadString('assets/abis/electionContractAbi.json');
    String registerContractAbi =
        await rootBundle.loadString('assets/abis/registerContractAbi.json');

    createElectionContract = DeployedContract(
        ContractAbi.fromJson(createElectionContractAbi, 'createElection'),
        createElectionContractAddress);
    registerContract = DeployedContract(
        ContractAbi.fromJson(registerContractAbi, 'Register'),
        registerContractAddress);
  }

  Future<List<dynamic>> queryCreateElectionContract(
      String functionName, List<dynamic> args) async {
    assert(createElectionContract != null);
    return queryContract(createElectionContract!, functionName, args);
  }

  Future<List<dynamic>> getElectionsFromCreateElection() async {
    List<dynamic> results =
        await queryCreateElectionContract('getdeployedContracts', []);
    return results[0];
  }

  Future<List<dynamic>> queryRegisterContract(
      String functionName, List<dynamic> args) async {
    assert(registerContract != null);
    return queryContract(registerContract!, functionName, args);
  }

  Future<bool> isUserRegistered() async {
    assert(registerContract != null);
    final results =
        await queryRegisterContract('registeredUser', [_myPublicAddress]);

    return results[0] == 'true';
  }

  Future<void> registerUser(String ipfsHash, String adhaar) async {
    assert(registerContract != null);
    assert(_client != null);
    final ethFunction = registerContract!.function('registerUser');
    await _client!.sendTransaction(
        _myPrivateKey,
        Transaction.callContract(
          contract: registerContract!,
          function: ethFunction,
          parameters: [ipfsHash, _myPrivateKey.publicKey, adhaar],
        ));
  }

  Future<List<DeployedContract>> getElectionsInProgress() async {
    final elections = await getElectionsFromCreateElection();
    List<DeployedContract> contracts = [];
    String votingContractAbi =
        await rootBundle.loadString('assets/abis/votingsContractAbi.json');
    for (var election in elections) {
      final contract = DeployedContract(
          ContractAbi.fromJson(votingContractAbi, 'Voting'),
          election);
      final response = await queryContract(contract, 'deadlineforUsers', []);
      final deadline = dateTimeFromUnixTimestamp(response[0]);
      if(deadline.isAfter(DateTime.now())){
        contracts.add(contract);
      }
    }
    return contracts;
  }

  Future<List<dynamic>> queryContract(DeployedContract contract, 
      String functionName, List<dynamic> args) async {
    assert(_client != null);
    final ethFunction = contract.function(functionName);
    final result = await _client!
        .call(contract: contract, function: ethFunction, params: args);
    return result;
  }



  DateTime dateTimeFromUnixTimestamp(BigInt b) => DateTime.fromMillisecondsSinceEpoch(b.toInt()*1000);

}
