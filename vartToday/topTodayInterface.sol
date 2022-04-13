// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.0;
import "./userDataStruct.sol";

interface topTodayInterface {
    function createAccount(string memory userName, string memory aboutUser)
        external
        returns (bool);

    function getData(string memory userName)
        external
        view
        returns (userData[] memory);

    function setTopData(
        uint256 position,
        string memory mainData,
        string memory description
    ) external payable returns (bool);

    function getTopData() external view returns (topDataDetails[10] memory);

    function setTopDataPrice(uint256 position, uint256 newPrice)
        external
        returns (bool);

    function getTopDataItemsPrice() external view returns (uint256[10] memory);

    function setPriceInterval(uint256 newPriceInterval) external returns (bool);
}
