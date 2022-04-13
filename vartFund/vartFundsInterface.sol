// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.0;
import "./fundDataStruct.sol";
interface vartFundSStandards{
    function contractBalance()external view returns(uint);
    function activeDonationsLists() external view returns(fundsData[] memory);
    function createDonationFund(string memory fundName,string memory purpose,uint requirement, string memory contact)external returns(bool);
    function transferFund(uint id) external payable returns(bool);
    function donate(uint id) external payable returns(bool);
}