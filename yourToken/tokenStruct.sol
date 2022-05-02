// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
struct token {
    string tokenName;
    uint256 maxSupply;
    uint256 curSupply;
    uint256 price;
    uint256 createdOn;
    address createdBy;
}
