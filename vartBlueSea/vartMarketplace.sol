// SPDX-License-Identifier:MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract vartMarketPlace {
    struct item {
        uint256 id;
        address owner;
        IERC721 contractInstance;
        uint256 price;
        bool isSold;
    }

    uint256 public totalListings;
    item[] public listedItems;

    address public contractAdd = address(this);

    event ItemListed(
        address indexed by,
        uint256 indexed id,
        address contractAddress,
        uint256 price,
        uint256 indexed listingId
    );
    event ItemSold(
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 indexed listingId
    );

    function listItem(
        uint256 id,
        address contractAddress,
        uint256 price
    ) public {
        require(price > 1, "Price Of Token Sholud Greater Than 1");
        item memory newItem = item(
            id,
            msg.sender,
            IERC721(contractAddress),
            price,
            false
        );
        newItem.contractInstance.transferFrom(msg.sender, address(this), id);
        totalListings++;
        listedItems.push(newItem);
        emit ItemListed(msg.sender, id, contractAddress, price, totalListings);
    }

    function purchaseItem(uint256 listingId) public payable returns (bool) {
        require(listingId <= totalListings, "Id Not Exits");
        item memory tempItem = listedItems[listingId - 1];
        require(tempItem.isSold == false, "Item Is Already Sold");
        require(
            msg.value >= tempItem.price,
            "Price Should Greater Than Specified Price"
        );
        listedItems[listingId - 1].isSold = true;
        bool isDone = payable(tempItem.owner).send(tempItem.price);
        tempItem.contractInstance.transferFrom(
            address(this),
            msg.sender,
            tempItem.id
        );
        emit ItemSold(tempItem.owner, msg.sender, tempItem.id, listingId);
        return isDone;
    }

    function getListings() public view returns (item[] memory) {
        item[] memory tempListings = listedItems;
        return tempListings;
    }

    // 0x1151d60cf5d85678e4e879cb12f8a4e04f2268a8
}
