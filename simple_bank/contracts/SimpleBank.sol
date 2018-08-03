pragma solidity ^0.4.13;
contract SimpleBank {

	/**
		Variables
	**/
  mapping (address => uint) private balances; // protect balance from other contracts
  mapping (address => bool) public enrolled; // We want a getter function
  address public owner; // make sure everyone knows who owns the bank

  /**
		Events
	**/
  event LogEnrolled(address accountAddress);
  event LogDepositMade(address accountAddress, uint amount);
	event LogWithdrawal(address accountAddress, uint withdrawAmount, uint newBalance);

	/**
		Constructor
	**/
  constructor() {
		owner = msg.sender;
  }

  /// @notice Enroll a customer with the bank
  /// @return The users enrolled status
  // Log the appropriate event
  function enroll() public returns (bool){
		enrolled[msg.sender] = true;
		emit LogEnrolled(msg.sender);
		return enrolled[msg.sender];
  }

  /// @notice Deposit ether into bank
  /// @return The balance of the user after the deposit is made
  // Add the appropriate keyword so that this function can receive ether
  function deposit() public payable returns (uint) {
    /*
		Add the amount to the user's balance, call the event associated with a deposit, then return the balance of the user
		*/
		balances[msg.sender] += msg.value;
		emit LogDepositMade(msg.sender, msg.value);
		return balances[msg.sender];
  }

  /// @notice Withdraw ether from bank
  /// @dev This does not return any excess ether sent to it
  /// @param withdrawAmount amount you want to withdraw
  /// @return The balance remaining for the user
  function withdraw(uint withdrawAmount) public returns (uint) {
    /*
		If the sender's balance is at least the amount they want to withdraw, subtract the amount from the sender's balance, and try to send that amount of ether to the user attempting to withdraw. 	If the send fails, add the amount back to the user's balance
   	return the user's balance.
		*/
		require(balances[msg.sender] >= withdrawAmount);
		balances[msg.sender] -= withdrawAmount;

		if(!msg.sender.send(withdrawAmount)) {
			balances[msg.sender] += withdrawAmount;
		}

		emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
		return balances[msg.sender];
  }

  /// @notice Get balance
  /// @return The balance of the user
  // A SPECIAL KEYWORD prevents function from editing state variables;
  // allows function to run locally/off blockchain
  function balance() public view returns (uint) {
    /*
		Get the balance of the sender of this transaction
		*/
		return balances[msg.sender];
  }

  // Fallback function - Called if other functions don't match call or
  // sent ether without data
  // Typically, called when invalid data is sent
  // Added so ether sent to this contract is reverted if the contract fails
  // otherwise, the sender's money is transferred to contract
  function() {
    revert();
  }
}
