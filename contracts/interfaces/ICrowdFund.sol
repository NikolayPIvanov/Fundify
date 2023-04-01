// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ProjectStructure} from "../structs/Project.sol";

interface ICrowdFund {
    function createProject(
        bytes calldata name,
        bytes calldata description
    ) external payable;
}
