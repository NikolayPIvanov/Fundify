// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ProjectFactory} from "./ProjectFactory.sol";
import {Project} from "./structs/Project.sol";
import {ContributionEvents} from "./events/ContributionEvents.sol";
import {ProjectEvents} from "./events/ProjectEvents.sol";

import {LibContributions} from "./libraries/LibContributions.sol";

contract Contribution is ProjectFactory {
    mapping(address => uint256[]) public userContributions;

    function initialize() public virtual override onlyInitializing {
        ProjectFactory.initialize();
    }

    function getUserContributions() external view returns (uint256[] memory) {
        return userContributions[msg.sender];
    }

    /**
     * @dev Contributes the given amount of Ether to the project with the given ID.
     *
     * Requirements:
     * - `_projectId` must correspond to an existing project.
     * - `msg.value` must be greater than 0.
     * - The project's deadline must not have passed.
     *
     * Effects:
     * - Increases the contribution of the sender to the specified project.
     * - Increases the amount of funds raised for the specified project.
     * - Emits a `FundsContributed` event.
     * - If the project's funding goal is reached, emits a `FundingGoalReached` event.
     *
     * @param _projectId The ID of the project to contribute to.
     */
    function contribute(uint256 _projectId) external payable {
        require(
            _projectId < projects.length,
            "CrowdFund: Project does not exist"
        );
        require(msg.value > 0, "Contribution must be greater than 0");

        Project storage _project = projects[_projectId];
        require(
            block.timestamp <= _project.deadline,
            "Project deadline has passed"
        );

        _project.contributions[msg.sender] += msg.value;
        _project.fundsRaised += msg.value;
        userContributions[msg.sender].push(_projectId); // add project ID to user's contributions

        emit ContributionEvents.FundsContributed(
            _projectId,
            msg.sender,
            msg.value
        );

        if (_project.fundsRaised >= _project.fundingGoal) {
            emit ProjectEvents.FundingGoalReached(
                _projectId,
                _project.fundsRaised
            );
        }
    }

    /**
        @dev Allows the creator of a project to withdraw the funds if the project has met its funding goal, 
             or allows contributors to withdraw their contributions if the deadline has passed and the funding goal was not met.
        @param _projectId The ID of the project to withdraw funds from.
            Requirements:
            The project deadline must have passed if creator is withdrawing.
            If the project has met its funding goal, only the project creator can withdraw funds and must not have already done so.
            If the project has not met its funding goal, the contributor must have made a contribution and must have funds to withdraw.
            The project must not have already been completed.
            Emits a {ProjectFundsWithdrawn} event.
    */
    function withdrawFunds(uint256 _projectId) internal {
        Project storage _project = projects[_projectId];
        require(
            _project.deadline < block.timestamp,
            "Project deadline has not passed yet"
        );
        if (_project.fundsRaised >= _project.fundingGoal) {
            // Withdraw only if the project succeeded to raise the goal and the deadline has passed.
            // Withdraw only if you are the creator.
            require(
                msg.sender == _project.creator,
                "Only project creator can withdraw funds"
            );
            require(!_project.completed, "Funds have already been withdrawn");
            _project.creator.transfer(_project.fundsRaised);
            _project.completed = true;

            emit ProjectEvents.ProjectCompleted(
                _projectId,
                _project.fundsRaised
            );
        } else {
            // Withdraw only if the project failed to raise the goal and the deadline has passed.
            require(
                _project.fundsRaised < _project.fundingGoal,
                "Funding goals were met"
            );
            uint256 amount = _project.contributions[msg.sender];
            require(amount > 0, "No funds to withdraw");
            _project.contributions[msg.sender] = 0;

            // Remove project ID from userContributions mapping
            uint256[] storage userProjects = userContributions[msg.sender];
            for (uint i = 0; i < userProjects.length; i++) {
                if (userProjects[i] == _projectId) {
                    userProjects[i] = userProjects[userProjects.length - 1];
                    userProjects.pop();
                    break;
                }
            }

            payable(msg.sender).transfer(amount);

            emit ContributionEvents.ContributionWithdrawn(
                _projectId,
                msg.sender,
                amount
            );
        }
    }
}
