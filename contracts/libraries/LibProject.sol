// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Project} from "../structs/Project.sol";
import {ProjectEvents} from "../events/ProjectEvents.sol";
import "hardhat/console.sol";

library LibProject {
    function _createProject(
        Project[] storage projects,
        string memory _name,
        string memory _description,
        string memory _imageLink,
        uint256 _fundingGoal,
        uint256 _deadline
    ) internal {
        require(bytes(_name).length > 0, "Project name is required");
        require(
            bytes(_description).length > 0,
            "Project description is required"
        );
        require(bytes(_imageLink).length > 0, "Image link is required");
        require(_fundingGoal > 0, "Funding goal must be greater than 0");
        require(_deadline > 0, "Deadline must be greater than 0");

        // Create the project.
        Project storage project = projects.push();
        project.name = _name;
        project.description = _description;
        project.imageLink = _imageLink;
        project.fundingGoal = _fundingGoal;
        project.fundsRaised = 0;
        project.completed = false;
        project.deadline = block.timestamp + _deadline;
        project.creator = payable(msg.sender);
    }
}
