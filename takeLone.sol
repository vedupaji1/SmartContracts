// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract takeLone {
    struct transactionDetails {
        address addr;
        uint256 amount;
        uint256 loneGivenTime;
        uint256 loneDueTime;
        uint16 interestRate;
        bool moneyPaid;
    }

    struct request {
        address requester;
        uint256 amount;
        uint256 loneDueTime;
        uint16 interestRate;
        string contact;
        string status;
    }

    struct personalLoneReq {
        address to;
        uint256 index;
    }

    request[] public globalLoneRequests;
    mapping(address => uint256) globalRequestIndex;

    mapping(address => request[]) personalLoneRequests;
    mapping(address => personalLoneReq) personalRequestIndex;

    mapping(address => transactionDetails[]) loneGiven;
    mapping(address => transactionDetails[]) loneTaken;

    event moneyTransfered(address from, address to, uint256 amount);

    function userBalance() public view returns (uint256) {
        return (msg.sender.balance);
    }

    function userLoneTaken() public view returns (transactionDetails[] memory) {
        return (loneTaken[msg.sender]);
    }

    function userLoneGiven() public view returns (transactionDetails[] memory) {
        return (loneGiven[msg.sender]);
    }

    function showLoneRequests() public view returns (request[] memory) {
        return (personalLoneRequests[msg.sender]);
    }

    function moneyTransfer(address payable to) public payable returns (bool) {
        uint256 requestIndex = personalRequestIndex[to].index; //searchRequest(to, msg.sender);
        require(
            ((requestIndex != 0) &&
                (personalRequestIndex[to].to == msg.sender)) ||
                (globalRequestIndex[to] != 0),
            "Lone Request Not Found"
        );

        if (
            ((requestIndex != 0) && (personalRequestIndex[to].to == msg.sender))
        ) {
            uint256 amount = personalLoneRequests[msg.sender][requestIndex - 1]
                .amount;
            require((msg.sender.balance >= amount), "Insufficient Balance");
            require(
                (msg.value == amount),
                "Your Lone Amount Not Matching To Requester Amount"
            );
            bool isDone = to.send(amount); // Money Transfered And Response Stored In "isDone"

            if (isDone == true) {
                emit moneyTransfered(msg.sender, to, amount);
                transactionDetails memory tempObj = transactionDetails(
                    to,
                    amount,
                    block.timestamp,
                    personalLoneRequests[msg.sender][requestIndex - 1]
                        .loneDueTime,
                    personalLoneRequests[msg.sender][requestIndex - 1]
                        .interestRate,
                    false
                );

                loneGiven[msg.sender].push(tempObj); // Details Of Transaction Stored In Sender Records
                tempObj.addr = msg.sender;
                loneTaken[to].push(tempObj); // Details Of Transaction Stored In Receiver Records

                personalLoneRequests[msg.sender][
                    personalRequestIndex[to].index - 1
                ].status = "Completed";
                personalRequestIndex[to].index = 0;
                personalRequestIndex[to]
                    .to = 0x0000000000000000000000000000000000000000;
            }
            return isDone;
        } else {
            request memory globalReq = globalLoneRequests[
                globalRequestIndex[to] - 1
            ];
            uint256 amount = globalReq.amount;

            require((msg.sender.balance >= amount), "Insufficient Balance");
            require(
                (msg.value == amount),
                "Your Lone Amount Not Matching To Requester Amount"
            );
            bool isDone = to.send(amount); // Money Transfered And Response Stored In "isDone"

            if (isDone == true) {
                emit moneyTransfered(msg.sender, to, amount);
                transactionDetails memory tempObj = transactionDetails(
                    to,
                    amount,
                    block.timestamp,
                    globalReq.loneDueTime,
                    globalReq.interestRate,
                    false
                );

                loneGiven[msg.sender].push(tempObj); // Details Of Transaction Stored In Sender Records
                tempObj.addr = msg.sender;
                loneTaken[to].push(tempObj); // Details Of Transaction Stored In Receiver Records

                globalLoneRequests[globalRequestIndex[to] - 1]
                    .status = "Completed";
                globalRequestIndex[to] = 0;
            }
            return isDone;
        }
    }

    function sendGlobalLoneRequest(
        uint256 amount,
        uint256 loneDueTime,
        uint16 interestRate,
        string memory contact
    ) public {
        require(globalRequestIndex[msg.sender] == 0, "Request Limit Is Full");
        request memory tempObj = request(
            msg.sender,
            amount,
            loneDueTime,
            interestRate,
            contact,
            "Pending"
        );
        globalLoneRequests.push(tempObj);
        globalRequestIndex[msg.sender] = globalLoneRequests.length;
    }

    function sendPersonalLoneRequest(
        address loneProvider,
        uint256 amount,
        uint256 loneDueTime,
        uint16 interestRate,
        string memory contact
    ) public {
        require(
            personalRequestIndex[msg.sender].index == 0,
            "Request Limit Is Full"
        );
        request memory tempObj = request(
            msg.sender,
            amount,
            loneDueTime,
            interestRate,
            contact,
            "Pending"
        );
        personalLoneRequests[loneProvider].push(tempObj);

        personalLoneReq memory reqObj = personalLoneReq(
            loneProvider,
            personalLoneRequests[loneProvider].length
        );
        personalRequestIndex[msg.sender] = reqObj;
    }

    function removeGlobalRequest() public {
        require(
            globalRequestIndex[msg.sender] != 0,
            "There Is Not Any Request"
        );
        globalLoneRequests[globalRequestIndex[msg.sender] - 1]
            .status = "No Need";
        globalRequestIndex[msg.sender] = 0;
    }

    function removePersonalRequest() public {
        require(
            personalRequestIndex[msg.sender].index != 0,
            "There Is Not Any Request"
        );
        personalLoneRequests[personalRequestIndex[msg.sender].to][
            personalRequestIndex[msg.sender].index - 1
        ].status = "No Need";

        personalRequestIndex[msg.sender].index = 0;
        personalRequestIndex[msg.sender]
            .to = 0x0000000000000000000000000000000000000000;
    }

    function searchLoneReceiverIndex(address provider)
        private
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < loneTaken[msg.sender].length; i++) {
            if ((loneTaken[msg.sender][i].addr == provider)) {
                return i + 1;
            }
        }
        return 0;
    }

    function searchLoneProviderIndex(address provider)
        private
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < loneGiven[provider].length; i++) {
            if ((loneGiven[provider][i].addr == msg.sender)) {
                return i + 1;
            }
        }
        return 0;
    }

    function payLoneAmount(address payable to) public payable returns (bool) {
        uint256 requestIndex = searchLoneReceiverIndex(to);

        require(requestIndex != 0, "Lone Not Taken From Given Address");
        require(
            (loneTaken[msg.sender][requestIndex - 1].moneyPaid == false),
            "Lone Amount Already Paid"
        );
        uint256 amount = loneTaken[msg.sender][requestIndex - 1].amount;
        require((msg.sender.balance >= amount), "Insufficient Balance");
        require(
            (msg.value == amount),
            "Your Lone Amount Not Matching To Requester Amount"
        );
        bool isDone = to.send(amount); // Money Transfered And Response Stored In "isDone"

        if (isDone == true) {
            emit moneyTransfered(msg.sender, to, amount);
            loneTaken[msg.sender][requestIndex - 1].moneyPaid = true;
            uint256 loneProviderIndex = searchLoneProviderIndex(to);
            loneGiven[to][loneProviderIndex - 1].moneyPaid = true;
        }
        return isDone;
    }
}
