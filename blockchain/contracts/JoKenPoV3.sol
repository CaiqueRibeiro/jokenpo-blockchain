// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract JoKenPo {
    enum Options {
        NONE,
        ROCK,
        PAPER,
        SCISSORS
    }

    Options public choice1 = Options.NONE;
    address private player1;
    string private result = "";
    uint256 private bid = 0.01 ether;
    uint8 private comission = 10; // percent

    address payable private immutable owner;

    struct Player {
        address wallet;
        uint32 wins;
    }

    Player[] public players;

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
        require(owner == msg.sender, "You do not have permission to this");
        require(
            player1 == address(0),
            "You cannot change the bid with a game in progress"
        );
        bid = newBid;
    }

    function setComission(uint8 newComission) external {
        require(owner == msg.sender, "You do not have permission to this");
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

        players.push(Player(winner, 1));
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
        choice1 = Options.NONE;
    }

    function getBalance() public view returns (uint) {
        require(owner == msg.sender, "You do not have permission to this");
        return address(this).balance;
    }

    function play(Options newChoice) external payable {
        require(msg.sender != owner, "Owner cannot play");
        require(newChoice != Options.NONE, "Invalid choice");
        require(player1 != msg.sender, "Wait the another plauyer");
        require(msg.value >= bid, "Invalid bids");

        if (choice1 == Options.NONE) {
            player1 = msg.sender;
            choice1 = newChoice;
            result = "Player 1 chosse his/her option. Waiting for player 2";
        } else if (choice1 == Options.ROCK && newChoice == Options.SCISSORS) {
            finishGame("Rock breaks scissors. Player 1 wins", player1);
        } else if (choice1 == Options.PAPER && newChoice == Options.ROCK) {
            finishGame("Paper covers rock. Player 1 wins", player1);
        } else if (choice1 == Options.SCISSORS && newChoice == Options.PAPER) {
            finishGame("Scissors cut paper. Player 1 wins", player1);
        } else if (choice1 == Options.SCISSORS && newChoice == Options.ROCK) {
            finishGame("Rock breaks scissors. Player 2 wins", msg.sender);
        } else if (choice1 == Options.ROCK && newChoice == Options.PAPER) {
            finishGame("Paper wraps rock. Player 2 wins", msg.sender);
        } else if (choice1 == Options.PAPER && newChoice == Options.SCISSORS) {
            finishGame("Scissors cut paper. Player 2 wins", msg.sender);
        } else {
            result = "Draw game. The prize was doubled.";
            player1 = address(0);
            choice1 = Options.NONE;
        }
    }

    function getLeaderboard() external view returns (Player[] memory) {
        if (players.length < 2) return players;

        Player[] memory arr = new Player[](players.length);
        for (uint i = 0; i < players.length; i++) {
            arr[i] = players[i];
        }

        for (uint i = 0; i < arr.length - 1; i++) {
            for (uint j = i + 1; j < arr.length; j++) {
                if (arr[i].wins < arr[j].wins) {
                    Player memory temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }

        return arr;
    }
}
