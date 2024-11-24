// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProjectManager} from "../src/ProjectManager.sol";

contract ProjectManagerScript is Script {
    ProjectManager public projectManager;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        projectManager = new ProjectManager();

        vm.stopBroadcast();
    }
}
