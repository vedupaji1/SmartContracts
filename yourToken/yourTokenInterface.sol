// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface yourTokenInterface {
    function createToken(
        string memory tokenName_,
        uint256 maxSupply_,
        uint256 price_
    ) external returns (bool);

    function buyTokens(uint256 quantity, uint256 tokenId)
        external
        payable
        returns (bool);

    function sellTokens(uint256 quantity, uint256 tokenId)
        external
        returns (bool);

    function transfer(
        address receiver,
        uint256 quantity,
        uint256 tokenId
    ) external returns (bool);
}
