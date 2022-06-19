# Aasha
Flutter App for Evoting using Web3

The main app Aasha is a Flutter app written in Dart.
The smart contracts are written in Solidity and ready to deploy to Ethereum Blockchain.
The backend is written in Python - Flask.

<img src="https://github.com/emem365/evoting_web3/raw/main/assets/1635668119535.jpg" width=175px />  <img src="https://github.com/emem365/evoting_web3/raw/main/assets/1635661679536.jpg" width=175px />  <img src="https://github.com/emem365/evoting_web3/raw/main/assets/1635668119528.jpg" width=175px />
<img src="https://github.com/emem365/evoting_web3/raw/main/assets/1635668119523.jpg" width=175px />  <img src="https://github.com/emem365/evoting_web3/raw/main/assets/1635661679515.jpg" width=175px />

## The Problems Aasha solves
The traditional way of voting asks the voters to go to a specific voting booth to cast their votes. This way of voting raises several issues -
#### Vote Security:
Problem:We hear about EVM hacking in almost every election. The ruling party is accused of tampering with the EVMs to increase their vote count.
Solution: Our app ensures that the user votes cannot be tampered since the data is stored on the blockchain.

#### Voter Security:
Problem : Traditional way of voting results in booth capturing. Supporters of a particular party sometimes make people vote forcefully without their will.
Solution: By using AASHA, voters can cast their vote online as long as they have an active internet connection and are registered as voters.

#### Accessibility:
Problem: This problem specifically arises in case of people who are living away from their home because of work. Since a voter can only vote by going to the polling booth, resulting in a very less voter turnout.
Solution: With AASHA, people can vote from anywhere in the country/world as long as the voting period is ON and they are registered.

## Challenges we ran into
One challenge we ran into was checking the validity of AADHAR NUMBER i.e. if the aadhar number entered by the user is a valid number given by UIDAI or any random imaginary number. We managed to solve it using the Verhoeff Algorithm.

Another challenge we ran into was connecting different smart contracts with each other. AASHA makes use of 2 smart contracts, one for registration and another for voting and creating elections. Registration smart contracts contained all the global data so we had to use that data in all the election and voting contracts.
