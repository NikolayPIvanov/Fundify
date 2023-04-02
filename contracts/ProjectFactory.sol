// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Project} from "./structs/Project.sol";
import {LibProject} from "./libraries/LibProject.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "hardhat/console.sol";

contract ProjectFactory is Initializable {
    Project[] public projectInstances;
    uint256 public projectCount;

    // Mappings to show the ownership of the projects to a given address.
    // Will be used to get the projects for a given address
    mapping(address => uint256[]) public ownerToProjects;

    event ProjectCreated(address indexed owner, uint256 indexed projectId);

    function initialize() public virtual onlyInitializing {}

    /// @param _owner The address of the owner.
    /// @return result The projects of the given address.
    /// @dev The address cannot be the zero address.
    function projects(address _owner) external view returns (Project[] memory) {
        require(_owner != address(0), "ProjectFactory: Address cannot be zero");

        uint256 counter = 0;
        uint256[] memory projectIds = ownerToProjects[_owner];
        Project[] memory result = new Project[](projectIds.length);

        // Traverse the project ids.
        // Project Ids are the index in the projects array.
        for (uint256 i = 0; i < projectIds.length; i++) {
            uint256 index = projectIds[i];
            Project memory project = projectInstances[index - 1];
            result[counter] = project;
            counter++;
        }

        return result;
    }

    /// @notice Creates a project with the given name and description.
    /// @param name The name of the project.
    /// @param description The description of the project.
    /// @param goal The goal of the project.
    /// @param deadline The deadline of the project.
    /// @dev The project name and description cannot be empty.
    /// @dev The project name and description cannot be longer than 32 bytes.
    /// @dev The project name and description cannot be shorter than 1 byte.
    /// @dev The project name and description cannot contain only whitespace.
    /// 531f9ac8  =>  createProject(bytes,bytes)
    function createProject(
        bytes calldata name,
        bytes calldata description,
        uint256 goal,
        uint256 deadline
    ) external payable {
        Project memory project = LibProject.createProject(
            name,
            description,
            goal,
            deadline
        );

        projectCount++;
        projectInstances.push(project);
        ownerToProjects[msg.sender].push(projectInstances.length);

        emit ProjectCreated(msg.sender, projectInstances.length);
    }
}
