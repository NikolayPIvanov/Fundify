// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IProject} from "./interfaces/IProject.sol";
import {Project} from "./structs/Project.sol";

/// @custom:security-contact nick.ivanov98@gmail.com
contract Project is IProject {
    mapping(address => Project[]) public projects;

    /// @notice Creates a project with the given name and description.
    /// @param project - The project to create.
    function create(Project calldata project) external override {
        projects[msg.sender].push(project);
    }
}
