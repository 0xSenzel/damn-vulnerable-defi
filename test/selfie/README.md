# Challenge#6 Drain flashloan pool's DVT token

The `SelfiePool` contract has an oddly specific menacingly suspicious function `drainAllFunds()`. Like the name suggest it did just that, so our goal is to run this function to withdraw all token.

However this function pass a modifier:
```
modifier onlyGovernance() {
        require(msg.sender == address(governance), "Only governance can execute this action");
        _;
    }
```
To pass this modifier we have to go through _SimpleGovernance_ contract. Looking at this contract looks like our end game is to `queueAction()` and then `executeAction()`. To go through these functions we have to first make sure we have pass this requirement:
```
function _hasEnoughVotes(address account) private view returns (bool) {
        uint256 balance = governanceToken.getBalanceAtLastSnapshot(account);
        uint256 halfTotalSupply = governanceToken.getTotalSupplyAtLastSnapshot() / 2;
        return balance > halfTotalSupply;
    }
```
Checking back at deployment contract, The initial supply minted is 2 million token of which 1.5 million transffered to `SelfiePool`. If we loan all the token inside `SelfiePool`, we are definitely checking the requirement for `_hasEnoughVotes()`.

Looking at `flashLoan()`, there is a low level `functionCall` which conveniently able to let us use to call `drainAllFunds()`, what a life saver! (or in this case life destroyer)

So to exploit it we need to:

Flashloan all the tokens >> <br/>
Take a snapshot of token >> <br/>
Use function call to call drain fund function >> <br/>
Return flashloan

