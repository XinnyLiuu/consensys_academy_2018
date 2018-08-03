pragma solidity ^0.4.23;

contract SupplyChain {

	// NOTE: SKU (stockkeeping unit, sometimes spelled "Sku") is an identification, usually alphanumeric, of a particular product that allows it to be tracked for inventory purposes.

	/**
		Variables
	**/
  address owner; // Owner
	uint skuCount; // Track most recent sku #
	mapping (uint => Item) public items; // maps sku to item
	enum State {
		ForSale, Sold, Shipped, Received
	}
	struct Item {
		string name;
		uint sku;
		uint price;
		State state;
		address seller;
		address buyer;
	}

	/**
		Events
	**/
	event ForSale(uint sku);
	event Sold(uint sku);
	event Shipped(uint sku);
	event Received(uint sku);

	/**
		Modifiers
	**/
	modifier checkOwner (address _owner) {
		require(msg.sender == _owner);
		_;
	}
  modifier verifyCaller (address _address) {
		require(msg.sender == _address);
		_;
	}
  modifier paidEnough (uint _price) {
		require(msg.value >= _price);
		_;
	}
  modifier checkValue (uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }
  modifier forSale (uint _sku) {
		require( items[_sku].state == State.ForSale );
		_;
	}
  modifier sold (uint _sku) {
		require( items[_sku].state == State.Sold );
		_;
	}
  modifier shipped (uint _sku) {
		require( items[_sku].state == State.Shipped );
		_;
	}
  modifier received (uint _sku) {
		require( items[_sku].state == State.Shipped );
		_;
	}

	/**
		Constructor
	**/
  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
		owner = msg.sender;
		skuCount = 0;
  }

	/**
		Functions
	**/
  function addItem(string _name, uint _price) public {
    emit ForSale(skuCount);
    items[skuCount] = Item({
			name: _name,
			sku: skuCount,
			price: _price,
			state: State.ForSale,
			seller: msg.sender,
			buyer: 0
		});
    skuCount = skuCount + 1;
  }

  function buyItem(uint sku)
		public
		payable
		forSale(sku)
		paidEnough(items[sku].price)
		checkValue(sku)
	{
		// Transfer money to seller
		items[sku].seller.transfer(items[sku].price);
		// Set buyer as the person who called this transaction
		items[sku].buyer = msg.sender;
		// Set state to Sold
		items[sku].state = State.Sold;
		// Call event
		emit Sold(sku);
	}

  function shipItem(uint sku)
		public
		sold(sku)
		checkOwner(items[sku].seller)
	{
		// Change the state of this item to shipped
		items[sku].state = State.Shipped;
		// Call Event
		emit Shipped(sku);
	}

  function receiveItem(uint sku)
		public
		shipped(sku)
		verifyCaller(items[sku].buyer)
	{
		// Change the state to recieved
		items[sku].state = State.Received;
		// Call Event
		emit Received(sku);
	}

	// TEST FUNCTION
  function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

}
