// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./tokenStruct.sol";
import "./usersStruct.sol";
import "./yourTokenInterface.sol";

//import "hardhat/console.sol";
contract yourToken is yourTokenInterface {
    address public contractCreator;
    token[] public tokens; // It Will Store Information About Tokens.
    uint256 public totalTokens = 0;
    mapping(address => usersStruct) public users; // It Will Store User's Information.

    constructor(address contractCreator_) {
        contractCreator = contractCreator_;
    }

    function createToken(
        string memory tokenName_,
        uint256 maxSupply_,
        uint256 price_
    ) external override returns (bool) {
        token memory newToken = token(
            tokenName_,
            maxSupply_,
            0,
            price_,
            block.timestamp,
            msg.sender
        );
        totalTokens++;
        tokens.push(newToken);
        users[msg.sender].tokensId.push(totalTokens);
        users[msg.sender].isAvailable = true;
        return true;
    }

    modifier isTokenExists(uint256 tokenId) {
        require(tokenId > 0 && tokenId <= totalTokens, "Token Does Not Exists"); // It Will Check Whether Token Exits Or Not.
        _;
    }

    function buyTokens(uint256 quantity, uint256 tokenId)
        external
        payable
        override
        isTokenExists(tokenId)
        returns (bool)
    {
        require(msg.sender.balance >= msg.value, "Insufficient Balance");
        uint256 tokenId_ = tokenId - 1;
        token memory token_ = tokens[tokenId_]; // Storing Token Data In Memory, It Will Save Our Gas Fee Because If We Will Read Data From Storage So It Will Increase Gas Cost.
        require(
            (token_.curSupply + quantity) <= token_.maxSupply,
            "Total Supply Of Tokens Reached Its Max Supply"
        );
        require(
            msg.value >= (token_.price * quantity),
            "Sended Amount Is Not Sufficient"
        );
        if (users[msg.sender].isAvailable == false) {
            users[msg.sender].isAvailable = true;
        }
        users[msg.sender].balances[tokenId] += quantity;
        tokens[tokenId_].curSupply += quantity;
        return true;
    }

    modifier checkTokenBalance(uint256 quantity, uint256 tokenId) {
        require(
            users[msg.sender].balances[tokenId] >= quantity,
            "Insufficient Token Balance"
        );
        _;
    }

    function sellTokens(uint256 quantity, uint256 tokenId)
        external
        override
        isTokenExists(tokenId)
        checkTokenBalance(quantity, tokenId)
        returns (bool)
    {
        uint256 tokenId_ = tokenId - 1;
        users[msg.sender].balances[tokenId] -= quantity;
        tokens[tokenId_].curSupply -= quantity;
        address payable receiver = payable(msg.sender);
        bool isDone = receiver.send(tokens[tokenId_].price * quantity);
        return isDone;
    }

    function transfer(
        address receiver,
        uint256 quantity,
        uint256 tokenId
    )
        external
        override
        isTokenExists(tokenId)
        checkTokenBalance(quantity, tokenId)
        returns (bool)
    {
        if (users[msg.sender].isAvailable == false) {
            users[msg.sender].isAvailable = true;
        }
        users[msg.sender].balances[tokenId] -= quantity;
        users[receiver].balances[tokenId] += quantity;
        return true;
    }

    function getTokensData() public view returns (token[] memory) {
        token[] memory tokens_ = tokens;
        return tokens_;
    }

    modifier isUserAvailable(address user_) {
        require(users[user_].isAvailable == true, "User Does Not Exists");
        _;
    }

    function usersGeneratedTokens(address user_)
        public
        view
        isUserAvailable(user_)
        returns (uint256[] memory)
    {
        uint256[] memory tokensId_ = users[user_].tokensId;
        return tokensId_;
    }

    function usersTokenBalance(address user_, uint256 tokenId)
        public
        view
        isUserAvailable(user_)
        isTokenExists(tokenId)
        returns (uint256)
    {
        uint256 balance_ = users[user_].balances[tokenId];
        return balance_;
    }
}
