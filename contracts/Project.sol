// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IProject} from "./interfaces/IProject.sol";
import {ProjectStructure} from "./structs/Project.sol";
import {Events} from "./events/ProjectEvents.sol";

/// @custom:security-contact nick.ivanov98@gmail.com
contract Project is IProject {
    mapping(address => ProjectStructure[]) public projects;

    /// @notice Creates a project with the given name and description.
    /// @param name The name of the project.
    /// @param description The description of the project.
    /// @dev The project name and description cannot be empty.
    /// @dev The project name and description cannot be longer than 32 bytes.
    /// @dev The project name and description cannot be shorter than 1 byte.
    /// @dev The project name and description cannot contain only whitespace.
    /// 531f9ac8  =>  createProject(bytes,bytes)
    function createProject(
        bytes calldata name,
        bytes calldata description
    )
        external
        payable
        override
        onlyValidProjectName(name)
        onlyValidProjectDescription(description)
    {
        _createProject(name, description);
    }

    /// @notice Creates a project with the given name and description.
    /// @param name The name of the project.
    /// @param description The description of the project.
    /// @dev The project name and description cannot be empty.
    /// @dev The project name and description cannot be longer than 32 bytes.
    /// @dev The project name and description cannot be shorter than 1 byte.
    /// @dev The project name and description cannot contain only whitespace.
    function _createProject(
        bytes memory name,
        bytes memory description
    ) internal {
        ProjectStructure memory project = ProjectStructure({
            name: string(name),
            description: string(description)
        });

        projects[msg.sender].push(project);

        emit Events.ProjectCreated(
            msg.sender,
            projects[msg.sender].length,
            project
        );
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

    modifier onlyValidProjectName(bytes memory name) {
        require(name.length > 0, "Project name cannot be empty.");
        require(
            name.length <= 32,
            "Project name cannot be longer than 32 bytes."
        );
        require(
            !_isOnlyWhitespace(name),
            "Project name cannot contain only whitespace."
        );
        _;
    }

    modifier onlyValidProjectDescription(bytes memory description) {
        require(description.length > 0, "Project description cannot be empty.");
        require(
            description.length <= 32,
            "Project description cannot be longer than 32 bytes."
        );
        require(
            !_isOnlyWhitespace(description),
            "Project description cannot contain only whitespace."
        );
        _;
    }
}
