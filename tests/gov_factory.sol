pragma solidity ^0.5.0;
import "math.sol";
import "code_v3.14.sol";
import "erc20.sol";

contract tests_and_dai_interface{
	//Will just put in the necessary functions in here to get the gov_child working.
	event Set_init_tranche_size(uint tranche_size);

	function set_gov_interface(IOnchain_gov _gov_interface) external;

	function reveal_fakedai() external returns (ERC20);

	function set_init_sizes(uint _init_buy_size, uint _init_sell_size) public;
}

contract gov_factory is DSMath{
    
    onchain_gov public gov_interface;
    ERC20 public fakedai_Interface;
    

	constructor(tests_and_dai_interface _tests_and_dai) public {
	    
	    fakedai_Interface = _tests_and_dai.reveal_fakedai(); //Get fakedai_Interface
	    
	    uint _init_price = 1000000000000;
	    gov_interface = new onchain_gov(_init_price, fakedai_Interface);
	    uint _Supply = gov_interface.balanceOf(address(this));
	    
	    
	    
		_tests_and_dai.set_gov_interface(gov_interface); //Set correct gov_interface in tests_and_dai contract.
		
		
		
		gov_interface.transfer(address(_tests_and_dai), _Supply); //Transfer gov token supply to the _tests_and_dai contract. 
		
		_tests_and_dai.set_init_sizes(wmul(_Supply, _init_price)/100, wmul(_Supply, _init_price)/100);
		
		
	}

}