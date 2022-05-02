// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
struct usersStruct {
    uint256[] tokensId;
    mapping(uint256 => uint256) balances;
    bool isAvailable;
}
