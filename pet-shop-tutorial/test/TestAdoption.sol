pragma solidity ^0.4.17;

import 'truffle/Assert.sol';
import 'truffle/DeployedAddresses.sol';
import '../contracts/Adoption.sol';

contract TestAdoption {
	Adoption adoption = Adoption(DeployedAddresses.Adoption());

	// Testing adopt()
	function testAdopt() public {
		uint returnedId = adoption.adopt(8);

		uint expected = 8;

		Assert.equal(returnedId, expected, "Adoption of petId 8 should be recorded");
	}

	// Testing getting single adopter by petId
	function testGetAdoptersByPetId() public {
		// expected is assigned to 'this', which is the global variable for the current contract address
		address expected = this;

		address adopter = adoption.adopters(8);

		Assert.equal(adopter, expected, "Owner of petId 8 should be recorded");
	}

	// Testing getting all adopters
	function testGetAdopters() public {

		address expected = this;

		address[16] memory adopters = adoption.getAdopters();

		Assert.equal(adopters[8], expected, "Owner of petId 8 should be recorded");
	}
}
