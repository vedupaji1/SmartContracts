// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

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

    struct _chakra {
        address creator;
        address[] participants;
        uint256 baseValue;
        uint256 startTime;
        uint256 creatorShare;
    }

    address contractCreator = msgSender();
    mapping(uint256 => _chakra) private chakras; // It Will Store Information About Chakras
    mapping(uint256 => bool) public isChakraExists; // We Can Also Put It Inside Struct But It Saves Gas Cost.
    mapping(uint256 => uint256) public winners; // It Will Store Truly Random Number For Every Chakra.
    int256 public lock = -1;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        _chakra storage temp = chakras[0];
        temp.creator = msgSender();
        temp.participants = [
            msgSender(),
            0x3D21439ec0282Ecb775a80c7A772f154aE08609D
        ];
        temp.baseValue = 0;
        temp.startTime = block.timestamp;
        temp.creatorShare = 0;
        isChakraExists[0] = true;
    }

    function requestRandomWords() public {
        // This Method Is Used To Get Random Value And It Will Call "fulfillRandomWords" Method.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    //uint public chakraFee=1200000000000000;
    uint256 public chakraFee = 0; // Chakra Fee Is Taken For Recovering Expense Of Truly Random Number
    uint256 public minOverTime = 60; // It Refers To Minimum Time After Which User Can End Chakra
    uint256 public minBaseValue = 0; //  It Refers To Minimum Base Value Of Chakra
    uint256 public maxCreatorShare = 90; // It Refers To Maximum Share Value Of Chakra Creator

    function msgSender() public view returns (address) {
        return msg.sender;
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords)
        internal
        override
    {
        uint256 id = uint256(lock);
        winners[id] = randomWords[0];
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

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds(uint256 amount) public onlyOwner {
        payable(contractCreator).transfer(amount);
    }

    // Chakra Can Be Created Using This Method.
    // Chakra Creator Has To Use Unique Id For Creating Chakra.
    // They Can Use Id Of Chakra That Not Exists.
    function createChakra(
        uint256 id,
        uint256 _baseValue,
        uint256 _share
    ) public payable {
        require(isChakraExists[id] == false, "Chakra Already Exists");
        require(
            (_baseValue > minBaseValue && _share < maxCreatorShare),
            "Creator Share Should Lesser Than MaxShare Value And Passed Value Should Greater Than MinBase Value."
        );
        require(
            msg.value >= (_baseValue + chakraFee),
            "Your Passed Value Should Greater Or Equal To BaseValue + Fee"
        );
        _chakra storage newChakra = chakras[id];
        address _creator = msgSender();
        newChakra.creator = _creator;
        newChakra.participants = [_creator];
        newChakra.baseValue = _baseValue;
        newChakra.startTime = block.timestamp;
        newChakra.creatorShare = _share;
        isChakraExists[id] = true;
    }

    // This Method Will Check That Whether Participant Exists Or Not.
    function isPraticipantExists(address _participant, uint256 id)
        internal
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
        require(isChakraExists[id] == true, "Chakra Not Exists");
        require(winners[id] == 0, "Winner Of This Chakra Is Declared");
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
    }

    // Using This Method Chakra Creator Chakra Can End Or Stop.
    // Only Chakra Creator Can Access This Method.
    // Basically Here "requestRandomWords" Will Be Called Which Will Assign Random Value To Winners Mapping
    function endChakra(uint256 id) public {
        require(lock == -1, "Now Method Is Lock Try After Some Time");
        require(isChakraExists[id] == true, "Chakra Not Exists");
        _chakra memory tempChakra = chakras[id];
        require(
            tempChakra.startTime + minOverTime < block.timestamp,
            "Chakra Can End After MinOverTime"
        );
        require(
            tempChakra.creator == msgSender(),
            "Only Chakra Creator Can Access This Method"
        );
        lock = int256(id);
        requestRandomWords();
    }

    // Using This Method Funds Will Be Distributed To Winner And Chakra Creator.
    // Anyone Can Access This Method.
    // Chakra Creator Will Get Funds As Per Their Share Amount And Rest Of Funds Will Sended To Winner.
    function distributeFunds(uint256 id) public {
        require(isChakraExists[id] == true, "Chakra Not Exists");
        uint256 winner = winners[id];
        require(winner != 0, "Winner Is Not Declared, Wait For Few Time");
        _chakra memory tempChakra = chakras[id];
        address _creator = msgSender();
        isChakraExists[id] = false;
        uint256 totalFund = tempChakra.participants.length *
            tempChakra.baseValue;
        uint256 _creatorShare = (totalFund * tempChakra.creatorShare) / 100;
        totalFund -= _creatorShare;
        payable(_creator).transfer(_creatorShare);
        uint256 randomNumber = winner % tempChakra.participants.length;
        address winnerAddress = tempChakra.participants[randomNumber];
        payable(winnerAddress).transfer(totalFund);
        winners[id] = 0;
    }
}
