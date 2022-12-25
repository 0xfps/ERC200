// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import {IERC200} from "./interfaces/IERC200.sol";
import {IERC200Metadata} from "./interfaces/IERC200Metadata.sol";

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
* @notice   Refer to [file] => {function()}.
*/
contract ERC200 is 
IERC200, 
Context, 
Counter 
{
    /// @dev Data for each created token.
    struct Tokens {
        bool valid;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
    }

    /// @dev Mapping each token data to their unique ID.
    mapping(uint8 => Tokens) private tokens;
    /// @dev    Mapping addresses to the token IDs they own and then
    ///         to balances.
    mapping(address => mapping(uint8 => uint256)) private balances;
    /// @dev    Allowance mapping.
    ///         mapping(owner => spender => id => amount);
    mapping(address => mapping(address => mapping( uint8 => uint256))) private allowances;


    /**
    * @dev  On deployment, a new token [Parent Token, maybe] must be created.
    *       Some callers will not need to set a `_totalSupply` value.
    *       The `_mint()` function to do the work.
    *
    * @param _name      Name of parent token.
    * @param _symbol    Symbol of the parent token.
    * @param _decimals  Decimals for the parent token.
    *                   This is to allow flexibility as different tokens
    *                   may contain different decimals.
    */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        /// @dev Create token.
        _createToken(
            _name,
            _symbol,
            _decimals
        );
    }

    /**
    * @inheritdoc IERC200Metadata
    */
    function tokensCreated() public view returns (uint8) {
        return tokensCount;
    }

    /**
    * @inheritdoc IERC200Metadata
    */
    function name(uint8 _id) public view returns (string memory) {
        require(_exists(_id), "Query for invalid token.");
        return tokens[_id].name;
    }

    /**
    * @inheritdoc IERC200Metadata
    */
    function symbol(uint8 _id) public view returns (string memory) {
        require(_exists(_id), "Query for invalid token.");
        return tokens[_id].symbol;
    }

    /**
    * @inheritdoc IERC200Metadata
    */
    function decimals(uint8 _id) public view returns (uint8) {
        require(_exists(_id), "Query for invalid token.");
        return tokens[_id].decimals;
    }

    /**
    * @inheritdoc IERC200
    */
    function totalSupply(uint8 _id) public view returns (uint256) {
        require(_exists(_id), "Query for invalid token.");
        return tokens[_id].totalSupply;
    }

    /**
    * @inheritdoc IERC200
    */
    function balanceOf(address _account, uint8 _id) public view returns (uint256) {
        require(_account != address(0), "Query for 0 address.");
        require(_exists(_id), "Query for invalid token.");
        return balances[_account][_id];
    }

    /**
    * @inheritdoc IERC200
    */
    function transfer(
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) public returns (bool) {
        require(_exists(_id), "Query for invalid token.");
        require(_to != address(0), "Transfer to 0 address.");
        require(_amount != 0, "0 Transfer.");
        require(balances[msgSender()][_id] >= _amount, "Amount < Balance.");

        _transfer(
            msgSender(),
            _to, 
            _id, 
            _amount
        );

        emit Transfer(msgSender(), _to, _id, _amount);

        return true;
    }

    function approve(
        address _spender, 
        uint8 _id, 
        uint256 _amount
    ) public returns (bool) {
        require(_exists(_id), "Query for invalid token.");
        require(_spender != address(0), "Approval to 0 address.");
        require(_amount != 0, "0 Approval.");
        require(balances[msgSender()][_id] >= _amount, "Amount < Balance.");

        allowances[msgSender()][_spender][_id] = _amount;

        emit Approval(msgSender(), _spender, _id, _amount);

        return true;
    }

    function allowance(
        address _owner, 
        address _spender, 
        uint8 _id
    ) public view returns (uint256) {
        require(_exists(_id), "Query for invalid token.");
        return allowances[_owner][_spender][_id];
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) external returns (bool) {
        require(_exists(_id), "Query for invalid token.");
        require(_amount != 0, "0 Transfer.");
        require(_to != address(0), "Transfer to 0 address.");
        require(allowance(_from, _to, _id) > _amount, "Allowance < Amount.");

        allowances[_from][msgSender()][_id] -= _amount;

        _transfer(_from, _to, _id, _amount);

        return true;
    }

    function _transfer(
        address _from,
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) internal {
        balances[_from][_id] -= _amount;
        balances[_to][_id] += _amount;
    }

    function _mint(
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) internal {
        require(_exists(_id), "Query for invalid token.");
        require(_to != address(0), "Mint to 0 address.");
        require(_amount != 0, "0 Transfer.");

        balances[_to][_id] += _amount;
        tokens[_id].totalSupply += _amount;
    }

    function burn(
        address _from, 
        uint8 _id, 
        uint256 _amount
    ) internal {
        require(_exists(_id), "Query for invalid token.");
        require(_from != address(0), "Mint to 0 address.");
        require(balances[_from][_id] >= _amount, "Amount > Balance.");
        require(_amount != 0, "0 Transfer.");

        balances[_from][_id] -= _amount;
        tokens[_id].totalSupply -= _amount;
    }
    
    /**
    * @dev  This function creates a new token when called, on the
    *       condition that the `tokenCount` doesn't exceed the limit.
    *       The token data for a newly created token are stored in the
    *       `Tokens` struct.
    *       The `_mint()` function to do the work.
    *       This emits the {TokenCreation} event.
    *
    * @param _name      Name of new token.
    * @param _symbol    Symbol of the new token.
    * @param _decimals  Decimals for the new token.
    */
    function _createToken(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) internal {
        /// @dev Refer to [utils/Counter.sol] => {_beforeIncrement()}.
        _beforeIncrement();

        /// @dev Create a new token to memory.
        Tokens memory newToken = Tokens(
            true,
            _name,
            _symbol,
            _decimals,
            0
        );

        /// @dev Set the Token Data to it's latest token ID.
        tokens[tokensCount] = newToken;

        /// @dev Emit the {TokenCreation} event.
        emit TokenCreation(tokensCount);
        
        /// @dev Increment the `tokenCount` by 1.
        _increment();
    }

    /// @dev Returns true if token id `_id` is valid.
    /// @param _id      Token ID to check validity.
    /// @return bool    True or false.
    function _exists(uint8 _id) private view returns (bool) {
        /// @dev Return `_valid` value.
        return tokens[_id].valid;
    }
}