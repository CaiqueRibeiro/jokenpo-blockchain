import { loadFixture} from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { expect } from "chai";
import { ethers } from "hardhat";

describe("JoKenPoTests", function () {

enum Options {
  NONE,
  ROCK,
  PAPER,
  SCISSORS
}

const DEFAULT_BID = ethers.parseEther("0.01");

  async function deployFixture() {
    const [owner, player1, player2] = await ethers.getSigners();

    const JoKenPo = await ethers.getContractFactory("JoKenPo");
    const jokenpo = await JoKenPo.deploy();

    return { jokenpo, owner, player1, player2 };
  }

  it('should get leader board', async function() {
    const { jokenpo, player1, player2 } = await loadFixture(deployFixture);

    const player1Instance = jokenpo.connect(player1);
    await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

    const player2Instance = jokenpo.connect(player2);
    await player2Instance.play(Options.ROCK, { value: DEFAULT_BID });

    const leaderboard = await jokenpo.getLeaderboard();

    expect(leaderboard.length).to.equal(1);
    expect(leaderboard[0].wallet).to.equal(player1.address);
    expect(leaderboard[0].wins).to.equal(1);
  });

  it('should set bid', async function() {
    const { jokenpo } = await loadFixture(deployFixture);

    const newBid = ethers.parseEther("0.02");

    await jokenpo.setBid(newBid);

    const updatedBid = await jokenpo.getBid();

    expect(updatedBid).to.equal(newBid);
  });

  it('should not be able to set bid (permission)', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const newBid = ethers.parseEther("0.02");

    const instance = jokenpo.connect(player1);

    await expect(instance.setBid(newBid)).to.be.revertedWith("You do not have permission to this");
  });

  it('should not be able to set bid (during the game)', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const newBid = ethers.parseEther("0.02");

    const player1Instance = jokenpo.connect(player1);
    await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

    await expect(jokenpo.setBid(newBid)).to.be.revertedWith("You cannot change the bid with a game in progress");
  });


  it('should set comission', async function() {
    const { jokenpo } = await loadFixture(deployFixture);

    const newComission = 11n;

    await jokenpo.setComission(newComission);

    const updatedComission = await jokenpo.getComission();

    expect(updatedComission).to.equal(newComission);
  });

  it('should not be able to set comission (permission)', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const newComission = 11n;

    const instance = jokenpo.connect(player1);

    await expect(instance.setComission(newComission)).to.be.revertedWith("You do not have permission to this");
  });

  it('should not be able to set comission (during the game)', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const newComission = 11n;

    const player1Instance = jokenpo.connect(player1);
    await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

    await expect(jokenpo.setComission(newComission)).to.be.revertedWith("You cannot change the comission with a game in progress");
  });

  it('should play alone', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const player1Instance = jokenpo.connect(player1);
    await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

    const result = await jokenpo.getResult();

    expect(result).to.equal("Player 1 chose his/her option. Waiting for player 2");
  });

  it('should play along', async function() {
    const { jokenpo, player1, player2 } = await loadFixture(deployFixture);

    const player1Instance = jokenpo.connect(player1);
    await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

    const player2Instance = jokenpo.connect(player2);
    await player2Instance.play(Options.ROCK, { value: DEFAULT_BID });

    const result = await jokenpo.getResult();

    expect(result).to.equal("Paper covers rock. Player 1 wins");
  });

  it('should not play with owner', async function() {
    const { jokenpo } = await loadFixture(deployFixture);

    await expect(jokenpo.play(Options.PAPER, { value: DEFAULT_BID }))
      .to.be.revertedWith("Owner cannot play");
  });

  it('should not play with wrong option', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const player1Instance = jokenpo.connect(player1);

    await expect(player1Instance.play(Options.NONE, { value: DEFAULT_BID }))
      .to.be.revertedWith("Invalid choice");
  });

  it('should not play with twice in a row', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const player1Instance = jokenpo.connect(player1);
    await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

    await expect(player1Instance.play(Options.ROCK, { value: DEFAULT_BID }))
      .to.be.revertedWith("Wait the another player");
  });

  it('should not play informing wrong bid', async function() {
    const { jokenpo, player1 } = await loadFixture(deployFixture);

    const player1Instance = jokenpo.connect(player1);

    await expect(player1Instance.play(Options.ROCK, { value: DEFAULT_BID - 1n }))
      .to.be.revertedWith("Invalid bids");
  });
});
