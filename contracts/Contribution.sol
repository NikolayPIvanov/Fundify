// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ProjectFactory} from "./ProjectFactory.sol";

import {Project, ProjectContribution} from "./structs/Project.sol";

contract Contribution is ProjectFactory {
    mapping(address => ProjectContribution[]) public contributions;
    mapping(uint256 => address[]) public contributors;

    function initialize() public virtual override onlyInitializing {
        ProjectFactory.initialize();
    }

    // MODFIERS
    modifier onlyProjectOwner(uint256 _projectId) {
        require(
            projectInstances[_projectId].owner == msg.sender,
            "CrowdFund: Only project owner can call this function"
        );
        _;
    }

    // FUNCTIONS
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

        ProjectContribution storage contribution = getContribution(_projectId);
        contribution.amount += msg.value;
        projectInstances[_projectId].totalContributions += msg.value;
    }

    function getContribution(
        uint256 _projectId
    ) internal returns (ProjectContribution storage contribution) {
        return _getContribution(_projectId, msg.sender);
    }

    function _getContribution(
        uint256 _projectId,
        address _contributor
    ) private returns (ProjectContribution storage contribution) {
        ProjectContribution[] storage contributedProjects = contributions[
            _contributor
        ];

        int256 index = -1;
        for (uint256 i = 0; i < contributedProjects.length; i++) {
            if (contributedProjects[i].projectId == _projectId) {
                index = int256(i);
                break;
            }
        }

        if (index == 0) {
            contributedProjects.push(
                ProjectContribution(_projectId, msg.value)
            );
            contributors[_projectId].push(msg.sender);

            return contributedProjects[contributedProjects.length - 1];
        }

        return contributedProjects[uint256(index)];
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

        ProjectContribution storage contribution = getContribution(_projectId);

        require(
            contribution.amount >= _amount,
            "CrowdFund: Invalid contribution withdraw amount"
        );

        contribution.amount -= _amount;
        projectInstances[_projectId].totalContributions -= _amount;

        // Delete the mapping if the contribution amount is zero
        if (contribution.amount == 0) {
            address[] storage addresses = contributors[_projectId];

            uint256 index;
            for (uint256 i = 0; i < addresses.length; i++) {
                if (addresses[i] == msg.sender) {
                    index = i;
                    break;
                }
            }

            addresses[index] = addresses[addresses.length - 1];
            addresses.pop();
        }

        // TODO: maybe use call approach with abi
        payable(msg.sender).transfer(_amount);
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
            "CrowdFund: Project goal has been reached"
        );

        payable(msg.sender).transfer(project.totalContributions);
    }

    function returnContributions(uint256 _projectId) external {
        Project storage project = projectInstances[_projectId];

        // Only can return the contributions if the deadline has passed and goal has not been reached
        require(
            project.deadline >= block.timestamp,
            "CrowdFund: Project deadline has not passed"
        );

        require(
            project.totalContributions < project.goal,
            "CrowdFund: Project goal has not been reached"
        );

        address[] memory projectContributors = contributors[_projectId];
        for (uint i = 0; i < projectContributors.length; i++) {
            ProjectContribution storage contribution = _getContribution(
                _projectId,
                projectContributors[i]
            );

            payable(projectContributors[i]).transfer(contribution.amount);
        }
    }
}
