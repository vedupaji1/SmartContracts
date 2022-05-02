// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract sendETH {
    address public userAddress;
    constructor()
    {
        userAddress=msg.sender;
    }
    function sendMoney(address payable to) public payable returns (bool) {
        // Visit This Site "https://medium.com/coinmonks/solidity-transfer-vs-send-vs-call-function-64c92cfc878a", For More Info About Methods Of Ethers Transfer
        bool isDone = to.send(msg.value);
        return isDone;
    }

    function showBalance() public view returns (uint256) {
        return msg.sender.balance;
    }
}
