import 'dart:convert';
import 'dart:typed_data';
import 'package:aasha/register.dart';
import 'package:aasha/secrets.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
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
      EthereumAddress.fromHex('0x07e90a385f633BdE571dC55ea262205974998239');
  final registerContractAddress =
      EthereumAddress.fromHex('0xc916249D121eE1e7630DAC2921c416F9Ca9F8768');

  // Remove these somehow
  final EthPrivateKey _myPrivateKey = EthPrivateKey.fromHex(PRIVATE_KEY);
  final EthereumAddress _myPublicAddress = EthereumAddress.fromHex(PUBLIC_KEY);

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

    debugPrint(results.toString());
    return results[0];
  }

  Future<String> registerUser(UserModel model) async {
    assert(registerContract != null);
    assert(_client != null);
    final res = await post(
        Uri.parse('http://ec2-15-207-97-255.ap-south-1.compute.amazonaws.com/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': model.name,
          'dob':
              '${model.dateOfBirth.day}/${model.dateOfBirth.month}/${model.dateOfBirth.year}',
          'aadhar': model.adhaar,
          'pub_address': _myPublicAddress.hex
        }));
    debugPrint(res.statusCode.toString());
    if (res.statusCode != 200) {
      throw Exception(res.statusCode);
    }
    String ipfs = jsonDecode(res.body)['Hash'];
    final ethFunction = registerContract!.function('registerUser');
    final response = await _client!.sendTransaction(
        _myPrivateKey,
        Transaction.callContract(
          contract: registerContract!,
          function: ethFunction,
          parameters: [
            convertHashToBytes(ipfs, _myPublicAddress),
            _myPublicAddress,
            model.adhaar
          ],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    debugPrint(response);
    return ipfs;
  }

  Future<List<DeployedContract>> getElectionsInProgress() async {
    final elections = await getElectionsFromCreateElection();
    List<DeployedContract> contracts = [];
    String votingContractAbi =
        await rootBundle.loadString('assets/abis/votingsContractAbi.json');
    for (var election in elections) {
      final contract = DeployedContract(
          ContractAbi.fromJson(votingContractAbi, 'Voting'), election);

      final deadline = await getUserDeadlineForElection(contract);
      if (deadline.isAfter(DateTime.now())) {
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

  DateTime dateTimeFromUnixTimestamp(BigInt b) =>
      DateTime.fromMillisecondsSinceEpoch(b.toInt() * 1000);

  Uint8List convertHashToBytes(String hash, EthereumAddress publicKey) {
    var key = utf8.encode(publicKey.hex);
    var hashBytes = utf8.encode(hash);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(hashBytes);
    return Uint8List.fromList(digest.bytes);
  }

  Uint8List convertToBytes(String inp) {
    var bytes = utf8.encode(inp);
    final digest = sha1.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  Future<String> getElectionName(DeployedContract contract) async {
    final response =
        await queryCreateElectionContract('electionName', [contract.address]);
    return response[0];
  }

  Future<DateTime> getUserDeadlineForElection(DeployedContract contract) async {
    final response = await queryContract(contract, 'deadlineforUsers', []);
    return dateTimeFromUnixTimestamp(response[0]);
  }

  Future<void> createElection(int numberOfDaysForRegisters,
      int numberOfDaysForUsers, String name) async {
    assert(createElectionContract != null);
    assert(_client != null);
    final ethFunction = createElectionContract!.function('newElection');
    final response = await _client!.sendTransaction(
        _myPrivateKey,
        Transaction.callContract(
          contract: createElectionContract!,
          function: ethFunction,
          parameters: [
            BigInt.from(numberOfDaysForRegisters),
            BigInt.from(numberOfDaysForUsers),
            name
          ],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    debugPrint(response);
  }

  Future<void> createParty(DeployedContract contract, String name) async {
    assert(_client != null);
    final ethFunction = contract.function('registerParty');
    final response = await _client!.sendTransaction(
        _myPrivateKey,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: [name, convertHashToBytes(name, _myPublicAddress)],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    debugPrint(response);
  }

  Future<List<dynamic>> getParties(DeployedContract contract) async {
    final response = await queryContract(contract, 'displayParty', []);
    return response[0];
  }

  Future<String> getPartyName(
      DeployedContract contract, Uint8List party) async {
    final response = await queryContract(contract, 'partyName', [party]);
    debugPrint(response.toString());
    return response[0];
  }

  Future<String> voteParty(DeployedContract contract, dynamic partyHash) async {
    assert(_client != null);
    
    final response =
        await queryRegisterContract('IPFShash', [_myPublicAddress]);
    final ethFunction = contract.function('vote');
    final responseNew = await _client!.sendTransaction(
        _myPrivateKey,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: [response[0], partyHash],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    return responseNew;
  }

  Future<bool> getHasVotedOnContract(DeployedContract contract) async {
    final response =
        await queryContract(contract, 'hasVoted', [_myPublicAddress]);
    return response[0];
  }
}
