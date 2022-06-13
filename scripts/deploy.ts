// We require the Hardhat Runtime Environment explicitly here.
import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy
  const PeerGovernor = await ethers.getContractFactory("PeerGovernor");
  const governor = await PeerGovernor.deploy();

  await governor.deployed();

  console.log("PeerGovernor deployed to:", governor.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
