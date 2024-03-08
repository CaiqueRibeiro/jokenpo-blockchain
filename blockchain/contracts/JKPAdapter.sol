// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./IJoKenPo.sol";

contract JKPAdapter {
    IJoKenPo private joKenPo;
    address private immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == owner, "You do not have permission to this");
        require(
            newImplementation != address(0),
            "Empty address is not allowed"
        );
        joKenPo = IJoKenPo(newImplementation);
    }
}
