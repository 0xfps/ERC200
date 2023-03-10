// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

/**
* @title Counter.
* @author Anthony (fps) https://github.com/0xfps.
* @author txcc https://github.com/zeroth-oc.
* @dev  This contract keeps count of all tokens creaeted by
*       the contract.

* @notice   This was written on Christmas, Merry Christmas <3 :).
* @notice   This contract is not a confirmed EIP, it is only a project
*           done from a place of fun.
*/
abstract contract Counter {
    /// @dev    Hold the number and id of the token to be
    ///         created. This is incremented per new token creation.
    ///         On deployment, token id 0 is created and it is incremented
    ///         token id 1 can then be created when desired.
    uint8 tokensCount;

    /// @dev Reverts if the 9 token limit is reached.
    error TokenLimitReached();
    
    /// @dev Checks to ensure that tokenCount doesn't exceed 10.
    function _beforeIncrement() internal view {
        /// @dev    Ensure that the count of tokens is less than 9.
        ///         ID runs from 0 - 9, i.e, 10 tokens per contract.
        ///         So, when token id 9 is created, it is incremented to
        ///         10, and will be in check.
        if (tokensCount >= 9) revert TokenLimitReached();
    }

    /// @dev Increment the `tokensCount` value by 1.
    function _increment() internal {
        unchecked {
            /// @dev Increment token count.
            tokensCount += 1;
        }
    }

    /// @dev    Returns the number of tokens created on the contract.
    ///         Number is incremented by
    function _count() internal view returns (uint8) {
        return tokensCount;
    }
}