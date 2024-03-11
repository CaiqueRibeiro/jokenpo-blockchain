// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./IJoKenPo.sol";
import "./JKPLibrary.sol";

contract JKPAdapter {
    IJoKenPo private joKenPo;
    address private immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function getImplementationAddress() external view returns (address) {
        return address(joKenPo);
    }

    function upgrade(address newImplementation) external restricted {
        require(msg.sender == owner, "You do not have permission to this");
        require(
            newImplementation != address(0),
            "Empty address is not allowed"
        );
        joKenPo = IJoKenPo(newImplementation);
    }

    function getResult() external view upgraded returns (string memory) {
        return joKenPo.getResult();
    }

    function getBid() external view upgraded returns (uint256) {
        return joKenPo.getBid();
    }

    function getComission() external view upgraded returns (uint8) {
        return joKenPo.getComission();
    }

    function setBid(uint256 newBid) external upgraded restricted {
        return joKenPo.setBid(newBid);
    }

    function setComission(uint8 newComission) external upgraded restricted {
        return joKenPo.setComission(newComission);
    }

    function getBalance() external view upgraded returns (uint256) {
        return joKenPo.getBalance();
    }

    function play(JKPLibrary.Options newChoice) external payable upgraded {
        joKenPo.play{value: msg.value}(newChoice); // have to bypass the payable value to the destination contract
    }

    function getLeaderboard()
        external
        view
        upgraded
        returns (JKPLibrary.Player[] memory)
    {
        return joKenPo.getLeaderboard();
    }

    modifier restricted() {
        require(msg.sender == owner, "You do not have permission to this");
        _;
    }

    modifier upgraded() {
        require(
            address(joKenPo) != address(0),
            "A valid implementation of JoKenPo was not set yet"
        );
        _;
    }
}
