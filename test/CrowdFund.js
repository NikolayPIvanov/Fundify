const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

describe("CrowdFund", () => {
    const toBytes = (value) => {
        const bytes = ethers.utils.toUtf8Bytes(value);
        const hex = ethers.utils.hexlify(bytes);

        return hex;
    }

    const toString = (value) => {
        const bytes = ethers.utils.hexlify(value);
        const string = ethers.utils.toUtf8String(bytes);

        return string;
    }

    const deployContract = async () => {
        const CrowdFund = await ethers.getContractFactory("CrowdFund");
        const crowdFund = await upgrades.deployProxy(CrowdFund);

        const accounts = await ethers.getSigners();

        return { crowdFund, accounts };
    }

    describe("Deployment", () => {
        it('works before and after upgrading', async function () {
            const { crowdFund } = await loadFixture(deployContract);

            expect(crowdFund.address).not.null;
        });
    });

    describe("Project", () => {
        describe("#createProject", () => {
            describe("Success", () => {
                it("should create a project and emit ProjectCreated and add to array", async () => {
                    const { crowdFund, accounts } = await loadFixture(deployContract);
                    const sender = accounts[0];
                    const name = "Test Project";
                    const description = "Test Description";

                    const projects = await crowdFund.getProjects();
                    const expected = projects.length + 1;

                    await expect(
                        crowdFund
                            .connect(sender)
                            .createProject(toBytes(name), toBytes(description)))
                        .to.emit(crowdFund, "ProjectCreated")
                        .withArgs(sender.address, expected);

                    const updatedProjects = await crowdFund.getProjects();
                    expect(updatedProjects.length).to.equal(expected);

                    expect(toString(updatedProjects[expected - 1].name)).to.equal(name);
                    expect(toString(updatedProjects[expected - 1].description)).to.equal(description);
                });
            })

            describe("Failure", () => {
                [{ name: "" }, { name: "    " }, { name: "longggggggggggggggggggggggggggggg" }].forEach(({ name }) => {
                    it(`should fail with Invalid project name when name is invalid: ${name}`, async () => {
                        const { crowdFund, accounts } = await loadFixture(deployContract);
                        const sender = accounts[0];
                        const description = "Test Description";

                        const projects = await crowdFund.getProjects();
                        const expected = projects.length;

                        await expect(
                            crowdFund
                                .connect(sender)
                                .createProject(toBytes(name), toBytes(description)))
                            .to.revertedWith("Invalid project name.")

                        const updatedProjects = await crowdFund.getProjects();
                        expect(updatedProjects.length).to.equal(expected);
                    });
                });

                [{ description: "" }, { description: "    " }, { description: "longggggggggggggggggggggggggggggg" }].forEach(({ description }) => {
                    it(`should fail with Invalid project name when description is invalid: ${description}`, async () => {
                        const { crowdFund, accounts } = await loadFixture(deployContract);
                        const sender = accounts[0];
                        const name = "Test Name";

                        const projects = await crowdFund.getProjects();
                        const expected = projects.length;

                        await expect(
                            crowdFund
                                .connect(sender)
                                .createProject(toBytes(name), toBytes(description)))
                            .to.revertedWith("Invalid project description.")

                        const updatedProjects = await crowdFund.getProjects();
                        expect(updatedProjects.length).to.equal(expected);
                    });
                });
            })
        });
    })
})