// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.0;

interface ERC1155PracInterface {
    function name() external returns (string memory);

    function symbol() external returns (string memory);

    function totalSupply(uint256 tokenId) external returns (uint256);

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function balanceOf(address _owner, uint256 tokenId)
        external
        returns (uint256);

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external;

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    function uri(uint256 _id) external view returns (string memory);

    function setURI(uint256 id, string memory _uri) external;

    event Mint(
        address indexed to,
        uint256 indexed id,
        uint256 indexed amount,
        bytes data
    );

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value,
        bytes data
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values,
        bytes data
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    event URI(string value, uint256 indexed id);
}

contract ERC1155Prac is ERC1155PracInterface {
    // Here We Can Put '_minter', '_totalSupply', '_balances' In Struct But Here We Are Following Standards And It Is Somewhere Gas Optimized Because When We Has To Read Data At That Time If We Will Read Stuct So It Will Cost More Gas.
    /*
       Another Way To Store Token Data,

       id --> {
        minter,
        totalSupply,
        balances --> balance(uint)
       }
       Note:- It Will Consume More Gas In Reading And Writing Data.
    */

    mapping(uint256 => address) private _minter;
    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _isApprovedForAll;

    mapping(uint256 => string) private tokenURI;
    

    string private _name = "PAPATOKEN";
    string private _symbol = "PN";

    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function totalSupply(uint256 tokenId)
        external
        view
        override
        returns (uint256)
    {
        // We Can Use Modifier Or Requier To Check That Whether Token Id Is Valid Or Not Or Token Exists Or Not But Here We Are Using Mapping So Unlike Array Invalid Id Will Not Affect Our Contract And It Will Also Save Gas.
        return _totalSupply[tokenId];
    }

    function minter(uint256 id) public view returns (address) {
        return _minter[id];
    }

    modifier isValidAddress(address to) {
        require(to != address(0), "Inavlid Address");
        _;
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external override isValidAddress(to) {
        require(_totalSupply[id] == 0, "Token Id Already Exists");
        require(amount>0,"Amount Should Greater Than 0");
        _totalSupply[id] = amount;
        _balances[id][to] = amount;
        _minter[id] = to;
        emit Mint(to, id, amount, data);
    }

    function balanceOf(address _owner, uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return _balances[tokenId][_owner];
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        override
        returns (uint256[] memory)
    {
        require(
            _owners.length == _ids.length,
            "Number Of Addresses Should Equal To Number Of Id's"
        );
        uint256[] memory _batchBalances = new uint256[](_owners.length);
        for (uint256 i = 0; i < _owners.length; ) {
            _batchBalances[i] = balanceOf(_owners[i], _ids[i]); // We Can Also Do Like This _batchBalances[i] = _balances[_ids[i]][_owners[i]]; But It Is More Expensive Than This.
            unchecked {
                i++;
            }
        }
        return _batchBalances;
    }

    function _transferTokens(
        address _caller,
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal isValidAddress(_to) {
        require(
            _from == _caller || _isApprovedForAll[_from][_caller] == true,
            "Only Owner Or Allowed Person Can Access This Method"
        );
        require(_amount <= _balances[_id][_from], "Insufficient Tokens");
        unchecked {
            _balances[_id][_from] -= _amount;
            _balances[_id][_to] += _amount;
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external override {
        address _caller = msgSender();
        _transferTokens(_caller, _from, _to, _id, _amount);
        emit TransferSingle(_caller, _from, _to, _id, _amount, _data);
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external override {
        require(
            _ids.length == _values.length,
            "Number Of Values Should Equal To Number Of Id's"
        );
        address _caller = msgSender();
        for (uint256 i = 0; i < _ids.length; ) {
            _transferTokens(_caller, _from, _to, _ids[i], _values[i]);
            unchecked {
                i++;
            }
        }
        emit TransferBatch(_caller, _from, _to, _ids, _values, _data);
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {
        address _caller = msgSender();
        require(
            _caller != _operator,
            "Owner Address And Operator Address Cannot Be Same"
        );
        _isApprovedForAll[_caller][_operator] = _approved;
        emit ApprovalForAll(_caller, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool)
    {
        return _isApprovedForAll[_owner][_operator];
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return tokenURI[_id];
    }

    function setURI(uint256 id, string memory _uri) external override {
        require(
            minter(id) == msgSender(),
            "Only Minter Can Access This Method"
        );
        tokenURI[id] = _uri;
        emit URI(_uri, id);
    }
}
