// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract VotingSystem {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateIndex;
    }

    address public admin;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint256 public votingStart;
    uint256 public votingEnd;

    event CandidateAdded(string name);
    event VoterRegistered(address voter);
    event VoteCast(address voter, uint256 candidateIndex);
    event VotingStarted(uint256 startTime, uint256 endTime);
    event VotingEnded(string winningCandidateName, uint256 winningVoteCount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier votingNotStarted() {
        require(votingStart == 0, "Voting has already started");
        _;
    }

    modifier duringVotingPeriod() {
        require(
            votingStart != 0 && block.timestamp >= votingStart && block.timestamp <= votingEnd,
            "Not within voting period"
        );
        _;
    }

    constructor() {
        require(msg.sender != address(0), "Invalid deployer address");
        admin = msg.sender;
        votingStart = 0;
        votingEnd = 0;
    }

    function addCandidate(string memory _name) public onlyAdmin votingNotStarted {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        candidates.push(Candidate({
            name: _name,
            voteCount: 0
        }));
        emit CandidateAdded(_name);
    }

    function registerVoter(address _voter) public onlyAdmin votingNotStarted {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter already registered");
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateIndex: 0
        });
        emit VoterRegistered(_voter);
    }

    function startVoting(uint256 _durationInMinutes) public onlyAdmin votingNotStarted {
        require(candidates.length >= 2, "At least two candidates required");
        require(_durationInMinutes > 0, "Duration should be greater than 0");
        votingStart = block.timestamp;
        votingEnd = votingStart + (_durationInMinutes * 1 minutes);
        emit VotingStarted(votingStart, votingEnd);
    }

    function vote(uint256 _candidateIndex) public duringVotingPeriod {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "Not registered to vote");
        require(!sender.hasVoted, "Already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate index");

        sender.hasVoted = true;
        sender.votedCandidateIndex = _candidateIndex;
        candidates[_candidateIndex].voteCount++;

        emit VoteCast(msg.sender, _candidateIndex);
    }

    function endVoting() public onlyAdmin {
        require(block.timestamp > votingEnd, "Voting period not yet over");
        require(votingStart != 0, "Voting never started");

        uint256 winningVoteCount = 0;
        uint256 winningCandidateIndex = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }

        emit VotingEnded(candidates[winningCandidateIndex].name, winningVoteCount);
    }

    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    function getVotingTimeRemaining() public view returns (uint256) {
        if (block.timestamp >= votingEnd) return 0;
        if (block.timestamp < votingStart) return votingEnd - votingStart;
        return votingEnd - block.timestamp;
    }
}