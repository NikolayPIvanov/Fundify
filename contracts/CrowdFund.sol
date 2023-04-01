// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {ICrowdFund} from "./interfaces/ICrowdFund.sol";
import {ProjectStructure} from "./structs/Project.sol";
import {Events} from "./events/ProjectEvents.sol";

/// @custom:security-contact nick.ivanov98@gmail.com
contract CrowdFund is ICrowdFund, Initializable, OwnableUpgradeable {
    mapping(address => ProjectStructure[]) public projects;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    /// @notice Creates a project with the given name and description.
    /// @param name The name of the project.
    /// @param description The description of the project.
    /// @dev The project name and description cannot be empty.
    /// @dev The project name and description cannot be longer than 32 bytes.
    /// @dev The project name and description cannot be shorter than 1 byte.
    /// @dev The project name and description cannot contain only whitespace.
    /// 531f9ac8  =>  createProject(bytes,bytes)
    function createProject(
        bytes calldata name,
        bytes calldata description
    )
        external
        payable
        override
        onlyValidProjectName(name)
        onlyValidProjectDescription(description)
    {
        ProjectStructure memory project = ProjectStructure(name, description);
        ProjectStructure[] storage userProjects = projects[msg.sender];
        userProjects.push(project);
        emit Events.ProjectCreated(msg.sender, userProjects.length);
    }

    function _isOnlyWhitespace(bytes memory data) internal pure returns (bool) {
        for (uint256 i = 0; i < data.length; i++) {
            // Whitespace is 0x20
            if (data[i] != 0x20) {
                return false;
            }
        }
        return true;
    }

    modifier onlyValidProjectName(bytes memory name) {
        require(
            name.length > 0 && name.length <= 32 && !_isOnlyWhitespace(name),
            "Invalid project name."
        );
        _;
    }

    modifier onlyValidProjectDescription(bytes memory description) {
        require(
            description.length > 0 &&
                description.length <= 32 &&
                !_isOnlyWhitespace(description),
            "Invalid project description."
        );
        _;
    }
}
