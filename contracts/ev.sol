// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        // string voterID;
        bool isRegistered;
        bool voted;
        uint256 vote;
        // uint256 constituencyIndex;
    }
    
    struct Constituency {
        uint256 index;
    }

    address public owner;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    bool public votingOpen;
    bool public votingEnded;

    // Events
    event CandidateAdded(string candidateName);
    event VotingStarted();
    event VoteCast(address voter, uint256 candidateIndex);
    event VotingEnded();
    event WinnerDeclared(string winnerName, uint256 winnerVoteCount);
    event MajorityReached();
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier votingIsOpen() {
        require(votingOpen, "Voting is not open");
        require(!votingEnded, "Voting has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // function addVoter(string votID, uint256 constIndex) public onlyOwner {
    //     require(!votingOpen, "Cannot add voters after voting has started");
    //     voters.push(Voter({
    //         voterID: votID,
    //         voted: false,
    //         vote: -1,
    //         constituencyIndex: constIndex 
    //     }));
    //     emit VoterAdded();
    // }
       function addCandidate(string memory candidateName) public onlyOwner {
        require(!votingOpen, "Cannot add candidates after voting has started");
        candidates.push(Candidate({
            name: candidateName,
            voteCount: 0
        }));
        emit CandidateAdded(candidateName);
    }

    // function registerVoter(address _voter, uint256 constIndex) public onlyOwner{
    //     // require(!voters[_voter].isRegistered, "Voter is already registered");
    //     voters.push(Voter({
    //         // isRegistered: true,
    //         voted: false,
    //         vote: -1,
    //         constituencyIndex: constIndex
    //     }));
    // }
    function registerVoter(address _voter) public onlyOwner {
        require(!voters[_voter].isRegistered, "Voter is already registered");
        voters[_voter] = Voter(true, false, 0);
        // emit VoterRegistered(_voter);
        }

    function startVoting() public onlyOwner {
        require(!votingOpen, "Voting has already started");
        votingOpen = true;
        emit VotingStarted();
    }

    function vote(uint256 candidateIndex) public votingIsOpen {
        require(!voters[msg.sender].voted, "You have already voted");
        require(candidateIndex < candidates.length, "Invalid candidate index");

        voters[msg.sender].voted = true;
        voters[msg.sender].vote = candidateIndex;
        candidates[candidateIndex].voteCount += 1;

        emit VoteCast(msg.sender, candidateIndex);
    }

    function endVoting() public onlyOwner votingIsOpen {
        votingEnded = true;
        votingOpen = false;
        emit VotingEnded();
    }

    function getWinner() public returns (string memory winnerName, uint256 winnerVoteCount) {
        require(votingEnded, "Voting is still ongoing");

        uint256 winningVoteCount = 0;
        uint256 winningIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningIndex = i;
            }
        }

        winnerName = candidates[winningIndex].name;
        winnerVoteCount = winningVoteCount;

        emit WinnerDeclared(winnerName, winnerVoteCount);
    }

    function getCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }
}