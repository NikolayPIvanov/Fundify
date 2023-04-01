const { ethers, upgrades, assert } = require("hardhat");
const {
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

describe("CrowdFund", () => {
    const getContractFactory = async (contractName = "CrowdFund") => {
        const CrowdFund = await ethers.getContractFactory("CrowdFund");
        return CrowdFund;
    };

    const deployContract = async () => {
        const CrowdFund = await getContractFactory("CrowdFund");
        const crowdFund = await CrowdFund.deploy();

        return { crowdFund };
    }

    describe("Deployment", () => {
        it('works before and after upgrading', async function () {
            const CrowdFund = await getContractFactory()

            const instance = await upgrades.deployProxy(CrowdFund);
        });
    });
})