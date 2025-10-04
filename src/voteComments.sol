// SPDX-License-Identifier: MIT
// License identifier required for Solidity contracts
// Why: The SPDX license identifier is required to specify the license under which the contract is published. This helps users and tools understand the legal terms for using, modifying, or distributing the contract code.
pragma solidity ^0.8.26; // Solidity compiler version

contract Vote { // Define the Vote contract
    // -----------------------
    // Data Structures
    // -----------------------

    struct Candidate {
        // Structure for candidate details
        address walletAddress; // Candidate’s Ethereum address (unique ID)
        string name; // Candidate’s display name
        uint256 voteCount; // Number of votes this candidate has received
        string description; // Candidate’s description/manifesto
    }

    struct Voter {
        // Structure for tracking voter’s status
        bool hasVoted; // Has this voter already voted?
        Candidate votedFor; // The candidate they voted for (snapshot of struct)
    }

    Candidate[] public candidates; // Dynamic array to store all candidates
    mapping(address => uint256) public candidateIndex; // Maps candidate address → index in candidates array
    mapping(address => Voter) public voterChoice; // Maps voter address → their voting status/choice

    // -----------------------
    // Candidate Functions
    // -----------------------

    function addCandidate(string memory name, string memory description) external {
        // If candidates exist, ensure sender is not already a candidate
        if (candidates.length > 0) {
            require(candidates[candidateIndex[msg.sender]].walletAddress != msg.sender, "Candidate already exists");
        }
        // Push new candidate struct into candidates array
        candidates.push(
            Candidate({
                walletAddress: msg.sender, // Candidate’s wallet is msg.sender
                name: name, // Candidate’s chosen name
                voteCount: 0, // Starts with 0 votes
                description: description // Candidate’s description
            })
        );
        // Store candidate’s index in mapping for quick lookup
        candidateIndex[msg.sender] = candidates.length - 1;
    }

    function changeName(string memory newName) external {
        uint256 idx = candidateIndex[msg.sender]; // Lookup candidate’s index
        require(
            candidates[idx].walletAddress == msg.sender, // Verify candidate exists
            "Candidate not found"
        );
        candidates[idx].name = newName; // Update candidate name
    }

    function changeDescription(string memory newDescription) external {
        uint256 idx = candidateIndex[msg.sender]; // Lookup candidate’s index
        require(
            candidates[idx].walletAddress == msg.sender, // Verify candidate exists
            "Candidate not found"
        );
        candidates[idx].description = newDescription; // Update candidate description
    }

    function getCandidates() external view returns (Candidate[] memory) {
        return candidates; // Return full list of candidates
    }

    // -----------------------
    // Voting Functions
    // -----------------------

    function vote(address candidate) external {
        require(!voterChoice[msg.sender].hasVoted, "Already voted"); // Ensure voter hasn’t voted before
        require(candidate != msg.sender, "Can't vote for yourself"); // Prevent self-voting

        uint256 idx = candidateIndex[candidate]; // Lookup candidate’s index in array

        // Record voter’s choice (copies the Candidate struct at time of vote)
        voterChoice[msg.sender] = Voter({hasVoted: true, votedFor: candidates[idx]});

        // Increment vote count for chosen candidate
        candidates[idx].voteCount += 1;
    }

    function getVoteCount(address candidate) external view returns (uint256) {
        // Return how many votes the candidate has
        return candidates[candidateIndex[candidate]].voteCount;
    }

    function getVoterChoice(address voter) external view returns (Candidate memory) {
        // Return candidate struct the voter chose
        return voterChoice[voter].votedFor;
    }

    function getTopCandidate() external view returns (Candidate memory) {
        require(candidates.length > 0, "No candidates available"); // Ensure at least 1 candidate exists

        Candidate memory topCandidate = candidates[0]; // Assume first candidate is leader
        for (uint256 i = 1; i < candidates.length; i++) {
            // Iterate through rest of candidates
            if (candidates[i].voteCount > topCandidate.voteCount) {
                // Compare votes
                topCandidate = candidates[i]; // Update topCandidate if higher
            }
        }
        return topCandidate; // Return candidate with highest votes
    }
}
