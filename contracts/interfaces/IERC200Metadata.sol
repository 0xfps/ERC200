// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

/**
* @title IERC200Metadata
* @author Anthony (fps) https://github.com/0xfps.
* @dev  This interface seeks to isolate only the metadata for
*       the tokens created by an ERC200 contract.
*/
interface IERC200Metadata {
    /// @dev Returns the number of tokens created by the contract.
    /// @return uint8 Number of tokens, [<= 10], [It runs from 0 - 9].
    function tokensCreated() external view returns (uint8);

    /// @dev Returns the name of tokenID `_id`
    /// @param _id Token Id.
    /// @return string Name of tokenID `_id`.
    function name(uint8 _id) external view returns (string memory);

    /// @dev Returns the symbol of tokenID `_id`
    /// @param _id Token Id.
    /// @return string Symbol of tokenID `_id`.
    function symbol(uint8 _id) external view returns (string memory);
    
    /// @dev Returns the decimals of tokenID `_id`
    /// @param _id Token Id.
    /// @return string Decimal of tokenID `_id`.
    function decimal(uint8 _id) external view returns (uint8);
}