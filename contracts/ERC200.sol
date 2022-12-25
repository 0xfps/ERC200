// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import {IERC200} from "./interfaces/IERC200.sol";

import {Context} from "./utils/Context.sol";
import {Counter} from "./utils/Counter.sol";

/**
* @title ERC200 Token Standard.
* @author Anthony (fps) https://github.com/0xfps.
* @dev  An implementation of the {IERC200} interface.
*       The goal of this contract, like stated in the tweets @
*       https://twitter.com/0xfps/status/1593336226349780993 and
*       https://twitter.com/0xfps/status/1606564497975549952,
*       is to create a contract capable of creating a batch of tokens
*       making it possible for DAOs or Web3 organizations to have
*       just one contract to create and take care of up to 10 different
*       tokens.

* @notice   This was written on Christmas, Merry Christmas <3 :).
* @notice   This contract is not a confirmed EIP, it is only a project
*           done from a place of fun.
*/
abstract contract ERC200 is 
IERC200, 
Context, 
Counter 
{
    struct Tokens {
        bool _valid;
        string _name;
        string _symbol;
        uint8 _decimals;
        uint256 _totalSupply;
    }

    mapping(uint8 => Tokens) private tokens;
    mapping(address => mapping(uint8 => uint256)) private balances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        _createToken(
            _name,
            _symbol,
            _decimals
        );
    }

    // function _mint(
    //     address _to, 
    //     uint8 _id, 
    //     uint256 _amount
    // ) internal {

    // }
    
    function _createToken(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) internal {
        Tokens memory newToken = Tokens(
            true,
            _name,
            _symbol,
            _decimals,
            0
        );

        tokens[tokensCount] = newToken;

        emit TokenCreation(tokensCount);
        
        _increment();
    }

    function _exists(uint8 _id) private view returns (bool) {
        return tokens[_id]._valid;
    }
}