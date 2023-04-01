// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ProjectStructure} from "../structs/Project.sol";

library Events {
    event ProjectCreated(
        address indexed owner,
        uint256 indexed projectId,
        ProjectStructure project
    );
}
