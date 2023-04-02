// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {ICrowdFund} from "./interfaces/ICrowdFund.sol";
import {ProjectStructure} from "./structs/Project.sol";
import {LibProject} from "./libraries/LibProject.sol";

/// @custom:security-contact nick.ivanov98@gmail.com
contract CrowdFund is ICrowdFund, Initializable, OwnableUpgradeable {
    // Mapping used to show all the projects
    ProjectStructure[] public projects;

    // Mappings to show the ownership of the projects to a given address
    // This can be used to get the projects for a given address
    mapping(address => uint256[]) public addressProjects;

    // Mapping to show the contributions of each address to each project and the amount of contributions
    mapping(address => mapping(uint256 => uint256)) public contributions;

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
    function getProjects() external view returns (ProjectStructure[] memory) {
        return projects;
    }

    /// @param _owner The address of the owner.
    /// @return result The projects of the given address.
    /// @dev The address cannot be the zero address.
    /// 66540c33  =>  getAddressProjects(address)
    function getAddressProjects(
        address _owner
    ) external view returns (ProjectStructure[] memory) {
        require(_owner != address(0), "CrowdFund: Address cannot be zero");

        uint256[] memory projectIds = addressProjects[_owner];
        uint256 counter = 0;
        ProjectStructure[] memory result = new ProjectStructure[](
            projectIds.length
        );

        // Traverse the project ids. Project Ids are the index in the projects array.
        for (uint256 i = 0; i < projectIds.length; i++) {
            ProjectStructure memory project = projects[projectIds[i]];
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
        ProjectStructure memory project = LibProject.createProject(
            name,
            description,
            goal,
            deadline
        );
        projects.push(project);
        addressProjects[msg.sender].push(projects.length);
        emit ProjectCreated(msg.sender, projects.length);
    }

    /// @param _projectId The id of the project.
    /// @dev The project id must exist.
    /// @dev The project deadline must not have passed.
    /// @dev The contribution amount must be greater than zero.
    /// @dev The contribution amount must not exceed the project goal.
    /// c1cbbca7  =>  contribute(uint256) (external)
    function contribute(uint256 _projectId) external payable {
        require(
            _projectId < projects.length,
            "CrowdFund: Project does not exist"
        );
        require(
            projects[_projectId].deadline > block.timestamp,
            "CrowdFund: Project deadline has passed"
        );
        require(
            msg.value > 0,
            "CrowdFund: Contribution amount must be greater than zero"
        );
        require(
            projects[_projectId].totalContributions +=
                msg.value <= projects[_projectId].goal,
            "CrowdFund: Contribution amount must not exceed project goal"
        );

        contributions[msg.sender][_projectId] += msg.value;
        projects[_projectId].totalContributions += msg.value;
    }

    /// @param _projectId The id of the project..
    /// @param _amount The amount to withdraw.
    /// @dev The project id must exist.
    /// 199340c7  =>  withdrawContribution(uint256,uint256) (external)
    function withdrawContribution(
        uint256 _projectId,
        uint256 _amount
    ) external {
        require(
            _projectId < projects.length,
            "CrowdFund: Project does not exist"
        );
        require(
            projects[_projectId].deadline > block.timestamp,
            "CrowdFund: Project deadline has passed"
        );
        require(
            contributions[msg.sender][_projectId] >= _amount,
            "CrowdFund: Invalid contribution withdraw amount"
        );

        contributions[msg.sender][_projectId] -= _amount;
        projects[_projectId].totalContributions -= _amount;

        // TODO: maybe use call approach with abi
        payable(msg.sender).transfer(_amount);

        // Delete the mapping if the contribution amount is zero
        if (contributions[msg.sender][_projectId] == 0) {
            delete contributions[msg.sender][_projectId];
        }
    }
}
