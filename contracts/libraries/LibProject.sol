// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Project} from "../structs/Project.sol";

library LibProject {
    uint256 public constant MAX_PROJECT_NAME_LENGTH = 32;
    uint256 public constant MIN_PROJECT_NAME_LENGTH = 1;

    function createProject(
        bytes calldata name,
        bytes calldata description,
        uint256 goal,
        uint256 deadline
    ) internal view returns (Project memory) {
        require(_isValid(name), "Invalid project name.");
        require(_isValid(description), "Invalid project description.");
        require(goal > 0, "Invalid project goal.");
        require(deadline > block.timestamp, "Invalid project deadline.");

        return Project(name, description, msg.sender, goal, deadline, 0);
    }

    function _isValid(bytes memory value) internal pure returns (bool) {
        return
            value.length >= MIN_PROJECT_NAME_LENGTH &&
            value.length <= MAX_PROJECT_NAME_LENGTH &&
            !_isOnlyWhitespace(value);
    }

    function _isOnlyWhitespace(bytes memory data) internal pure returns (bool) {
        for (uint256 i = 0; i < data.length; i++) {
            // Whitespace is 0x20
            if (data[i] != 0x20) {
                return false;
            }
        }
        return true;
    }
}
