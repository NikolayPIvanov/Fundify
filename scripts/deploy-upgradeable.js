const { ethers, upgrades } = require("hardhat");

const contract = "Fund";

async function main() {
    // Deploying
    const Fund = await ethers.getContractFactory(contract);
    const instance = await upgrades.deployProxy(Fund);
    const contractInstance = await instance.deployed();

    console.log(
        `Deployed on address ${contractInstance.address} with proxy ${instance.address}`
    );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
