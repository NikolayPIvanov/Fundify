const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Project Factory", () => {
    let projectFactory, signer, signers;

    beforeEach(async () => {
        upgrades.silenceWarnings();

        const ProjectFactory = await ethers.getContractFactory("ProjectFactory");
        projectFactory = await ProjectFactory.deploy();

        signers = await ethers.getSigners();
        signer = signers[0];

        projectFactory = projectFactory.connect(signer);

        await projectFactory.deployed();
    });

    describe("Deployment", () => {
        it("should have address", () => {
            expect(projectFactory.address).not.null;
        });
    });

    describe("#createProject", () => {
        it("should create a new project", async () => {
            const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
            const deadline = await time.latest() + ONE_YEAR_IN_SECS;

            const sender = signers[0];

            const contractInstanceWithLibraryABI = await ethers.getContractAt("ProjectEvents", projectFactory.address);

            await expect(projectFactory.createProject(
                "Test Project",
                "Test Description",
                "https://test.com/image.png",
                100,
                deadline
            )).to.emit(contractInstanceWithLibraryABI, "ProjectCreated")
                .withArgs(0, "Test Project", "Test Description", "https://test.com/image.png", 100, deadline, signer.address)

            // Get the project
            const project = await projectFactory.projects(0);

            // Check that the project was created correctly
            expect(project.name).to.equal("Test Project");
            expect(project.description).to.equal("Test Description");
            expect(project.imageLink).to.equal("https://test.com/image.png");
            expect(project.fundingGoal).to.equal(100);
            expect(project.deadline).to.equal(deadline);
        });
    });

})