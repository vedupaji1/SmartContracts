// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// Contract Address:- 0x9f6E11CB31F566e55Ec4dD582ccD2903a7C8c401
contract thugStickMan is ERC721, ERC721URIStorage {
    address creator;
    uint256 mintingFee;
    uint256 public totalStickmans; // Default Value Of uint Is 0, Thats Why there Is No Need To Initialize.

    constructor() ERC721("Thug Stickman", "TS") {
        creator = msgSender();
    }

    function msgSender() public view returns (address) {
        return msg.sender;
    }

    modifier onlyCreator() {
        require(creator == msgSender(), "Only Creator Can Mint New Tokens");
        _;
    }

    function setMintingFee(uint256 amount) public onlyCreator {
        mintingFee = amount;
    }

    function safeMint(address to, string memory uri) public payable {
        require(
            msg.value >= mintingFee,
            "Passed Value Is Less Than Minting Fee"
        );
        totalStickmans++;
        uint256 tokenId = totalStickmans;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
