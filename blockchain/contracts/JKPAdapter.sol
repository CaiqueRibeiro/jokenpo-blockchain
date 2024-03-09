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

    function getAddress() external view returns (address) {
        return address(joKenPo);
    }

    function upgrade(address newImplementation) external {
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

    function play(JKPLibrary.Options newChoice) external payable upgraded {}

    modifier upgraded() {
        require(
            address(joKenPo) != address(0),
            "A valid implementation of JoKenPo was not set yet"
        );
        _;
    }
}
