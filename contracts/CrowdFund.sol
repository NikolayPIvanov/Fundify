// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {ICrowdFund} from "./interfaces/ICrowdFund.sol";
import {Contribution} from "./Contribution.sol";

/// @custom:security-contact nick.ivanov98@gmail.com
contract CrowdFund is ICrowdFund, Contribution, OwnableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public override initializer {
        Contribution.initialize();
        __Ownable_init();
    }
}
