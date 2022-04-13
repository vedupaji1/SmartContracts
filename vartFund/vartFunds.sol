// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.0;
import "./fundDataStruct.sol";
import "./vartFundsInterface.sol";

contract vartFunds is vartFundSStandards {
    uint256 public totalDonationFunds;
    address public contractCreator;
    mapping(uint256 => fundsData) public donationFunds;
    uint256[] activeDonationFunds;

    constructor() {
        contractCreator = msg.sender;
    }

    function contractBalance() external view override returns (uint256) {
        return address(this).balance;
    }

    function activeDonationsLists()
        external
        view
        override
        returns (fundsData[] memory)
    {
        fundsData[] memory activeFunds = new fundsData[](
            activeDonationFunds.length
        );
        for (uint256 i = 0; i < activeDonationFunds.length; i++) {
            activeFunds[i] = (donationFunds[activeDonationFunds[i]]);
        }
        return activeFunds;
    }

    function createDonationFund(
        string memory fundName,
        string memory purpose,
        uint256 requirement,
        string memory contact
    ) external override returns (bool) {
        require((requirement > 0), "Invalid Input");

        totalDonationFunds++;
        fundsData memory newDonationFund = fundsData(
            fundName,
            purpose,
            payable(msg.sender),
            contact,
            requirement,
            0,
            requirement,
            true
        );
        donationFunds[totalDonationFunds] = newDonationFund;
        activeDonationFunds.push(totalDonationFunds);
        return true;
    }

    function deleteFromActive(uint256 id) public {
        // This Function Actually Removes ID's Of Donations From Active Donations Array After Completion Of Any Donation.
        uint256 j = 0;
        for (uint256 i = 0; i < activeDonationFunds.length - 1; i++) {
            if (activeDonationFunds[i] == id) {
                j++;
                activeDonationFunds[i] = activeDonationFunds[j];
            } else {
                activeDonationFunds[i] = activeDonationFunds[j];
            }
            j++;
        }
        activeDonationFunds.pop();
    }

    function transferFund(uint256 id) external payable override returns (bool) {
        require( // Checking That Wheather User Is Receiver Or Not
            msg.sender == donationFunds[id].receiver,
            "Only Donation Creator Can Get Donation Amount"
        );
        donationFunds[id].isActive = false; // Here Donation Will Become InActive And Collected Amount Will Transfer To Receiver
        deleteFromActive(id);
        bool isDone = donationFunds[id].receiver.send(
            donationFunds[id].collected
        );
        return isDone;
    }

    function donate(uint256 id) external payable override returns (bool) {
        uint256 amount = msg.value;
        require(msg.sender.balance >= amount, "Insuffecient Balance"); // We Will Check That Wheather Donater Have Sufficient Amount.
        require(donationFunds[id].isActive == true, "Donation Is Completed"); // Then We Will Check That Wheather Donation Is Active Or Not.
        require(donationFunds[id].requirement > 0, "Invalid Id");

        donationFunds[id].collected += amount; // Basically Amount Which Donater Will Transfer That Will Be Store In Contract, Here We Are Just Incrementing Collected Amount.
        if (donationFunds[id].remaining > amount) {
            donationFunds[id].remaining -= amount;
        } else {
            donationFunds[id].remaining = 0;
        }

        if (donationFunds[id].collected >= donationFunds[id].requirement) {
            // When Amount More Or Equal To Requirement Will Be Collected At That Time Automatically Donation Will Become InActive And Amount Will Transfer To Receiver.
            donationFunds[id].isActive = false;
            deleteFromActive(id);
            bool isDone = donationFunds[id].receiver.send(
                donationFunds[id].collected
            );
            return isDone;
        } else {
            return true;
        }
    }
}
