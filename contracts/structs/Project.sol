// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @custom:security-contact nick.ivanov98@gmail.com
struct ProjectStructure {
    bytes name;
    bytes description;
    address owner;
    uint256 goal;
    uint256 deadline;
}
