import { ethers } from "hardhat";

describe("JoKenPoTests", function () {
  async function loadFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const ProtoCoin = await ethers.getContractFactory("JoKenPo");
    const protoCoin = await ProtoCoin.deploy();

    return { protoCoin, owner, otherAccount };
  }
});
