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

    /**
    * @inheritdoc IERC200Metadata
    */
    function tokensCreated() public view returns (uint8) {
        /// @dev Reference [Counter] => {_count}.
        return _count();
    }

    /**
    * @inheritdoc IERC200Metadata
    */
    function name(uint8 _id) public view returns (string memory) {
        if (!_exists(_id)) revert InexistentToken();
        return tokens[_id].name;
    }

    /**
    * @inheritdoc IERC200Metadata
    */
    function symbol(uint8 _id) public view returns (string memory) {
        if (!_exists(_id)) revert InexistentToken();
        return tokens[_id].symbol;
    }

    /**
    * @inheritdoc IERC200Metadata
    */
    function decimals() public pure returns (uint8) {
        return 9;
    }

    /**
    * @inheritdoc IERC200
    */
    function totalSupply(uint8 _id) public view returns (uint256) {
        if (!_exists(_id)) revert InexistentToken();
        return tokens[_id].totalSupply;
    }

    /**
    * @inheritdoc IERC200
    */
    function balanceOf(address _account, uint8 _id) public view returns (uint256) {
        if (_account == address(0)) revert ZeroAddress();
        if (!_exists(_id)) revert InexistentToken();
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
        /// @dev Get caller address.
        address owner = msgSender();
        /// @dev Ensure that the id is in existence.
        if (!_exists(_id)) revert InexistentToken();
        /// @dev Ensure that `_to` is not a zero address.
        if (_to == address(0)) revert ZeroAddress();
        /// @dev Ensure that a value of 0 is not transferred.
        if (_amount == 0) revert ZeroTokenTransfer();

        /// @dev Transfer tokens.
        _transfer(
            owner,
            _to, 
            _id, 
            _amount
        );

        /// @dev Emit the {Trasnfer} event.
        emit Transfer(owner, _to, _id, _amount);

        /// @dev Return true.
        return true;
    }

    /**
    * @inheritdoc IERC200
    */
    function approve(
        address _spender, 
        uint8 _id, 
        uint256 _amount
    ) public returns (bool) {
        /// @dev Get caller address.
        address owner = msgSender();
        /// @dev Ensure that the id is in existence.
        if (!_exists(_id)) revert InexistentToken();
        /// @dev Ensure that `_spender` is not a zero address.
        if (_spender == address(0)) revert ZeroAddress();
        /// @dev Ensure that a value of 0 is not approved.
        if (_amount == 0) revert ZeroTokenTransfer();
        /// @dev Ensure that the balance of the sender is > the amount to be approved.
        if (balances[owner][_id] < _amount) revert LowBalance();

        /// @dev Set allowance of `_spender` of token `_id` to the `_amount`.
        allowances[owner][_spender][_id] = _amount;

        /// @dev Emit the {Approval} event.
        emit Approval(owner, _spender, _id, _amount);

        /// @dev Return true.
        return true;
    }

    /**
    * @inheritdoc IERC200
    */
    function allowance(
        address _owner, 
        address _spender, 
        uint8 _id
    ) public view returns (uint256) {
        /// @dev Ensure that the id is in existence.
        if (!_exists(_id)) revert InexistentToken();
        /// @dev Return the allowance `_spender` can spend on `_owner`'s behalf.
        return allowances[_owner][_spender][_id];
    }

    /**
    * @inheritdoc IERC200
    */
    function transferFrom(
        address _from, 
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) public returns (bool) {
        /// @dev Get caller address.
        address spender = msgSender();
        /// @dev Ensure that the id is in existence.
        if (!_exists(_id)) revert InexistentToken();
        /// @dev Ensure that a value of 0 is not transferred.
        if (_amount == 0) revert ZeroTokenTransfer();
        /// @dev Ensure that `_from` is not a zero address.
        if (_from == address(0)) revert ZeroAddress();
        /// @dev Ensure that `_to` is not a zero address.
        if (_to == address(0)) revert ZeroAddress();
        /// @dev Ensure that the allowance of `msgSender()` is > the amount to be sent.
        if (allowance(_from, spender, _id) < _amount) revert LowAllowance();

        /// @dev Deduct from `msgSender`'s allowance.
        allowances[_from][spender][_id] -= _amount;

        /// @dev Transfer to `_to`.
        _transfer(_from, _to, _id, _amount);

        /// @dev Return true.
        return true;
    }

    /**
    * @dev  Subtracts from the total supply of an existing tokenID
    *       by removing an amount from an existing address' balance.
    *
    * @param _id        Token ID to burn.
    * @param _amount    Number of tokens to burn from `msgSender`.
    */
    function burn(
        uint8 _id, 
        uint256 _amount
    ) public {
        /// @dev Get caller address.
        address owner = msgSender();
        /// @dev Ensure that the id is in existence.
        if (!_exists(_id)) revert InexistentToken();
        /// @dev Ensure that `_to` is not a zero address.
        if (owner == address(0)) revert ZeroAddress();
        /// @dev Ensure that the balance of msgSender is > _amount.
        if (balances[owner][_id] < _amount) revert LowBalance();
        /// @dev Ensure that value burnt is not 0.
        if (_amount == 0) revert ZeroTokenTransfer();

        /// @dev Subtract from caller's balance.
        balances[owner][_id] -= _amount;
        /// @dev Subtract from token ID's total supply.
        tokens[_id].totalSupply -= _amount;

        /// @dev Emit the {Trasnfer} event.
        emit Transfer(owner, address(0), _id, _amount);
    }

    /**
    * @dev  Transfers tokens between two addresses by 
    *       adding to the token balances of `_to` and subtracting
    *       from token balances of `_from` on token ID `_id`.
    *
    * @param _from      Address sending tokens.
    * @param _to        Address receiving `_amount` tokens.
    * @param _id        Token ID to move.
    * @param _amount    Number of tokens to move to `to`.
    */
    function _transfer(
        address _from,
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) internal {
        /// @dev Ensure that the balance of the `_from` is > the amount to be sent.
        if (balances[_from][_id] < _amount) revert LowBalance();
        /// @dev Subtract from token balance of `_from`.
        balances[_from][_id] -= _amount;
        /// @dev Add to token balances of `_to`.
        balances[_to][_id] += _amount;
    }

    /**
    * @dev  Adds to the total supply of an existing tokenID
    *       by adding an amount to an existing address' balance.
    *
    * @param _to        Address receiving `_amount` tokens.
    * @param _id        Token ID to mint.
    * @param _amount    Number of tokens to mint to `to`.
    */
    function _mint(
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) internal {
        /// @dev Ensure that the id is in existence.
        if (!_exists(_id)) revert InexistentToken();
        /// @dev Ensure that `_to` is not a zero address.
        if (_to == address(0)) revert ZeroAddress();
        /// @dev Ensure that a value of 0 is not minted.
        if (_amount == 0) revert ZeroTokenTransfer();

        /// @dev Add to the balances of `_to` for tokenID.
        balances[_to][_id] += _amount;
        /// @dev Increment the totalSypply of token ID.
        tokens[_id].totalSupply += _amount;

        /// @dev Emit the {Trasnfer} event.
        emit Transfer(address(0), _to, _id, _amount);
    }

    /**
    * @dev  This function creates a new token when called, on the
    *       condition that the `tokenCount` doesn't exceed the limit.
    *       The token data for a newly created token are stored in the
    *       `Tokens` struct.
    *       Callers do no need to set a totalSupply.
    *       The `_mint()` function to do the work.
    *       This emits the {TokenCreation} event.
    *
    * @param _name      Name of new token.
    * @param _symbol    Symbol of the new token.
    */
    function _createToken(
        string memory _name,
        string memory _symbol
    ) public {
        /// @dev Refer to [utils/Counter.sol] => {_beforeIncrement()}.
        _beforeIncrement();

        /// @dev Copy new token to memory.
        Tokens memory newToken = Tokens(
            true,
            _name,
            _symbol,
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