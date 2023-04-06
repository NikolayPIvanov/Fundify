// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library ProjectEvents {
    event ProjectCreated(
        uint256 projectId,
        string name,
        string description,
        string imageLink,
        uint256 fundingGoal,
        uint256 deadline,
        address creator
    );

    event FundingGoalReached(uint256 projectId, uint256 fundsRaised);
}
