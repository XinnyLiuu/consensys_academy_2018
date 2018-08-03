App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load pets.
    $.getJSON('../pets.json', function(data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');

      for (i = 0; i < data.length; i ++) {
        petTemplate.find('.panel-title').text(data[i].name);
        petTemplate.find('img').attr('src', data[i].picture);
        petTemplate.find('.pet-breed').text(data[i].breed);
        petTemplate.find('.pet-age').text(data[i].age);
        petTemplate.find('.pet-location').text(data[i].location);
        petTemplate.find('.btn-adopt').attr('data-id', data[i].id);

        petsRow.append(petTemplate.html());
      }
    });

    return App.initWeb3();
  },

  initWeb3: function() {
		// Required for the web app to connect to the ethereum blockchain
		if(typeof web3 !== 'undefined') {
			App.web3Provider = web3.currentProvider;
		} else {
			// if not web3 instance is detected, fall back to Ganache
			App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545/');
		}
		web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
		$.getJSON('Adoption.json', function(data) {
			// Get necessary contract artifact file and instantiate it with truffle-contract
			let AdoptionArtifact = data;
			App.contracts.Adoption = TruffleContract(AdoptionArtifact);

			// Set provider for our contract
			App.contracts.Adoption.setProvider(App.web3Provider);

			// Use our contract to retrieve and mark the adopted pets
			return App.markAdopted();
		});

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  markAdopted: function(adopters, account) {
		let adoptionInstance; // variable for storing the adoption instance

		// We want to access the deployed Adoption contract
		App.contracts.Adoption.deployed()
		.then(instance => {
			// Then we stored the deployed contract asa adoptionInstance
			adoptionInstance = instance;

			// After, we will access the getAdopters() function from the contract so we can loop through all our addresses to mark pets as adopted
			return adoptionInstance.getAdopters.call();
		})
		.then(adopters => {
			// Here, we loop through each adopter, and check its address for an empty address, if the address is not empty, then it means that the pet has been adopted already and we change the ui accordingly
			for(let i=0; i<adopters.length; i++) {

				if(adopters[i] !== '0x0000000000000000000000000000000000000000') {

					$('.panel-pet').eq(i).find('button').text('Success').attr('disabled', true);
				};
			};
		}).catch(err => {
			console.log(err);
		});
  },

  handleAdopt: function(event) {
    event.preventDefault();

    const petId = parseInt($(event.target).data('id'));

		let adoptionInstance;

		// We will use web3 to get the user's accounts,
		web3.eth.getAccounts((err, accounts) => {
			if(err) {
				console.log(err);
			}

			// The first account can be assumed to be the user's account
			const account = accounts[0];

			// We want to access the deployed Adoption contract
			App.contracts.Adoption.deployed()
			.then(instance => {
				adoptionInstance = instance;

				// Here, we are executing the adopt() function from our Adoption contract and pass in the values necessary for the function
				// The 'from:' is needed as we are using the adopt() as a transaction which requires an account/address
				return adoptionInstance.adopt(petId, {from: account});
			})
			.then(result => {
				// Finally, if no errors occurs, we will proceed to update ui with our data changes
				return App.markAdopted();
			})
			.catch(err => {
				console.log(err);
			})
		})

  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
