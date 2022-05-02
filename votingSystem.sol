// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.0;

contract votingSystem {
    /*
      This Is Crowd Voting System, It Is Moderator Based System In Which Moderator Will Start Voting And They Will End Voting.
      We Can Also Create Automated Voting System Where Automatically Voting Will Start And End.
     */

    struct voting {
        string votingName;
        string description;
        string[] candidates; // It Will Store Array Of Candidates.
        uint256[] votes; // It Will Record That How Much Votes Each Candidate Obtained.
        uint256 totalVotes;
        bool isVotingStart;
        bool isVotingEnd;
    }

    voting[] public votings; // It Will Contains List Of Votings Using Mapping.
    mapping(uint256 => mapping(address => bool)) voters; // It Will Contains List Of Voters Using Mapping.
    mapping(address => uint256[]) public moderators; // List Of Moderators Using Mapping.
    uint256 public totalVotings = 0; // We Will Use This As Id Of Votings.

    // This Method Will Create New Voting.
    function createVotings(
        string memory votingName_,
        string memory description_,
        string[] memory candidates_
    ) public returns (bool) {
        require(candidates_.length >= 2, "There Should Atleast Two Candidates"); // It Will Check Whether Candidates Are Greater Than 2 Or Not.
        uint256[] memory votes_ = new uint256[](candidates_.length);
        voting memory newVoting = voting({
            votingName: votingName_,
            description: description_,
            candidates: candidates_,
            votes: votes_,
            totalVotes: 0,
            isVotingStart: false,
            isVotingEnd: false
        });

        moderators[msg.sender].push(totalVotings); // Id Of Voting Is Pushed To Moderator Named Array Mapping.
        votings.push(newVoting);
        totalVotings++;
        return true;
    }

    // This Modifier Will Check Whether Voting Id Is Valid Or Not
    modifier isValidVotingId(uint256 votingId) {
        require((votingId < totalVotings), "Invalid Voting Id"); // It Will Check Whether Voting Exists.
        _;
    }

    // This Modifier Will Check That Whether Voting Id Available In Moderator Mapping Or Not.
    // If Voting Id Available In Moderator Mapping It Means They Has Actually Created Voting.
    modifier onlyModerator(uint256 votingId) {
        uint256[] memory votingIds = moderators[msg.sender];
        uint256 isAvailable = 0;
        for (uint256 i = 0; i < votingIds.length; i++) {
            if (votingIds[i] == votingId) {
                isAvailable = 1;
                break;
            }
        }
        require(isAvailable == 1, "Only Moderator Can Access This Method");
        _;
    }

    // This Method Will Start Voting And Only Moderator Can Invoke This Method.
    function startVoting(uint256 votingId)
        public
        isValidVotingId(votingId)
        onlyModerator(votingId)
    {
        require(
            (votings[votingId].isVotingEnd == false),
            "Voting Is Ended, You Cannot Restart Them"
        );
        votings[votingId].isVotingStart = true;
    }

    // This Method Will Return Result Of Voting And It Is Used In 'votingEnd' And 'votingResults' Method.
    function getWinner(uint256 votingId)
        internal
        view
        isValidVotingId(votingId)
        onlyModerator(votingId)
        returns (string memory)
    {
        uint256[] memory votes = votings[votingId].votes;
        uint256 winnerId = 0;
        for (uint256 i = 1; i < votes.length; i++) {
            if (votes[winnerId] < votes[i]) {
                winnerId = i;
            }
        }

        for (uint256 i = 0; i < votes.length; i++) {
            if ((winnerId != i) && (votes[winnerId] == votes[i])) {
                return "Voting Is Draw";
            }
        }
        return votings[votingId].candidates[winnerId];
    }

    // This Method Will End Voting And It Will Also Return Result Of Voting.
    // Only Moderator Can Invoke This Method.
    function endVoting(uint256 votingId)
        public
        isValidVotingId(votingId)
        onlyModerator(votingId)
        returns (string memory)
    {
        require(
            (votings[votingId].isVotingStart == true) &&
                (votings[votingId].isVotingEnd == false),
            "Without Starting Voting You Cannot End Them"
        );
        votings[votingId].isVotingStart = false;
        votings[votingId].isVotingEnd = true;

        string memory winner = getWinner(votingId);
        return winner;
    }

    // This Modifier Is Used To Verify Entered Details.
    modifier verifyDetails(uint256 votingId, uint256 candidateId) {
        require((votingId < totalVotings), "Invalid Voting Id"); // It Will Check Whether Voting Exists.
        require(candidateId <= votings[votingId].candidates.length); // It Will Check Whether Candiadte Id Exists.
        _;
    }

    // Using This Method Anyone Can Give Vote To Any Candidate.
    // Voter Can Only Give Vote Single Time.
    function giveVote(uint256 votingId, uint256 candidateId)
        public
        verifyDetails(votingId, candidateId)
        returns (bool)
    {
        require(votings[votingId].isVotingStart == true, "Voting Is Not Start");
        require(votings[votingId].isVotingEnd == false, "Voting Is End");
        require(voters[votingId][msg.sender] == false, "You Has Already Voted");
        voters[votingId][msg.sender] = true;
        votings[votingId].votes[candidateId] += 1;
        votings[votingId].totalVotes += 1;
        return true;
    }

    // This Method Will Return List Of Candidates Of Specified Voting.
    function candidatesName(uint256 votingId)
        public
        view
        isValidVotingId(votingId)
        returns (string[] memory)
    {
        string[] memory candidates = votings[votingId].candidates;
        return candidates;
    }

    // This Modifier Will Check That Whether Voting Is End Or Not
    modifier checkVotingEnd(uint256 votingId) {
        require(
            votings[votingId].isVotingEnd == true,
            "Result Can Declare After End Of Voting"
        );
        _;
    }

    // This Method Will Return Votes Obtained By Candidates Of Specified Voting.
    // It Will Be Accessible When Voting Will End.
    function votesInVoting(uint256 votingId)
        public
        view
        isValidVotingId(votingId)
        checkVotingEnd(votingId)
        returns (uint256[] memory)
    {
        uint256[] memory votes = votings[votingId].votes;
        return votes;
    }

    // This Method Will Display Result Of Votings, It Can Be Invoke By Anyone.
    // It Will Be Accessible When Voting Will End.
    function votingResults(uint256 votingId)
        public
        view
        isValidVotingId(votingId)
        checkVotingEnd(votingId)
        returns (string memory)
    {
        string memory winner = getWinner(votingId);
        return winner;
    }
}
