pragma solidity ^0.5.0;
import "base.sol";

contract fakedai is TokenBase(10 **21) {
    uint public _init_supply;
    constructor() public {
        _init_supply = _supply;
    }
    
}
