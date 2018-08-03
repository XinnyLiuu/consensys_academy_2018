pragma solidity ^0.4.17;

contract Adoption {
	address[16] public adopters; // Array of addresses

	// Adopting a pet
	function adopt(uint petId) public returns(uint) {
		require(petId >= 0 && petId <= 15	);

		// Using the petId, we will store the User's address (msg.sender) in index of petId inside of our array adopters
		adopters[petId] = msg.sender;

		return petId; // Returns petId
	}

	// Retrieving the adopters
	function getAdopters() public view returns(address[16]) {
		// Return the array of addresses in adopters
		return adopters;
	}
}
