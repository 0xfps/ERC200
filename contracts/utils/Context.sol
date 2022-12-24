// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

/**
* @title Context.
* @author Anthony (fps) https://github.com/0xfps.
* @dev This contract only provides the context of a function caller.
*/
abstract contract Context {
    function msgSender() public view returns (address) {
        return msg.sender;
    }
}