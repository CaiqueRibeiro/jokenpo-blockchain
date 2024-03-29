// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./IJoKenPo.sol";
import "./JKPLibrary.sol";

contract JoKenPo is IJoKenPo {
    JKPLibrary.Options public choice1 = JKPLibrary.Options.NONE;
    address private player1;
    string private result = "";
    uint256 private bid = 0.01 ether;
    uint8 private comission = 10; // percent

    address payable private immutable owner;

    JKPLibrary.Player[] public players;

    constructor() {
        owner = payable(msg.sender);
    }

    function getResult() external view returns (string memory) {
        return result;
    }

    // use external instead of public to save gas
    function getBid() external view returns (uint256) {
        return bid;
    }

    function getComission() external view returns (uint8) {
        return comission;
    }

    function setBid(uint256 newBid) external {
        require(owner == tx.origin, "You do not have permission to this");
        require(
            player1 == address(0),
            "You cannot change the bid with a game in progress"
        );
        bid = newBid;
    }

    function setComission(uint8 newComission) external {
        require(owner == tx.origin, "You do not have permission to this");
        require(
            player1 == address(0),
            "You cannot change the comission with a game in progress"
        );
        comission = newComission;
    }

    function updateWinner(address winner) private {
        for (uint i = 0; i < players.length; i++) {
            if (players[i].wallet == winner) {
                players[i].wins++;
                return;
            }
        }

        players.push(JKPLibrary.Player(winner, 1));
    }

    function finishGame(string memory newResult, address winner) private {
        address contractAddress = address(this);
        payable(winner).transfer(
            (contractAddress.balance / 100) * (100 - comission)
        );
        owner.transfer(contractAddress.balance);

        updateWinner(winner);

        result = newResult;
        player1 = address(0); // reset the game
        choice1 = JKPLibrary.Options.NONE;
    }

    function getBalance() external view returns (uint) {
        require(owner == tx.origin, "You do not have permission to this");
        return address(this).balance;
    }

    function play(JKPLibrary.Options newChoice) external payable {
        require(tx.origin != owner, "Owner cannot play");
        require(newChoice != JKPLibrary.Options.NONE, "Invalid choice");
        require(player1 != tx.origin, "Wait the another player");
        require(msg.value >= bid, "Invalid bids");

        if (choice1 == JKPLibrary.Options.NONE) {
            player1 = tx.origin;
            choice1 = newChoice;
            result = "Player 1 chose his/her option. Waiting for player 2";
        } else if (
            choice1 == JKPLibrary.Options.ROCK &&
            newChoice == JKPLibrary.Options.SCISSORS
        ) {
            finishGame("Rock breaks scissors. Player 1 wins", player1);
        } else if (
            choice1 == JKPLibrary.Options.PAPER &&
            newChoice == JKPLibrary.Options.ROCK
        ) {
            finishGame("Paper covers rock. Player 1 wins", player1);
        } else if (
            choice1 == JKPLibrary.Options.SCISSORS &&
            newChoice == JKPLibrary.Options.PAPER
        ) {
            finishGame("Scissors cut paper. Player 1 wins", player1);
        } else if (
            choice1 == JKPLibrary.Options.SCISSORS &&
            newChoice == JKPLibrary.Options.ROCK
        ) {
            finishGame("Rock breaks scissors. Player 2 wins", tx.origin);
        } else if (
            choice1 == JKPLibrary.Options.ROCK &&
            newChoice == JKPLibrary.Options.PAPER
        ) {
            finishGame("Paper wraps rock. Player 2 wins", tx.origin);
        } else if (
            choice1 == JKPLibrary.Options.PAPER &&
            newChoice == JKPLibrary.Options.SCISSORS
        ) {
            finishGame("Scissors cut paper. Player 2 wins", tx.origin);
        } else {
            result = "Draw game. The prize was doubled.";
            player1 = address(0);
            choice1 = JKPLibrary.Options.NONE;
        }
    }

    function getLeaderboard()
        external
        view
        returns (JKPLibrary.Player[] memory)
    {
        if (players.length < 2) return players;

        JKPLibrary.Player[] memory arr = new JKPLibrary.Player[](
            players.length
        );
        for (uint i = 0; i < players.length; i++) {
            arr[i] = players[i];
        }

        for (uint i = 0; i < arr.length - 1; i++) {
            for (uint j = i + 1; j < arr.length; j++) {
                if (arr[i].wins < arr[j].wins) {
                    JKPLibrary.Player memory temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }

        return arr;
    }
}
