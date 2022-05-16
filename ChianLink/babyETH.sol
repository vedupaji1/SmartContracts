// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract babyPrice {
    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x9326BFA02ADD2366b30bacB125260Af641031331
        );
    }

    function getPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (price * 10000000);
    }

    function etherToTokens(uint256 weis) public view returns (uint256) {
        uint256 tokenPrice = uint256(getPrice());
        uint256 _tokens = (1000000000000000000 * weis) / tokenPrice;
        return _tokens;
    }

    function tokensToEther(uint256 amount) public view returns (uint256) {
        uint256 tokenPrice = uint256(getPrice());
        uint256 _ethers = (tokenPrice * amount) / 1000000000000000000;
        return _ethers;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Funded(address by, uint256 amount, uint256 time);
    event TokensBuyed(address by, uint256 amount, uint256 time);
    event TokensSold(address by, uint256 amount, uint256 value, uint256 time);
}

contract babyETH is IERC20, babyPrice {
    uint256 public maxSupply = 1e21;
    uint256 _totalSupply = 100000000000000000000;
    address contractCreator = 0x3D21439ec0282Ecb775a80c7A772f154aE08609D;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowanceAmount;
    mapping(address => uint256) funders;

    constructor() {
        balances[contractCreator] = _totalSupply;
        emit Transfer(address(0), contractCreator, _totalSupply);
    }

    function ourFunds() public view returns (uint256) {
        return address(this).balance;
    }

    function fundUs() public payable returns (bool) {
        address from = msg.sender;
        uint256 amount = msg.value;
        funders[from] += amount;
        emit Funded(from, amount, block.timestamp);
        return true;
    }

    function name() external pure override returns (string memory) {
        return "BabyETH";
    }

    function symbol() external pure override returns (string memory) {
        return "BE";
    }

    function decimals() external pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    modifier isvalidAddress(address _address) {
        require(_address != address(0), "Invalid Address Or Adress Not Exists");
        _;
    }

    function balanceOf(address account)
        external
        view
        override
        isvalidAddress(account)
        returns (uint256)
    {
        return balances[account];
    }

    function transfer(address to, uint256 amount)
        external
        override
        isvalidAddress(to)
        returns (bool)
    {
        address from = msg.sender;
        require(balances[from] >= amount, "Insufficient Tokens");
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return allowanceAmount[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        isvalidAddress(spender)
        returns (bool)
    {
        address owner = msg.sender;
        require(balances[owner] >= amount, "Insufficient Tokens");
        allowanceAmount[owner][spender] += amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    modifier verifyInfo(
        address from,
        address to,
        uint256 amount
    ) {
        require(to != address(0), "Address Of Receiver Not Exists");
        require(
            allowanceAmount[from][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        require(balances[from] >= amount, "Owner Have Insufficient Tokens");
        _;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override verifyInfo(from, to, amount) returns (bool) {
        allowanceAmount[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function buyTokens() public payable returns (bool) {
        uint256 _tokens = etherToTokens(msg.value);
        require(
            (_totalSupply + _tokens) <= maxSupply,
            "Tokens Supply Reached To Their Maximum Supply"
        );
        address receiver = msg.sender;
        balances[receiver] += _tokens;
        _totalSupply += _tokens;
        emit TokensBuyed(receiver, _tokens, block.timestamp);
        return true;
    }

    function sellTokens(uint256 amount) public returns (bool) {
        require(
            (_totalSupply - amount) >= 900000000000000000000,
            "Tokens Cannot Be Sell, Total Supply Should Be 90% Of Max Supply"
        );
        uint256 sellValue = tokensToEther(amount);
        address seller = msg.sender;
        balances[seller] -= amount;
        _totalSupply -= amount;
        bool isDone = payable(seller).send(sellValue);
        emit TokensSold(seller, amount, sellValue, block.timestamp);
        return isDone;
    }
}
