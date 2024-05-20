// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract KK is ERC20, Ownable {
    constructor() ERC20("KK","KK") Ownable(msg.sender){

    }


    function mint(address sender, uint128 amount) public {
        require(amount > 0, "Minted amount must be greater thah 0");
        _mint(sender, amount);
    }



    function burn(uint128 amount) public  {
        require(amount > 0, "Burned amount must be greater thah 0");
        _burn(msg.sender, amount);
    }

}