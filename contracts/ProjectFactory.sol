// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Project} from "./structs/Project.sol";
import {LibProject} from "./libraries/LibProject.sol";
import {ProjectEvents} from "./events/ProjectEvents.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ProjectFactory is Initializable {
    Project[] public projects;

    function initialize() public virtual onlyInitializing {}

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

        // Project id is the length of the projects array minus 1.
        emit ProjectEvents.ProjectCreated(
            projects.length - 1,
            _name,
            _description,
            _imageLink,
            _fundingGoal,
            _deadline,
            msg.sender
        );
    }
}
