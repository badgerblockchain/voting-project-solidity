// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Vote {
    struct Candidate {
        address walletAddress;
        string name;
        uint voteCount;
        string description;
    }

    struct Voter {
        bool hasVoted;
        Candidate votedFor;
    }

    Candidate[] public candidates;
    mapping(address => uint) public candidateIndex;
    mapping(address => Voter) public voterChoice;

    function addCandidate(string memory name, string memory description) external {
        if (candidates.length > 0) {
            require(
                candidates[candidateIndex[msg.sender]].walletAddress != msg.sender,
                "Candidate already exists"
            );
        }
        candidates.push(Candidate({
            walletAddress: msg.sender,
            name: name,
            voteCount: 0,
            description: description
        }));
        candidateIndex[msg.sender] = candidates.length - 1;
    }

    function changeName(string memory newName) external {
        uint idx = candidateIndex[msg.sender];
        require(candidates[idx].walletAddress == msg.sender, "Candidate not found");
        candidates[idx].name = newName;
    }

    function changeDescription(string memory newDescription) external {
        uint idx = candidateIndex[msg.sender];
        require(candidates[idx].walletAddress == msg.sender, "Candidate not found");
        candidates[idx].description = newDescription;
    }

    function getCandidates() external view returns (Candidate[] memory) {
        return candidates;
    }

    function vote(address candidate) external {
        require(!voterChoice[msg.sender].hasVoted, "Already voted");
        require(candidate != msg.sender, "Can't vote for yourself");

        uint idx = candidateIndex[candidate];

        voterChoice[msg.sender] = Voter({
            hasVoted: true,
            votedFor: candidates[idx]
        });

        candidates[idx].voteCount += 1;
    }

    function getVoteCount(address candidate) external view returns (uint) {
        return candidates[candidateIndex[candidate]].voteCount;
    }

    function getVoterChoice(address voter) external view returns (Candidate memory) {
        return voterChoice[voter].votedFor;
    }

    function getTopCandidate() external view returns (Candidate memory) {
        require(candidates.length > 0, "No candidates available");

        Candidate memory topCandidate = candidates[0];
        for (uint i = 1; i < candidates.length; i++) {
            if (candidates[i].voteCount > topCandidate.voteCount) {
                topCandidate = candidates[i];
            }
        }
        return topCandidate;
    }
}