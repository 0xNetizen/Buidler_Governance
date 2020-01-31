/**

This contract simulates the interactions of an individual user with the contract and tests all functions as it moves through different states.

The tests will be internal functions and will be called externally by one function. 

The tests will be separated by state since there needs to be a certain amount of time delay.

I will focus on just the function I'm most interested in first.

Some internal functions will simply be repeated many times.

The output of the smart contract will also need to be tested.

Will first start using it by deploying tests and other contracts separately. 

*/
pragma solidity ^0.5.0;
import "gov_v3.14.sol";
import "fake_dai.sol";

contract user_tests is DSMath{

	ERC20 public fakedai_Interface;
	IOnchain_gov public gov_interface;
	ERC20 public ERC_gov_interface;
	address gov_token_address;
	address gov_address;
	uint gov_balance;
	uint erc20_balance;
	uint buy_price_1;
	uint buy_price_2;
	uint sell_price_1;
	uint sell_price_2;

	uint debug_amount;
	
	uint init_buy_size;
    uint init_sell_size;

/**
	constructor() public {
		ERC20Interface = ERC20(_erc20);
		gov_interface = IOnchain_gov(_gov);
		ERC_gov_interface = ERC20(_gov);
		erc20 = _erc20;
		gov = _gov;
		init_sell_size = _init_sell_size;

	}*/

	//Can start with some functions being external and then make them internal later.
	
	/**
	function set_ERC20Interface(address _fake_dai) external {
	    ERC20Interface = ERC20(_fake_dai);
	} */

	event Set_init_sell_size(uint init_buy_size, uint init_sell_size);
    
	function set_init_sizes(uint _init_buy_size, uint _init_sell_size) public {
		
		init_buy_size = _init_buy_size;
		init_sell_size = _init_sell_size;
		
		emit Set_init_sell_size(_init_buy_size, _init_sell_size);
	}
 
	function ercBalance_msgsender() public view returns (uint) {
		return fakedai_Interface.balanceOf(msg.sender);
	}
	
	function ercBalance() public view returns (uint) {
		return fakedai_Interface.balanceOf(address(this));
	}

	function set_balances() public {
		erc20_balance = ercBalance();
		gov_balance = ERC_gov_interface.balanceOf(address(this));
	}
	function dai_balance_up_test(uint _amount) internal {
		require(_amount == sub(ercBalance(), erc20_balance), "dai_balance_up_test.");
		set_balances();
	}
	function gov_balance_up_test(uint _amount) internal {
		require(_amount == sub(ERC_gov_interface.balanceOf(address(this)), gov_balance), "gov_balance_up_test");
		set_balances();
	}

	function dai_balance_down_test(uint _amount) internal {
		require(_amount == sub(erc20_balance, ercBalance()), "dai_balance_down_test.");
		set_balances();
	}
	function gov_balance_down_test(uint _amount) internal {
		require(_amount == sub(gov_balance, ERC_gov_interface.balanceOf(address(this))), "gov_balance_down_test");
		set_balances();
	}


	

	


	//Reset test with refunds.
	//Could be made more efficient by using small amount instead of 1. 
	//Then balances could be tested for this amount. 

	event debug_value(uint value);

	function number1_start() public {
		fakedai_Interface.approve(gov_address, ercBalance());
		require (fakedai_Interface.allowance(address(this), gov_address) == ercBalance());
	}
	function number2_reset() public { 
		
		gov_interface.reset();
	}
	function number3_buy(uint _id) public {
	    set_balances();
		gov_interface.buy(_id, 1, init_buy_size);
		dai_balance_down_test(1);
		buy_price_1 = gov_interface.calculate_price(0,now);
	}
	
	function number4_sell(uint _id) public {
		set_balances();
		uint amount = wdiv(init_sell_size/100, gov_interface.calculate_price(1,now));
		gov_interface.sell(_id, amount, init_sell_size);
		gov_balance_down_test(amount);
		sell_price_1 = gov_interface.calculate_price(1,now);
	}
	function number5_close_buy(uint _id) public {
		set_balances();
		gov_interface.close_tranche_buy(_id, init_buy_size, init_buy_size);
		dai_balance_down_test(sub(init_buy_size,1));
		buy_price_2 = gov_interface.calculate_price(0,now);
	}
	function number6_close_sell(uint _id) public {
		set_balances();
		uint dai_amount_left = sub(init_sell_size, init_sell_size/100);
		uint token_equiv_left = wdiv(dai_amount_left, gov_interface.calculate_price(1,now));

		uint input_amount = wdiv(init_sell_size, gov_interface.calculate_price(1,now));

		gov_interface.close_tranche_sell(_id, input_amount, init_sell_size);
		gov_balance_down_test(token_equiv_left);
    }
		//It should now be possible to accept the reset proposal.
    function number7_close_buy_refund_creator(uint _id) public {
    	set_balances();
		//Create potential refunds:
		gov_interface.buy(_id, 1, 2 * init_buy_size);
		dai_balance_down_test(1);
    }
	function number8_close_sell_refund_creator(uint _id) public {
		set_balances();
		uint amount = wdiv(init_sell_size/100, gov_interface.calculate_price(1,now));

		gov_interface.sell(_id, amount, 2 * init_sell_size);
		gov_balance_down_test(amount);
		sell_price_2 = gov_interface.calculate_price(1,now);
    }
    
    function number9_accept_reset() public {
    	set_balances();

		//Accept reset and then try to get redemptions and refunds.
		gov_interface.accept_reset();
    }
    function number10_buy_redeem(uint _id) public {
		//Set balances
		set_balances();

		gov_interface.buy_redeem(_id, init_buy_size);
		gov_balance_up_test(wmul(1, buy_price_1));
    }
    function number11_sell_redeem(uint _id) public {
    	set_balances();
		gov_interface.sell_redeem(_id, init_sell_size);
		dai_balance_up_test(init_sell_size/100);
    }
    function number12_final_buy_redeem(uint _id) public {
    	set_balances();
		gov_interface.final_buy_redeem(_id, init_buy_size);
		gov_balance_up_test(wmul(sub(init_buy_size, 1), buy_price_2));
    }
    function number13_final_sell_redeem(uint _id) public {
    	set_balances();
		gov_interface.final_sell_redeem(_id, init_sell_size);
		dai_balance_up_test(sub(init_sell_size, init_sell_size/100));
    }
    
    function number14_buy_refund_accept(uint _id) public {
    	set_balances();
		gov_interface.buy_refund_accept(_id, 2 * init_buy_size);
		dai_balance_up_test(1);
    }
    function number15_sell_refund_accept(uint _id) public {
    	set_balances();
		gov_interface.sell_refund_accept(_id, 2 * init_sell_size);
		gov_balance_up_test(wdiv(init_sell_size/100, sell_price_2));
    }

    function submit_proposal(uint _amount, uint _pap_dai_buy_side, uint _pap_dai_sell_side) public {
    	set_balances();
    	gov_interface.submit_proposal(_amount, init_sell_size, [wdiv(WAD, wmul(2*WAD, _pap_dai_buy_side)), wdiv(_pap_dai_sell_side, WAD) , 1003858241594480000, 10**17], 7 * WAD, init_sell_size, 10, 10, 10);
    }

    function init_proposal(uint40 _id) public {
    	gov_interface.init_proposal(_id);
    }

    function accept_prop() public {
    	gov_interface.accept_prop();
    }

    function reject_spread() public {
    	gov_interface.reject_prop_spread();
    }

    function reject_timeout() public {
    	gov_interface.reject_prop_time();
    }

    function buy_refund_reject(uint _id) public {
    	gov_interface.buy_refund_reject(_id, init_buy_size);
    }

    function sell_refund_reject(uint _id) public {
    	set_balances();
    	gov_interface.sell_refund_reject(_id, init_sell_size);
    	gov_balance_up_test(wdiv(init_sell_size/100, sell_price_1));
    }


    
    function trade_run_through(uint _id) public {
        number3_buy(_id);
        number4_sell(_id);
        number5_close_buy(_id);
        number6_close_sell(_id);
        number7_close_buy_refund_creator(_id);
        number8_close_sell_refund_creator(_id);
    }
    
    function accept_redeem_run_through(uint _id) public {
        number10_buy_redeem(_id);
        number12_final_buy_redeem(_id);
        number13_final_sell_redeem(_id);
        number14_buy_refund_accept(_id);
        number15_sell_refund_accept(_id);
    }

    function submission_test_fail(uint _pap_dai_buy_side, uint _pap_dai_sell_side) public {
    	submit_proposal(init_sell_size/5, _pap_dai_buy_side, _pap_dai_sell_side);
    	submit_proposal(init_sell_size/10, _pap_dai_buy_side, _pap_dai_sell_side);
    }

    function submission_test_pass(uint40 _id, uint _pap_dai_buy_side, uint _pap_dai_sell_side) public {
    	set_balances();
    	submit_proposal(init_sell_size/10, _pap_dai_buy_side, _pap_dai_sell_side);
    	dai_balance_down_test(init_sell_size/1000);
    	submit_proposal(init_sell_size/5, _pap_dai_buy_side, _pap_dai_sell_side);
    	dai_balance_down_test(init_sell_size/1000);
    	init_proposal(_id);
    }

    




}

