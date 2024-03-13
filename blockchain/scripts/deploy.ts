import { ethers } from "hardhat";

async function main() {
  const implementation = await ethers.deployContract("JoKenPo");
  await implementation.waitForDeployment();
  const implementationAddress = await implementation.getAddress();
  console.log("Implementation contract deployed to:", implementationAddress);
  
  const adapter = await ethers.deployContract("JKPAdapter");
  await adapter.waitForDeployment();
  const adapterAddress = await adapter.getAddress();
  console.log("Adapter contract deployed to:", adapterAddress);

  await adapter.upgrade(implementationAddress);
  console.log("Adapter was upgraded");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
