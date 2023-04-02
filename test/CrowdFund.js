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
                    const goal = 1000;
                    const deadline = (await time.latest()) + 1000;

                    const projectCount = await crowdFund.projectCount();
                    const expected = projectCount + 1;

                    await expect(
                        crowdFund
                            .connect(sender)
                            .createProject(toBytes(name), toBytes(description), goal, deadline))
                        .to.emit(crowdFund, "ProjectCreated")
                        .withArgs(sender.address, expected);

                    const updatedProjectCount = await crowdFund.projectCount();
                    expect(updatedProjectCount).to.equal(expected);

                    const projects = await crowdFund.projects(sender.address);
                    const project = projects[expected - 1];
                    expect(toString(project.name)).to.equal(name);
                    expect(toString(project.description)).to.equal(description);
                    expect(project.owner).to.equal(sender.address);
                    expect(project.goal).to.equal(goal);
                    expect(project.deadline).to.equal(deadline);
                });
            })

            describe("Failure", () => {
                [{ name: "" }, { name: "    " }, { name: "longggggggggggggggggggggggggggggg" }].forEach(({ name }) => {
                    it(`should fail with Invalid project name when name is invalid: ${name}`, async () => {
                        const { crowdFund, accounts } = await loadFixture(deployContract);
                        const sender = accounts[0];
                        const description = "Test Description";
                        const goal = 1000;
                        const deadline = (await time.latest()) + 1000;

                        const projects = await crowdFund.projects(sender.address);
                        const expected = projects.length;

                        await expect(
                            crowdFund
                                .connect(sender)
                                .createProject(toBytes(name), toBytes(description), goal, deadline))
                            .to.revertedWith("Invalid project name.")

                        const updatedProjects = await crowdFund.projects(sender.address);
                        expect(updatedProjects.length).to.equal(expected);
                    });
                });

                [{ description: "" }, { description: "    " }, { description: "longggggggggggggggggggggggggggggg" }].forEach(({ description }) => {
                    it(`should fail with Invalid project name when description is invalid: ${description}`, async () => {
                        const { crowdFund, accounts } = await loadFixture(deployContract);
                        const sender = accounts[0];
                        const name = "Test Name";
                        const goal = 1000;
                        const deadline = (await time.latest()) + 1000;

                        const projects = await crowdFund.projects(sender.address);
                        const expected = projects.length;

                        await expect(
                            crowdFund
                                .connect(sender)
                                .createProject(toBytes(name), toBytes(description), goal, deadline))
                            .to.revertedWith("Invalid project description.")

                        const updatedProjects = await crowdFund.projects(sender.address);
                        expect(updatedProjects.length).to.equal(expected);
                    });
                });
            })
        });
    })
})