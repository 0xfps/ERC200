// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

/**
* @title IERC200Metadata
* @author Anthony (fps) https://github.com/0xfps.
* @author txcc https://github.com/zeroth-oc.
* @dev  This contract interface was inspired by OpenZeppelin 
*       [https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol].
* @dev  This interface seeks to isolate only the metadata for
*       the tokens created by an ERC200 contract.

* @notice   This was written on Christmas, Merry Christmas <3 :).
* @notice   This contract is not a confirmed EIP, it is only a project
*           done from a place of fun.
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
    
    /// @dev    Returns the decimals of all tokens.
    ///         For ease, all token decimals are set to 9.
    /// @return uint8 number of decimals.
    function decimals() external view returns (uint8);
}