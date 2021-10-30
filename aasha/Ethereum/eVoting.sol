// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./register.sol";

contract createElection {
    
    address[] public deployedContracts;
    address manager = 0x0C3d04c2b490e3Cb883022e359A893621d150994;
    uint dUsers;
    uint dRegisters;
    address newelection;
    mapping(address => string) electionName;
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
    
    mapping(bytes32 => uint) public count;
    
    constructor(uint d, uint f) public{
        deadlineforUsers = d;
        deadlineforRegisters = f;
        global = Register(0x754112A0c1D537698ABEcF568E39d7775E754E7D);
    }
    
    function registerParty(bytes32 name) public{
        require(!registeredHash[name]);
        require(!registeredParty[msg.sender]);
        require(block.timestamp < deadlineforRegisters);
        
        registeredParty[msg.sender] = true;
        registeredHash[name] = true;
        count[name] = 0;
        
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
