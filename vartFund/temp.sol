// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.0;


contract temp 
{
    mapping(uint256 => uint256) public tempMap;
    function initMap() public {
        tempMap[0] = 100;
        tempMap[1] = 10075;
        tempMap[5] = 102770;
    }
}
