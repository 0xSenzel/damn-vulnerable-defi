# Challenge#3 Drain pool's DVT token

The contract transfers a set amount of DTV token to borrower and then calls a target address making a `functionCall()`
```
function flashLoan (
...
    damnValuableToken.transfer(borrower, borrowAmount);
    target.functionCall(data);
...
```
When `flashLoan()` is called, it will call any function on any address defined as _target_.

The function `flashLoan()` does not check minimum amount to borrow, so we can borrow 0 token to gain access to the pool to transfer all the token.
______
## Takeaway
We should not trust other contracts to do any external calls. [Link](https://consensys.github.io/smart-contract-best-practices/development-recommendations/general/external-calls/)