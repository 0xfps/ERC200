// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import {IERC200Receiver} from "./IERC200Receiver.sol";
import {IERC200Metadata} from "./IERC200Metadata.sol";

/**
* @title IERC200.
* @author Anthony (fps) https://github.com/0xfps.
* @dev  Inspired by https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol.
*       Interface of the ERC200 contract.
*/

interface IERC200 is IERC200Metadata, IERC200Receiver {
    /**
    * @dev Emitted when `value` tokens of tokenID `id` are moved 
    *      from one account (`from`) to another (`to`).
    */
    event Transfer(
        address indexed from, 
        address indexed to, 
        uint8 indexed id, 
        uint256 value
    );

    /**
    * @dev  Emitted when the allowance of a `spender` for an `owner` of tokenID `id` 
    *       is set by a call to {approve}. `value` is the new allowance.
    */
    event Approval(
        address indexed owner, 
        address indexed spender, 
        uint8 indexed id, 
        uint256 value
    );

    /**
    * @dev Returns the amount of tokens in existence for tokenID `_id`.
    *
    * @param _id Token id.
    *
    * @return uint256 Amount of tokens in existence.
    */
    function totalSupply(uint8 _id) external view returns (uint256);

    /**
    * @dev Returns the amount of tokens of tokenID `_id` owned by `_account`.
    *
    * @param _account Address to return its token amount.
    * @param _id Token id.
    *
    * @return uint256 Amount of tokens in existence.
    */
    function balanceOf(address _account, uint8 _id) external view returns (uint256);

    /**
    * @dev  Moves `_amount` tokens of tokenID `_id` from the caller's account to `_to`.
    *       Returns a boolean value indicating whether the operation succeeded.
    *       Emits a {Transfer} event.
    *
    * @notice For security, 0 tokens cannot be transferred.
    *
    * @param _to        Address receiving `_amount` tokens.
    * @param _id        Token ID to move.
    * @param _amount    Number of tokens to move to `to`.
    *
    * @return bool Status of the operation.
    */
    function transfer(
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) external returns (bool);

    /**
    * @dev  Returns the remaining number of tokens of tokenId `_id`
    *       that `_spender` will be allowed to spend on behalf of 
    *       `owner` through {transferFrom}. This is
    *       zero by default.
    *
    * @notice This value changes when {approve} or {transferFrom} are called.
    *
    * @param _owner     Token owner.
    * @param _spender   Address delegated to spend some tokens.
    * @param _id        Id of token to be spent.
    *
    * @return uint256 Amount of tokens allocated as allowance to `_spender`
    */
    function allowance(
        address _owner, 
        address _spender, 
        uint8 _id
    ) external view returns (uint256);

    /**
    * @dev  Sets an `_amount` of tokenId `_id` as the allowance of `_spender` 
    *       over the caller's tokens.
    *       Returns a boolean value indicating whether the operation succeeded.
    *       Emits an {Approval} event.
    *
    * @param _spender   Address allowance is allocated to.
    * @param _id        Token ID allocated.
    * @param _amount    Amount of tokens in tokenID `_id` allocated.
    * 
    * @return bool Status of the operation.
    */
    function approve(
        address _spender, 
        uint8 _id, 
        uint256 _amount
    ) external returns (bool);

    /**
    * @dev  Moves `_amount` tokens of tokenId `_id` from `from` to `to` using the
    *       allowance mechanism. `amount` is then deducted from the caller's
    *       allowance.
    *       Returns a boolean value indicating whether the operation succeeded.
    *       Emits a {Transfer} event.
    *
    * @param _from      Address sending the token.
    * @param _to        Address receiving `_amount` tokens.
    * @param _id        Token ID to move.
    * @param _amount    Number of tokens to move to `to`.
    *
    * @return bool Status of the operation.
    */
    function transferFrom(
        address _from, 
        address _to, 
        uint8 _id, 
        uint256 _amount
    ) external returns (bool);
}