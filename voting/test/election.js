const Election = artifacts.require('./Election.sol');

contract("Election", function(accounts) {
	let electionInstance;

	// Checks if the total number of candidatesCount is 2
	it("initializes with two candidates", function() {
		return Election.deployed()
		// NOTE: returning Election.deployed() allows us to access the contract 'Election', and read its contents
		.then(function(instance) {
			electionInstance = instance;
			return electionInstance.candidatesCount();
		})
		.then(function(count) {
			assert.equal(count, 2);
		});
	});


	// Checks if id, name, and votes are correct
	it("initializes the candidates with the correct values", function() {
		return Election.deployed()
		.then(function(instance) {
			electionInstance = instance;
			return electionInstance.candidates(1);
		})
		.then(function(candidate) {
			assert.equal(candidate[0], 1, "contains the correct id");
			assert.equal(candidate[1], "Candidate 1", "contains the correct name");
			assert.equal(candidate[2], 0, "contains the correct votes count");
			return electionInstance.candidates(2);
		})
		.then(function(candidate) {
			assert.equal(candidate[0], 2, "contains the correct id");
			assert.equal(candidate[1], "Candidate 2", "contains the correct name");
			assert.equal(candidate[2], 0, "contains the correct votes count");
		});
	});
});
