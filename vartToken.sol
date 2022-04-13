// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.0;

interface ERCStandardFunctions {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract mathFuncs {
    /*
      Basically There Is Not Much More Need Of This Library And Its Fuction But For More Security And Increasing Readabilty Of Contract It Is Used.
      Actually We Will Be Using Mostly "Add" And "Sub" Fuction For Addition And Substraction Opration
      */
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition Overflow, Something Went Wrong");
        return c;
    }

    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        require(b <= a, "Subtraction Overflow, Something Went Wrong");
        uint256 c = a - b;
        return c;
    }

    function multi(uint256 a, uint256 b) public pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Multiplication Overflow, Something Went Wrong");
        return c;
    }

    function div(uint256 a, uint256 b) public pure returns (uint256) {
        require(b > 0, "Division Overflow, Something Went Wrong");
        uint256 c = a / b;
        return c;
    }

    function perce(uint256 value, uint256 perVal)
        public
        pure
        returns (uint256)
    {
        require(
            ((value != 0) && (perVal != 0)),
            "Percentage Overflow, Something Went Wrong"
        );
        uint256 c = (value * perVal) / 100;
        return c;
    }
}

contract vartToken is ERCStandardFunctions, mathFuncs {
    string tokenName = "VARt Token";
    string tokenSymbol = "VARt";
    uint8 decimal = 18;
    uint256 maxTokenSupply = 1000000000;
    uint256 totalTokenSupply;
    address public founder;
    uint256 public deployedTime;
    uint256 public contractUpdatedTime;
    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private allowed;

    constructor() {
        founder = msg.sender;
        totalTokenSupply = perce(maxTokenSupply, 50);
        balance[founder] = totalTokenSupply;
        deployedTime = block.timestamp;
        contractUpdatedTime = block.timestamp;
        emit Transfer(address(this), founder, totalTokenSupply);
    }

    function name() public view override returns (string memory) {
        return tokenName;
    }

    function symbol() public view override returns (string memory) {
        return tokenSymbol;
    }

    function decimals() public view override returns (uint8) {
        return decimal;
    }

    function totalSupply() public view override returns (uint256) {
        return totalTokenSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    function myAddress() public view returns (address) {
        return msg.sender;
    }

    function myBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function transfer(address to, uint256 value)
        public
        override
        returns (bool)
    {
        return transferToken(msg.sender, to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool success) {
        /*
         Requirements For Transfering Tokens Using Allowance:-
         (1) Allowed Amount Should Be Greater Than Value
         (2) Balance Of Sender Should Be Greater Or Equal To Value.
         (3) Only Allowed Account Or Person Can Transfer Token Using Allowance
        */
        address allowedAccount = msg.sender;
        require(
            (allowed[from][allowedAccount] >= value),
            "Insufficient Allowance Balance"
        );

        allowed[from][allowedAccount] = sub(
            allowed[from][allowedAccount],
            value
        );
        return transferToken(from, to, value);
    }

    function transferToken(
        address from,
        address to,
        uint256 value
    ) private returns (bool) {
        /*
         Requirements For Transfering Tokens:-
         (1) Sender Or Receiver Address Should Not Be Zero (No Address Or No Mans Land).
         (2) Balance Of Sender Should Be Greater Or Equal To Value.
        */
        require(
            (from != address(0)),
            "Tokens Cannot Transfer From Zero Address"
        );
        require((to != address(0)), "Tokens Cannot Transfer To Zero Address");
        require((balance[from] >= value), "Insufficient Balance");

        balance[to] = add(balance[to], value);
        balance[from] = sub(balance[from], value);
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value)
        public
        override
        returns (bool success)
    {
        address owner = msg.sender;
        require(owner != address(0), "Owner Address Cannot Zero");
        require(spender != address(0), "Spender Address Cannot Zero");
        require(balance[owner] >= value, "Insufficient Balance For Allowance");

        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    //  function mintTokens() public returns(uint) {
    //      require(msg.sender==founder,"Only Founder Can Mint Coins");
    //  }
}
