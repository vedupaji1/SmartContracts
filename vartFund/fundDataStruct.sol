// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.0;

struct fundsData {
    string fundName;
    string purpose;
    address payable receiver;
    string contact;
    uint256 requirement;
    uint256 collected;
    uint256 remaining;
    bool isActive;
}
