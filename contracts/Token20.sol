//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token20 is ERC20, Ownable{

    constructor(uint totalAmount, address contractToApproveAmount)ERC20("MyToken", "MTK"){
        _mint(msg.sender, totalAmount);
        approve(contractToApproveAmount, totalAmount);
    }

}
