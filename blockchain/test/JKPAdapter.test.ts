import { loadFixture} from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { expect } from "chai";
import { ethers } from "hardhat";

describe("JoKenPo Tests", function () {

enum Options {
  NONE,
  ROCK,
  PAPER,
  SCISSORS
}

const DEFAULT_BID = ethers.parseEther("0.01");
const DEFAULT_COMISSION = 10n;

  async function deployFixture() {
    const [owner, player1, player2] = await ethers.getSigners();

    const JoKenPo = await ethers.getContractFactory("JoKenPo");
    const jokenpo = await JoKenPo.deploy();

    const JKPAdapter = await ethers.getContractFactory("JKPAdapter");
    const jkpAdapter = await JKPAdapter.deploy();

    return { jokenpo, jkpAdapter, owner, player1, player2 };
  }

  it('should get implementation address', async function() {
    const { jokenpo, jkpAdapter } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(jokenpo);
    const address = await jokenpo.getAddress();
    const implementationAddress = await jkpAdapter.getImplementationAddress();

    expect(implementationAddress).to.equal(address);
  });

  it('should get bid', async function() {
    const { jokenpo, jkpAdapter } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(jokenpo);
    const bid = await jkpAdapter.getBid();

    expect(bid).to.equal(DEFAULT_BID);
  });

  it('should NOT get bid', async function() {
    const { jkpAdapter } = await loadFixture(deployFixture);
    await expect(jkpAdapter.getBid())
        .to
        .be
        .revertedWith("A valid implementation of JoKenPo was not set yet");
  });

  it('should get comission', async function() {
    const { jokenpo, jkpAdapter } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(jokenpo);
    const comission = await jkpAdapter.getComission();

    expect(comission).to.equal(DEFAULT_COMISSION);
  });

  it('should NOT get comission', async function() {
    const { jkpAdapter } = await loadFixture(deployFixture);
    await expect(jkpAdapter.getComission())
        .to
        .be
        .revertedWith("A valid implementation of JoKenPo was not set yet");
  });

  it('should NOT upgrade (permission)', async function() {
    const { jokenpo, jkpAdapter, player1 } = await loadFixture(deployFixture);

    const instance = jkpAdapter.connect(player1);
    await expect(instance.upgrade(jokenpo))
        .to
        .be
        .revertedWith("You do not have permission to this");
  });

  it('should play alone by adapter', async function() {
    const { jokenpo, jkpAdapter, player1 } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(jokenpo);

    const instance = jkpAdapter.connect(player1);
    await instance.play(Options.PAPER, { value: DEFAULT_BID });

    const result = await instance.getResult();

    expect(result).to.equal("Player 1 chose his/her option. Waiting for player 2");
  });

  it('should play along by adapter', async function() {
    const { jokenpo, jkpAdapter, player1, player2 } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(jokenpo);

    const instance = jkpAdapter.connect(player1);
    await instance.play(Options.PAPER, { value: DEFAULT_BID });

    const instance2 = jkpAdapter.connect(player2);
    await instance2.play(Options.ROCK, { value: DEFAULT_BID });

    const result = await instance.getResult();

    expect(result).to.equal("Paper covers rock. Player 1 wins");
  });
});
