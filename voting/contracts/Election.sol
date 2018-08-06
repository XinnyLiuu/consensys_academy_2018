pragma solidity ^0.4.0;

contract Election {
	/*
	 	Variables
	*/
	struct Candidate {
		uint id;
		string name;
		uint voteCount;
	}
	mapping(uint => Candidate) public candidates; // Store Candidates
	mapping(address => bool) public voters; // Store accounts that have voted
	uint public candidatesCount;

	/*
		Constructor
	*/
	constructor() public {
		addCandidate("Candidate 1");
		addCandidate("Candidate 2");
	}

	/*
		Functions
	*/
	function addCandidate(string _name) private {
		candidatesCount++;
		candidates[candidatesCount] = Candidate({
				id: candidatesCount,
				name: _name,
				voteCount: 0
			});
	}
	
	function vote(uint _candidateId) public {
		require(!voters[msg.sender]); // check that address has not voted
		require(_candidateId > 0 && _candidateId <= candidatesCount); // check that the id cannot be 0, and must be less than candidatesCount

		voters[msg.sender] = true; // Record voter has voted

		candidates[_candidateId].voteCount++; // Update candidates' vote count
	}
}
