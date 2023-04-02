// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {ICrowdFund} from "./interfaces/ICrowdFund.sol";
import {ProjectStructure} from "./structs/Project.sol";
import {LibProject} from "./libraries/LibProject.sol";

/// @custom:security-contact nick.ivanov98@gmail.com
contract CrowdFund is ICrowdFund, Initializable, OwnableUpgradeable {
    ProjectStructure[] public projects;

    mapping(address => ProjectStructure[]) public addressProjects;

    event ProjectCreated(address indexed owner, uint256 indexed projectId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    /// @notice Returns all projects.
    /// dcc60128  =>  getProjects()
    function getProjects() public view returns (ProjectStructure[] memory) {
        return projects;
    }

    function getAddressProjects(
        address _owner
    ) public view returns (ProjectStructure[] memory) {
        require(_owner != address(0), "CrowdFund: Address cannot be zero");
        return addressProjects[_owner];
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
        ProjectStructure memory project = LibProject.createProject(
            name,
            description,
            goal,
            deadline
        );
        projects.push(project);
        addressProjects[msg.sender].push(project);
        emit ProjectCreated(msg.sender, projects.length);
    }
}
