// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
// import "hardhat/console.sol";

interface CEth {
    function mint() external payable;

    function redeemUnderlying(uint256) external returns (uint256);
}

contract chakra is VRFConsumerBaseV2 {
    // This State Variables Are Used To Get Random Number, This Are Related To Chainlink VRF.
    uint64 s_subscriptionId = 4356; // Your Have To Take Subscription Of Chain Link And Then You Will Get This Id.
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab; // This Is Coordinator Id For Rinkeby Network.
    VRFCoordinatorV2Interface COORDINATOR =
        VRFCoordinatorV2Interface(vrfCoordinator);
    bytes32 keyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc; // Choose Different Id For Differnt Network And This Hash Is Responsible For Gas Fee In Random Number Generation.
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256 public s_requestId;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {}

    function requestRandomWords() private {
        // This Method Is Used To Get Random Value And It Will Call "fulfillRandomWords" Method.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    // This Variable, "depositETH" And "withdrawn" Are Realated To Compound Protocol.
    CEth contractInter = CEth(0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e); // Reference Variable Of CEth Interface And It Takes Contract Address For Rinkeby Network.

    function depositETH() public payable {
        contractInter.mint{value: msg.value, gas: 250000000}();
    }

    function withdrawn(uint256 amount) internal returns (uint256) {
        //uint256 resVal = contractInter.redeem(amount);
        return contractInter.redeemUnderlying(amount);
    }

    event ChakraCreated(
        address indexed by,
        uint256 indexed id,
        uint256 value,
        uint256 time
    );
    event ChakraJoined(
        address indexed by,
        uint256 indexed id,
        uint256 value,
        uint256 time
    );
    event ChakraEnd(address indexed winner, uint256 indexed id, uint256 value);

    struct _chakra {
        address creator;
        address[] participants;
        uint256 baseValue;
        uint256 creatorShare;
        uint256 startTime;
        uint256 endTime;
        uint256 winner;
        bool isTrulyRandom;
    }

    address public contractCreator = msgSender();
    mapping(uint256 => _chakra) public chakras; // It Will Store Information About Chakras.
    int256 public lock = -1; // For Applying Locking Mechanism.

    //uint public chakraFee=1200000000000000;
    uint256 public chakraFee = 0; // Chakra Fee Is Taken For Recovering Expense Of Truly Random Number
    uint256 public minOverTime = 60; // It Refers To Minimum Time After Which User Can End Chakra
    uint256 public minBaseValue = 0; //  It Refers To Minimum Base Value Of Chakra
    uint256 public maxCreatorShare = 90; // It Refers To Maximum Share Value Of Chakra Creator
    uint256 private randNonce = 0;

    function msgSender() private view returns (address) {
        return msg.sender;
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords)
        internal
        override
    {
        uint256 id = uint256(lock);
        uint256 randomValue = randomWords[0] % chakras[id].participants.length;
        chakras[id].winner = randomValue + 1;
        lock = -1;
    }

    modifier onlyOwner() {
        require(
            contractCreator == msgSender(),
            "Only Contract Creator Can Access This Method"
        );
        _;
    }

    function setChakraFee(uint256 _chakraFee) public onlyOwner {
        chakraFee = _chakraFee;
    }

    function setMinOverTime(uint256 _minOverTime) public onlyOwner {
        minOverTime = _minOverTime;
    }

    function setMinBaseValue(uint256 _minBaseValue) public onlyOwner {
        minBaseValue = _minBaseValue;
    }

    function setMaxCreatorShare(uint256 _maxCreatorShare) public onlyOwner {
        maxCreatorShare = _maxCreatorShare;
    }

    function checkRandNonce() public view onlyOwner returns (uint256) {
        return randNonce;
    }

    function setRandNonce(uint256 _randNonce) public onlyOwner {
        randNonce = _randNonce;
    }

    function withdrawFunds(uint256 amount) public onlyOwner {
        contractInter.redeemUnderlying(amount);
        payable(contractCreator).transfer(amount);
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Chakra Can Be Created Using This Method.
    // Chakra Creator Has To Use Unique Id For Creating Chakra.
    // They Can Use Id Of Chakra That Not Exists.
    function createChakra(
        uint256 id,
        uint256 _baseValue,
        uint256 _share,
        bool _isTrulyRandom
    ) public payable {
        require(chakras[id].creator == address(0), "Chakra Already Exists");
        require(
            (_baseValue > minBaseValue && _share < maxCreatorShare),
            "Creator Share Should Lesser Than MaxShare Value And Passed Value Should Greater Than MinBase Value."
        );
        if (_isTrulyRandom == true) {
            require(
                msg.value >= (_baseValue + chakraFee),
                "Your Passed Value Should Greater Or Equal To BaseValue + Fee"
            );
        } else {
            require(
                msg.value >= (_baseValue),
                "Your Passed Value Should Greater Or Equal To BaseValue"
            );
        }
        _chakra storage newChakra = chakras[id];
        address _creator = msgSender();
        newChakra.creator = _creator;
        newChakra.participants = [_creator];
        newChakra.baseValue = _baseValue;
        newChakra.creatorShare = _share;
        newChakra.startTime = block.timestamp;
        newChakra.isTrulyRandom = _isTrulyRandom;
        depositETH();
        emit ChakraCreated(_creator, id, msg.value, block.timestamp);
    }

    // This Method Will Check That Whether Participant Exists Or Not.
    function isPraticipantExists(address _participant, uint256 id)
        private
        view
        returns (bool)
    {
        address[] memory _participants = chakras[id].participants;
        uint256 totalParticipants = _participants.length;
        for (uint256 i = 0; i < totalParticipants; ) {
            unchecked {
                if (_participants[i] == _participant) {
                    return true;
                }
                i++;
            }
        }
        return false;
    }

    // Anyone Can Join Chakra By Passing Id Of Chakra In This Method.
    function joinChakra(uint256 id) public payable {
        _chakra memory tempChakra = chakras[id];
        require(tempChakra.creator != address(0), "Chakra Not Exists");
        require(tempChakra.winner == 0, "Chakra Is Ended");
        if (tempChakra.isTrulyRandom == true) {
            require(lock == -1, "Now This Method Is Lock And Chakra Is End");
        }
        require(
            msg.value >= chakras[id].baseValue,
            "Your Passed Value Should Greater Or Equal To BaseValue"
        );
        address _participant = msgSender();
        require(
            isPraticipantExists(_participant, id) == false,
            "User Already Exists"
        );
        chakras[id].participants.push(_participant);
        depositETH();
        emit ChakraJoined(_participant, id, msg.value, block.timestamp);
    }

    // Using This Method Chakra Creator Chakra Can End Or Stop.
    // Only Chakra Creator Can Access This Method.
    // Basically Here "requestRandomWords" Will Be Called Which Will Assign Random Value To Winners Mapping
    function endChakra(uint256 id) public {
        _chakra memory tempChakra = chakras[id];
        require(tempChakra.creator != address(0), "Chakra Not Exists");
        require(tempChakra.winner == 0, "Chakra Is Ended");
        require(
            tempChakra.creator == msgSender(),
            "Only Chakra Creator Can Access This Method"
        );
        require(
            tempChakra.startTime + minOverTime < block.timestamp,
            "Chakra Can End After MinOverTime"
        );
        if (tempChakra.isTrulyRandom == true) {
            require(lock == -1, "Now This Method Is Lock Try After Some Time");
            lock = int256(id);
            requestRandomWords();
        } else {
            address _creator = msgSender();
            randNonce++;
            uint256 randomNumber = uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, _creator, randNonce)
                )
            ) % tempChakra.participants.length;
            chakras[id].winner = randomNumber + 1;
            chakras[id].endTime = block.timestamp;
            uint256 totalFund = tempChakra.participants.length *
                tempChakra.baseValue;
            withdrawn(totalFund);
            uint256 _creatorShare = (totalFund * tempChakra.creatorShare) / 100;
            totalFund -= _creatorShare;
            payable(_creator).transfer(_creatorShare);
            address winnerAddress = tempChakra.participants[randomNumber];
            payable(winnerAddress).transfer(totalFund);
            emit ChakraEnd(winnerAddress, id, totalFund);
        }
    }

    // Using This Method Funds Will Be Distributed To Winner And Chakra Creator.
    // Anyone Can Access This Method.
    // Chakra Creator Will Get Funds As Per Their Share Amount And Rest Of Funds Will Sended To Winner.
    function distributeFunds(uint256 id) public {
        require(chakras[id].creator != address(0), "Chakra Not Exists");
        _chakra memory tempChakra = chakras[id];
        require(
            tempChakra.isTrulyRandom == true && tempChakra.endTime == 0,
            "Only Truly Random Chakra Can Be Accesed And Before EndTime"
        );
        require(
            tempChakra.winner != 0,
            "Winner Is Not Declared Or Random Value Is Not Obtained"
        );
        chakras[id].endTime = block.timestamp;
        address _creator = tempChakra.creator;
        address winnerAddress = tempChakra.participants[tempChakra.winner - 1];
        uint256 totalFund = tempChakra.participants.length *
            tempChakra.baseValue;
        withdrawn(totalFund);
        uint256 _creatorShare = (totalFund * tempChakra.creatorShare) / 100;
        totalFund -= _creatorShare;
        payable(_creator).transfer(_creatorShare);
        payable(winnerAddress).transfer(totalFund);
        emit ChakraEnd(winnerAddress, id, totalFund);
    }
}
