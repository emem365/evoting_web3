// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Voting{
    
    
    bytes32[] public party;
    mapping (address => bool) public registeredParty;
    mapping (bytes32 => bool) public registeredHash;
    mapping (address => bytes32) public IPFShash;
    mapping (address => bool) public hasVoted;
    mapping (string => bool) public registeredAadhar;
    mapping (address => bool) public registeredUser;
    mapping(bytes32 => uint) public count;
    
    //Elections
    mapping (bytes32 => bool) public elections;
    
    function registerParty(bytes32 name) public{
        require(!registeredHash[name]);
        require(!registeredParty[msg.sender]);
        
        registeredParty[msg.sender] = true;
        registeredHash[name] = true;
        count[name] = 0;
        
        party.push(name);
    }
    
    function vote(bytes32 userhash, bytes32 votingHash) public{
        require(IPFShash[msg.sender] == userhash);
        require(!(hasVoted[msg.sender]));
        
        count[votingHash] += 1;
        
        hasVoted[msg.sender] = true;
        
    }
    
    function displayParty() public view returns(bytes32[] memory){
        return party;
    }
    
    function registerUser(bytes32 userhash, address useraddress, string memory aadhar) public {
        require(!registeredAadhar[aadhar]);
        require(!registeredUser[useraddress]);
        IPFShash[useraddress] = userhash;
        registeredAadhar[aadhar] = true;
        registeredUser[useraddress] = true;
    }
    
}
