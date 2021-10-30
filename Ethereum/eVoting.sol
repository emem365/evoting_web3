// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./register.sol";

contract createElection {
    
    address[] public deployedContracts;
    address manager = 0x5449E38e424342A2D5c7042942E0F334eeB110C4;
    uint public dUsers;
    uint public dRegisters;
    address newelection;
    mapping(address => string) public electionName;
    function newElection(uint numberOfDaysForRegisters,uint numberOfDaysForUsers, string memory name) public {
        require(msg.sender == manager);
        dUsers = block.timestamp + (numberOfDaysForUsers * 1 days);
        dRegisters = block.timestamp + (numberOfDaysForRegisters * 1 days);
        newelection = address(new Voting(dUsers, dRegisters));
        electionName[newelection] = name;
        deployedContracts.push(newelection);
    }
    
    function getdeployedContracts() public view returns(address[] memory){
        return deployedContracts;
    }
}


contract Voting{
    
    Register global;
    bytes32[] public party;
    uint public deadlineforUsers;
    uint public deadlineforRegisters;
    mapping (address => bool) public registeredParty;
    mapping (bytes32 => bool) public registeredHash;
    
    mapping (address => bool) public hasVoted;
    mapping(bytes32 => string) public partyName;
    mapping(bytes32 => uint) public count;
    
    constructor(uint d, uint f) public{
        deadlineforUsers = d;
        deadlineforRegisters = f;
        global = Register(0x754112A0c1D537698ABEcF568E39d7775E754E7D);
    }
    
    function registerParty(string memory p, bytes32 name) public{
        require(!registeredHash[name]);
        require(!registeredParty[msg.sender]);
        require(block.timestamp < deadlineforRegisters);
        
        registeredParty[msg.sender] = true;
        registeredHash[name] = true;
        count[name] = 0;
        partyName[name] = p;
        party.push(name);
    }
    
    function vote(bytes32 userhash, bytes32 votingHash) public{
        require((global.IPFShash(msg.sender)) == userhash);
        require(!(hasVoted[msg.sender]));
        require(block.timestamp < deadlineforUsers);
        count[votingHash] += 1;
        hasVoted[msg.sender] = true;
        
    }
    
    function displayParty() public view returns(bytes32[] memory){
        return party;
    }
    
}
