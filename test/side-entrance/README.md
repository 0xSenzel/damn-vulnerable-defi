# Challenge#4 Drain ETH from lending pool

**SideEntrance** challenge contains a  `flashLoan()` function:
```
function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
```
It takes Ether that user wants to borrow >> <br/>
Checks if lending pool has enough fund >> <br/>
Implements `IFlashLoanEtherReceiver` interface and calls `execute` function to send the request Ether >> <br/>
Checks if flash loan has been repaid

The `flashLoan()` uses `balanceBefore` to check balance while `withdraw()` uses `balances[msg.sender]`. This can easily cause accounting error as the contract does not check if balance is equal to the deposit fund.

So if we deposit the flash loan we take?