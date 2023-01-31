// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import {IERC200} from "./interfaces/IERC200.sol";
import {IERC200Metadata} from "./interfaces/IERC200Metadata.sol";

import {Context} from "./utils/Context.sol";
import {Counter} from "./utils/Counter.sol";

/**
* @title ERC200 Token Standard.
* @author Anthony (fps) https://github.com/0xfps.
* @author txcc https://github.com/zeroth-oc.
* @dev  An implementation of the {IERC200} interface.
*       The goal of this contract, like stated in the tweets @
*       https://twitter.com/0xfps/status/1593336226349780993 and
*       https://twitter.com/0xfps/status/1606564497975549952,
*       is to create a contract capable of creating a batch of tokens
*       making it possible for individuals, DAOs or Web3 organizations to have
*       just one contract to create and take care of up to 10 different
*       tokens.
*
* @notice   This was written on Christmas, Merry Christmas <3 :).
* @notice   This contract is not a confirmed EIP, it is only a project
*           done from a place of fun.
* @notice   Refer to [file] => {function()}.
* @notice   The _mint function, _createToken function, tokens mapping
*           and balances mapping, and allowance mapping are all public
*           until testings are complete.
*/
abstract contract ERC200 is 
IERC200, 
Context, 
Counter 
{
    /// @dev Data for each created token.
    struct Tokens {
        bool valid;
        string name;
        string symbol;
        uint256 totalSupply;
    }

    /// @dev Mapping each token data to their unique ID.
    mapping(uint8 => Tokens) public tokens;
    /// @dev    Mapping addresses to the token IDs they own and then
    ///         to their balances on the token.
    mapping(address => mapping(uint8 => uint256)) public balances;
    /// @dev    Allowance mapping.
    ///         mapping(owner => spender => id => amount);
    mapping(address => mapping(address => mapping( uint8 => uint256))) public allowances;
}