const App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:9545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

	// Inititalizes the contract, and sets the web3Provider
	initContract: function() {
		$.getJSON("Election.json", function(election) {
			// Instantiate a new truffle contract from the artifact
			App.contracts.Election = TruffleContract(election);
			// Connect the provider to interact with contract
			App.contracts.Election.setProvider(App.web3Provider);

			App.listenForEvents(); // Listens for events

			return App.render();
		});
	},

	// Rendering the front end for the dApp
	render: function() {
		let electionInstance;
		const loader = $('#loader');
		const content = $('#content');

		loader.show();
		content.hide();

		// Load account data
		web3.eth.getCoinbase(function(err, account) {
			if(err === null) {
				App.account = account;
				$("#accountAddress").html("Your account: " + account);
			}
		});

		// Load contract data
		App.contracts.Election.deployed()
		.then(function(instance) {
			electionInstance = instance;
			return electionInstance.candidatesCount();
		})
		.then(function(candidatesCount) {
			const candidatesResults = $("#candidatesResults");
			candidatesResults.empty();

			const candidatesSelect = $('#candidatesSelect');
			candidatesSelect.empty();

			// Loop through each Candidate in candidates to properly render the front end
			for(let i=1; i <= candidatesCount; i++) {
				electionInstance.candidates(i)
				.then(function(candidate) {
					let id = candidate[0];
					let name = candidate[1];
					let voteCount = candidate[2];

					// Render the result
					const candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + voteCount + "</td></tr>";
					candidatesResults.append(candidateTemplate);

					// Render ballot option
					const candidateOption = "<option value ='" + id + "'>" + name + "</ option>";
					candidatesSelect.append(candidateOption);
				});
			};

			return electionInstance.voters(App.account);
		})
		.then(hasVoted => {

			if(hasVoted) { // ensures that the users that have voted will not be able to vote again.
				$('form').hide();
			}

			loader.hide();
			content.show();
		})
		.catch(err => {
			console.warn(err);
		});
	},

	// Allows for casting of votes, then hide the content and show the loader
	castVote: function() {
		const candidateId = $('#candidatesSelect').val();
		App.contracts.Election.deployed()
		.then(instance => {
			electionInstance = instance;
			return electionInstance.vote(candidateId, { from: App.account });
		})
		.then(result => {
			$('#content').hide();
			$('#loader').show();
		})
		.catch(err => {
			console.error(err);
		});
	},

	// Listens for Events, and reloads the App
	listenForEvents: function() {
		App.contracts.Election.deployed()
		.then(instance => {
			electionInstance = instance;
			electionInstance.votedEvent({}, {
				fromBlock: 0,
				toBlock: 'latest'
			})
			.watch((error, event) => {
				console.log("event triggered", event);

				// Reload when a new vote is recorded
				App.render()
			});
		});
	}
};

$(function() {
	$(window).load(() => {
		App.init();
	});
});
