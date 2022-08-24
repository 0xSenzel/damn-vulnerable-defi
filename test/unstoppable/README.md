# Stop the pool from offering flash loans

This challenge contains 2 smart contract:
- *UnstoppableLender*
- *ReceiverUnstoppable*

When we deploy the contract through *unstoppable.challenge.js* , 1000000 "ether" token of **DVT (DamnValuableToken)** is deposited into *UnstoppableLender* pool. *ReceiverUnstoppable* contract act as a test to execute flash loan from *UnstoppableLender* and then pays it back.

When looking at the `flashLoan` function, the function keep track of the balance at pool through `poolBalance`
```
assert(poolBalance == balanceBefore);
```
Unlike `balanceBefore` which reads the pool balance directly through `balanceOf` ; `poolBalance` is a user-defined function which takes values from function `depositTokens`.

If we able to bypass `depositTokens` function and send token directly to the pool, it will lead to "accounting error" where by `assert` statement is false and the operation will be halted following with a roll back on `flashLoan`.