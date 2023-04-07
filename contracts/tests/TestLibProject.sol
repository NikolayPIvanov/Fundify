// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibProject} from "../../contracts/libraries/LibProject.sol";
import {Project} from "../../contracts/structs/Project.sol";

contract TestLibProject {
    Project[] public projects;

    function getProject(
        uint256 index
    ) public view returns (string memory _name, string memory _description) {
        _name = projects[index].name;
        _description = projects[index].description;
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
