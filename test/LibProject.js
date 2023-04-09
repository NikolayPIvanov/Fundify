const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("LibProject", function () {
    let testLibProject;

    beforeEach(async () => {
        const TestLibProject = await ethers.getContractFactory("TestLibProject");
        testLibProject = await TestLibProject.deploy();
    });

    describe("#createProject", () => {
        it("should create a new projects", async () => {
            for (let index = 0; index < 3; index++) {
                const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
                const deadline = await time.latest() + ONE_YEAR_IN_SECS;

                await testLibProject.createProject(
                    `Test Project: ${index}`,
                    "Test Description",
                    "https://test.com/image.png",
                    100,
                    deadline
                );

                // Get the project
                const project = await testLibProject.projects(index);

                // Check that the project was created correctly
                expect(project.name).to.equal(`Test Project: ${index}`);
                expect(project.description).to.equal("Test Description");
                expect(project.imageLink).to.equal("https://test.com/image.png");
                expect(project.fundingGoal).to.equal(100);
                expect(project.deadline).to.equal(deadline);
            }
        });

        it("should revert if name is not provided", async function () {
            // Call the createProject function without a name
            await expect(
                testLibProject.createProject(
                    "",
                    "Test Description",
                    "https://test.com/image.png",
                    100,
                    10000000000
                )
            ).to.be.revertedWith("Project name is required");
        });

        it("should revert if description is not provided", async function () {
            // Call the createProject function without a description
            await expect(
                testLibProject.createProject(
                    "Test Project",
                    "",
                    "https://test.com/image.png",
                    100,
                    10000000000
                )
            ).to.be.revertedWith("Project description is required");
        });

        it("should revert if image link is not provided", async function () {
            // Call the createProject function without an image link
            await expect(
                testLibProject.createProject(
                    "Test Project",
                    "Test Description",
                    "",
                    100,
                    10000000000
                )
            ).to.be.revertedWith("Image link is required");
        });

        it("should revert if funding goal is not greater than 0", async function () {
            // Call the createProject function with a funding goal of 0
            await expect(
                testLibProject.createProject(
                    "Test Project",
                    "Test Description",
                    "https://test.com/image.png",
                    0,
                    10000000000
                )
            ).to.be.revertedWith("Funding goal must be greater than 0");
        });

        it("should revert if deadline is not greater than 0", async function () {
            // Call the createProject function with a deadline of 0
            await expect(
                testLibProject.createProject(
                    "Test Project",
                    "Test Description",
                    "https://test.com/image.png",
                    100,
                    0
                )
            ).to.be.revertedWith("Deadline must be greater than 0");
        });
    });
});
