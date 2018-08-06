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
	mapping(uint => Candidate) public candidates;
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
}
