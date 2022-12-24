// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

/**
* @title IERC200Receiver
* @author Anthony (fps) https://github.com/0xfps.
* @dev  This contract interface is to be implemented by
*       contracts that intend to receive tokens from an IERC200 contract.
*/
interface IERC200Receiver {
    /**
    * @dev  Called by the ERC200 contract implementer after transfer
    *       to external contract.
    *       This function shall return `onERC200Received.selector`.
    *
    * @notice For security, 0 tokens cannot be transferred.
    *
    * @param _to        Address receiving `_amount` tokens.
    * @param _id        Token ID to move.
    * @param _amount    Number of tokens to move to `to`.
    * @param _data      Encoded data.
    *
    * @return bytes4 `onERC200Received.selector`.
    */
    function onERC200Received(
        address _to, 
        uint8 _id, 
        uint256 _amount,
        bytes memory _data
    ) external returns(bytes4);
}