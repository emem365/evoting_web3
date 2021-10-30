// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Register{
    
    mapping (string => bool) public registeredAadhar;
    mapping (address => bool) public registeredUser;
    mapping (address => bytes32) public IPFShash;
    
    function registerUser(bytes32 userhash, address useraddress, string memory aadhar) public {
        require(!registeredAadhar[aadhar]);
        require(!registeredUser[useraddress]);
        IPFShash[useraddress] = userhash;
        registeredAadhar[aadhar] = true;
        registeredUser[useraddress] = true;
    }
    
}
