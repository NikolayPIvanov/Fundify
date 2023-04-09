// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibProject} from "../../contracts/libraries/LibProject.sol";
import {Project} from "../../contracts/structs/Project.sol";

contract TestLibProject {
    Project[] public projects;

    function getProject(
        uint256 index
    )
        public
        view
        returns (
            string memory _name,
            string memory _description,
            string memory _imageLink,
            uint256 _fundingGoal,
            uint256 _fundsRaised,
            uint256 _deadline,
            bool _completed,
            address _creator
        )
    {
        _name = projects[index].name;
        _description = projects[index].description;
        _imageLink = projects[index].imageLink;
        _fundingGoal = projects[index].fundingGoal;
        _fundsRaised = projects[index].fundsRaised;
        _deadline = projects[index].deadline;
        _completed = projects[index].completed;
        _creator = projects[index].creator;
    }

    function createProject(
        string memory _name,
        string memory _description,
        string memory _imageLink,
        uint256 _fundingGoal,
        uint256 _deadline
    ) public {
        LibProject._createProject(
            projects,
            _name,
            _description,
            _imageLink,
            _fundingGoal,
            _deadline
        );
    }
}
