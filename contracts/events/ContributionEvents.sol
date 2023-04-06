// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library ContributionEvents {
    event FundsContributed(
        uint256 projectId,
        address contributor,
        uint256 amount
    );

    event ContributionWithdrawn(
        uint256 projectId,
        address contributor,
        uint256 amount
    );
}
