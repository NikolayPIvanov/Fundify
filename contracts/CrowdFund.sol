// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {ICrowdFund} from "./interfaces/ICrowdFund.sol";
import {Project} from "./structs/Project.sol";
import {LibProject} from "./libraries/LibProject.sol";

import {ProjectFactory} from "./ProjectFactory.sol";

/// @custom:security-contact nick.ivanov98@gmail.com
contract CrowdFund is ICrowdFund, ProjectFactory, OwnableUpgradeable {
    // Mappings to show the contributions of a given address to a given project
    mapping(uint256 => mapping(address => uint256)) public contributions;
    // Mappings to show all the contributions of a given address to projects
    mapping(address => uint256[]) public addressContributions;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public override initializer {
        ProjectFactory.initialize();
        __Ownable_init();
    }

    /// @param _projectId The id of the project.
    /// @dev The project id must exist.
    /// @dev The project deadline must not have passed.
    /// @dev The contribution amount must be greater than zero.
    /// @dev The contribution amount must not exceed the project goal.
    /// c1cbbca7  =>  contribute(uint256) (external)
    function contribute(uint256 _projectId) external payable {
        require(
            _projectId < projectInstances.length,
            "CrowdFund: Project does not exist"
        );
        require(
            projectInstances[_projectId].deadline > block.timestamp,
            "CrowdFund: Project deadline has passed"
        );
        require(
            msg.value > 0,
            "CrowdFund: Contribution amount must be greater than zero"
        );

        uint256 totalContributions = projectInstances[_projectId]
            .totalContributions;

        require(
            totalContributions + msg.value <= projectInstances[_projectId].goal,
            "CrowdFund: Contribution amount must not exceed project goal"
        );

        // Add the project id to the addressContributions mapping if the address has not contributed to the project before
        uint256[] storage contributedProjects = addressContributions[
            msg.sender
        ];
        bool isContributor = false;
        for (uint256 i = 0; i < contributedProjects.length; i++) {
            if (contributedProjects[i] == _projectId) {
                isContributor = true;
                break;
            }
        }

        if (!isContributor) {
            contributedProjects.push(_projectId);
        }

        contributions[_projectId][msg.sender] += msg.value;
        projectInstances[_projectId].totalContributions += msg.value;
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
            _projectId < projectInstances.length,
            "CrowdFund: Project does not exist"
        );
        require(
            projectInstances[_projectId].deadline > block.timestamp,
            "CrowdFund: Project deadline has passed"
        );
        require(
            contributions[_projectId][msg.sender] >= _amount,
            "CrowdFund: Invalid contribution withdraw amount"
        );

        contributions[_projectId][msg.sender] -= _amount;
        projectInstances[_projectId].totalContributions -= _amount;

        // Delete the mapping if the contribution amount is zero
        if (contributions[_projectId][msg.sender] == 0) {
            delete contributions[_projectId][msg.sender];
            uint256[] storage projectIds = addressContributions[msg.sender];

            // Delete the address from the contributors array finding its index first, then switch it with the last element and then pop the last element
            uint256 index;
            for (uint256 i = 0; i < projectIds.length; i++) {
                if (projectIds[i] == _projectId) {
                    index = i;
                    break;
                }
            }

            projectIds[index] = projectIds[projectIds.length - 1];
            projectIds.pop();
        }

        // TODO: maybe use call approach with abi
        payable(msg.sender).transfer(_amount);
    }

    modifier onlyProjectOwner(uint256 _projectId) {
        require(
            projectInstances[_projectId].owner == msg.sender,
            "CrowdFund: Only project owner can call this function"
        );
        _;
    }

    function withdraw(
        uint256 _projectId
    ) external onlyProjectOwner(_projectId) {
        // Only can withdraw the amount of the goal
        // Only can withdraw if the deadline has passed and goal has been reached

        Project memory project = projectInstances[_projectId];

        require(
            project.deadline < block.timestamp,
            "CrowdFund: Project deadline has not passed"
        );

        require(
            project.totalContributions >= project.goal,
            "CrowdFund: Project goal has not been reached"
        );

        payable(msg.sender).transfer(project.totalContributions);
    }

    function returnContributions(uint256 _projectId) external view {
        Project memory project = projectInstances[_projectId];

        // Only can return the contributions if the deadline has passed and goal has not been reached
        require(
            project.deadline >= block.timestamp,
            "CrowdFund: Project deadline has not passed"
        );

        require(
            project.totalContributions < project.goal,
            "CrowdFund: Project goal has not been reached"
        );
    }
}
