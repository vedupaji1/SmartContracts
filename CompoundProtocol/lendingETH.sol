// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface Erc20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);
}

interface CEth {
    // Check Github Profile Of Compound For More Info "https://github.com/compound-finance/compound-protocol/blob/master/contracts/CTokenInterfaces.sol" And "https://github.com/compound-developers/compound-supply-examples/blob/master/contracts/MyContracts.sol".
    function balanceOf(address) external view returns (uint256);

    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function balanceOfUnderlying(address) external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function repayBorrow() external payable;
}

contract temp {
    CEth contractInter = CEth(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);

    event ShowBalance(address user, uint256 balance);
    event Deposit(address from, uint256 amount);
    event Withdrawn(address from, uint256 amount, uint256 value);

    receive() external payable{

    }

    function getSupplyRate() public returns (uint256) {
        uint256 resVal = contractInter.supplyRatePerBlock();
        console.log(resVal);
        return resVal;
    }

    function getExchangeRate() public returns (uint256) {
        uint256 resVal = contractInter.exchangeRateCurrent();
        console.log(resVal);
        return resVal;
    }

    function depositETH() public payable returns (bool) {
        contractInter.mint{value: msg.value, gas: 250000000}();
        emit Deposit(msg.sender, msg.value);
        return true;
    }

    function showBalance() public payable returns (uint256) {
        uint256 resVal = contractInter.balanceOf(address(this));
        console.log(resVal);
        emit ShowBalance(address(this), resVal);
        return resVal;
    }

    function withdrawn(uint256 amount) public returns (bool) {
        //uint256 resVal = contractInter.redeem(amount);
        uint256 resVal = contractInter.redeemUnderlying(amount);
        console.log(resVal);
        emit Withdrawn(address(this), amount, resVal);
        return true;
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
