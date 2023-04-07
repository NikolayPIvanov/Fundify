const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");


describe("CrowdFund", () => {
    let crowdFund;
    let accounts;
    let creator;
    let contributor;

    const createProject = async (creator) => {
        await crowdFund.connect(creator).createProject(
            'Project A',
            'Description for Project A',
            'https://example.com/project-a',
            ethers.utils.formatUnits('10', 'ether'),
            Math.floor(Date.now() / 1000) + 86400 // deadline in 24 hours
        );
    }

    const contribute = async (contributor, projectId = 0) => {
        await crowdFund.contribute(projectId, { from: contributor, value: ethers.utils.formatUnits('1', 'ether') });
    }

    beforeEach(async () => {
        upgrades.silenceWarnings();

        const CrowdFund = await ethers.getContractFactory("CrowdFund");
        crowdFund = await upgrades.deployProxy(CrowdFund);

        accounts = await ethers.getSigners();
        creator = accounts[0];
        contributor = accounts[1];

        createProject(creator);
        contribute(contributor);
    });

    describe("Deployment", () => {
        it('works before and after upgrading', () => {
            expect(crowdFund.address).not.null;
        });
    });

    describe("Project", () => {
        describe("#createProject", () => {
        })
    })
});