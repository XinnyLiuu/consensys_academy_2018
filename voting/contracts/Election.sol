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
		Events
	*/
	event votedEvent(uint indexed _candidateId);

	/*
		Functions
	*/
	function addCandidate(string _name) private {
		// Tally candidatesCount
		candidatesCount++;

		// Set the value of the struct Candidate
		candidates[candidatesCount] = Candidate({
				id: candidatesCount,
				name: _name,
				voteCount: 0
			});
	}

	function vote(uint _candidateId) public {
		// check that address has not voted
		require(!voters[msg.sender]);

		// check that the id cannot be 0, and must be less than candidatesCount
		require(_candidateId > 0 && _candidateId <= candidatesCount);

		// Record voter has voted
		voters[msg.sender] = true;

		// Update candidates' vote count
		candidates[_candidateId].voteCount++;

		// Trigger voted event
		emit votedEvent(_candidateId);
	}


}
