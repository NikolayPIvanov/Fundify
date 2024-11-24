// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProjectManager} from "../src/ProjectManager.sol";

contract ProjectManagerTest is Test {
    ProjectManager public projectManager;

    function setUp() public {
        projectManager = new ProjectManager();
    }
}
