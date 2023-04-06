// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @custom:security-contact nick.ivanov98@gmail.com
struct Project {
    string name;
    string description;
    string imageLink;
    uint fundingGoal;
    uint fundsRaised;
    uint deadline;
    address payable creator;
    mapping(address => uint256) contributions;
}