contract tests_and_dai is user_tests, onchain_gov_events{

	/**We want this contract to:
	- Deploy fakedai as a separate contract.  
	- Deploy user_tests within this contract via inheritance so its functions can be called.
	- Set the correct fakedai interface address.
	- Give fakedai to this contract so it can be used.

	For the gov child contract, we will need to:
	- Give correct test_and_dai_child address to constructor. 
	- Constructor calls a function in test_and_dai_child to set the correct gov address in user_tests.
	- Constructor calls a function in test_and_dai_child that reveals correct fakedai address and then sets the fakedai interface to that address.
	- Gov tokens are given to the test_and_dai_child address.
	- Initial tranche size is set in the test_and_dai_child contract.

	Looks like everything's done - test tomorrow.  
	*/

	constructor() public {
		fakedai_Interface = new fakedai();
	}

	function set_gov_interface(IOnchain_gov _gov_interface) external {

		gov_interface = _gov_interface;
		ERC_gov_interface = ERC20(address(_gov_interface));
	    gov_address = address(_gov_interface);
	    gov_token_address = address(_gov_interface);

	}

	function reveal_fakedai() external view returns (ERC20){
		return fakedai_Interface;
	}
    
	
	function get_balance(address _owner) public view returns (uint){
	    return fakedai_Interface.balanceOf(_owner);
	}
	
	




}