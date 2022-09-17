# Challenge#11 Gain backdoor excess to tokens

**_WalletRegistry.sol_** is a type of [proxy factory](https://blockchain-academy.hs-mittweida.de/courses/solidity-coding-beginners-to-intermediate/lessons/solidity-11-coding-patterns/topic/factory-clone/) pattern that uses [minimal proxy contract](https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/). 

From the contract, when user call `proxyCreated()` **_IProxyCreationCallback.sol_** will interface with **_GnosisSafeProxyFactory.sol_** for execution. The proxy factory contract will deploy **_GnosisSafeProxy.sol_** that will `delegatecall` to logic contract **_GnosisSafe.sol_**.

Our **_WalletRegistry.sol_** will interact with **_GnosisSafe.sol_** to perform multisignature wallet with support for confirmations using signed messages based on ERC191. Our contract is not having obvious loophole as it:
- checks if functions is invoked by GnosisSafeProxyFactory
- checks if singleton is from GnosisSafe so we can't manipulate return data
- checks number of wallet == 1 so we can't bypass by increasing number of owner
- checks calldata is from GnosisSafe::setup 

So how can we 'backdoor' it? [This article](https://blog.openzeppelin.com/backdooring-gnosis-safe-multisig-wallets/) explains in detail how a module can be used easily by arbitrary address to execute transactions from the wallet without any confirmations from the owners.

In this case, the `setup()` function of **_GnosisSafe.sol_** contains an interesting "fallbackHandler" that handles fallback to this contract:
```
function setup(
   ...
    ) external {
        ...
        if (fallbackHandler != address(0)) internalSetFallbackHandler(fallbackHandler);
        // As setupOwners can only be called if the contract has not been initialized we don't need a check for setupModules
        setupModules(to, data);
        ...
        }
```
After looking into the fallback handling logic  **_FallbackManager.sol_**:
```
...
fallback() external {
        bytes32 slot = FALLBACK_HANDLER_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let handler := sload(slot)
            if iszero(handler) {
                return(0, 0)
            }
            calldatacopy(0, 0, calldatasize())
            // The msg.sender address is shifted to the left by 12 bytes to remove the padding
            // Then the address without padding is stored right after the calldata
            mstore(calldatasize(), shl(96, caller()))
            // Add 20 bytes for the address appended add the end
            let success := call(gas(), handler, 0, 0, add(calldatasize(), 20), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if iszero(success) {
                revert(0, returndatasize())
            }
            return(0, returndatasize())
        }
    }
...
```
The `fallback()` uses `call` that is different from `delegatecall` ([refer here for some details](https://ethereum.stackexchange.com/questions/3667/difference-between-call-callcode-and-delegatecall)) which means this allowed us to make arbitrary calls to address we want. We can set token fallback address to **_FallbackManager.sol_** , `approve()` the token and call `transfer()`. Since the token contract is being called by wallet, `msg.sender` will be wallet's address and we have access to freely transfer the token.