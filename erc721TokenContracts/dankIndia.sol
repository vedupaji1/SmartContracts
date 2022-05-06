// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC721 {
    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    function approve(address _approved, uint256 _tokenId) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
    event NFTMinted(address by, uint256 id, bytes uri, uint256 time);
}

contract dankIndia is IERC721 {
    string private _name = "Dank India";
    string private _symbol = "DI";
    uint256 _tokenSupply = 0;

    constructor() {
        safeMint("https://api.npoint.io/88c33fa6c3dea49731cd");
        safeMint("https://api.npoint.io/e7f6a63adab37d85ff26");
    }

    mapping(address => uint256) private balances;
    mapping(uint256 => address) private owners;
    mapping(uint256 => string) private _tokenURI;
    mapping(uint256 => address) private approvals;
    mapping(address => mapping(address => bool)) private isAllowedForAll;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256)
    {
        return balances[_owner];
    }

    function totalSupply() external view returns (uint256) {
        return _tokenSupply;
    }

    modifier isTokenExists(uint256 _tokenId) {
        require(owners[_tokenId] != address(0), "Token Or NFT Not Exists");
        _;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        isTokenExists(tokenId)
        returns (string memory)
    {
        return _tokenURI[tokenId];
    }

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        isTokenExists(_tokenId)
        returns (address)
    {
        return owners[_tokenId];
    }

    function safeMint(string memory uri) public returns (bool) {
        _tokenSupply++;
        address owner = msg.sender;
        uint256 tokenId = _tokenSupply;
        _tokenURI[tokenId] = uri;
        owners[tokenId] = owner;
        balances[owner] += 1;

        emit NFTMinted(owner, tokenId, bytes(uri), block.timestamp);
        return true;
    }

    modifier isValidReceiver(address _from, address _to) {
        require(_to != address(0), "Invalid Address Or Address Not Exists");
        require(_from != _to, "Address Of Sender And Receiver Is Same");
        _;
    }

    modifier isOwnerOrApproved(address _from, uint256 _tokenId) {
        address msgSender = msg.sender;
        require(
            owners[_tokenId] == _from,
            "Token Is Not Owned By Mentioned Owner"
        );
        require(
            ((isAllowedForAll[_from][msgSender] == true) ||
                (approvals[_tokenId] == msgSender) ||
                (msgSender == _from)),
            "Token Is Not Owned By You Or Allowd To You."
        );
        _;
    }

    function transfer(address _to, uint256 _tokenId)
        public
        isTokenExists(_tokenId)
        returns (bool)
    {
        address _owner = msg.sender;
        require(owners[_tokenId] == _owner, "Token Is Not Owned By You");
        if (approvals[_tokenId] != address(0)) {
            approvals[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }

        balances[_owner] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(_owner, _to, _tokenId);
        return true;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external override {
        uint256 expectedBalance = balances[_to] + 1;
        transferFrom(_from, _to, _tokenId);
        require(
            (owners[_tokenId] == _to) && (balances[_to] == expectedBalance),
            "Something Went Wrong"
        );
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external override {
        uint256 expectedBalance = balances[_to] + 1;
        transferFrom(_from, _to, _tokenId);
        require(
            (owners[_tokenId] == _to) && (balances[_to] == expectedBalance),
            "Something Went Wrong"
        );
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        override
        isTokenExists(_tokenId)
        isOwnerOrApproved(_from, _tokenId)
    {
        approvals[_tokenId] = address(0);
        emit Approval(_from, address(0), _tokenId);

        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId)
        external
        override
        isTokenExists(_tokenId)
    {
        address _owner = msg.sender;
        require(_owner != _approved, "Owner And Operator Should Different");
        require(owners[_tokenId] == _owner, "You Not Owns This NFT");
        approvals[_tokenId] = _approved;
        emit Approval(_owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {
        address _owner = msg.sender;
        require(_owner != _operator, "Owner And Operator Should Different");
        isAllowedForAll[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function getApproved(uint256 _tokenId)
        external
        view
        override
        isTokenExists(_tokenId)
        returns (address)
    {
        return approvals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool)
    {
        return isAllowedForAll[_owner][_operator];
    }
}
