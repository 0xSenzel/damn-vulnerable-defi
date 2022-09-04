# Challenge#8 Steal all token from pool

The logic of this contract consisting of 
- Lending pool - **_PuppetPool.sol_**
- Decentralized Exchange - **_UniswapV1Exchange.json_**

The lending pool offering DVT token. Looking at the main functions implemented:
- `borrow()` that allow user to borrow an amount of token by depositing an amount of `ETH` equal to the double of the token price that wished to be borrowed.

The function checks `depositRequired` which calculated through `calculateDepositRequired()`. 
- The code multiples `amount` by 2 and `_computeOraclePrice()`
- Upon checking on the `_computeOraclePrice()` , there is no underflow / overflow / reentrancy oppurtunities.

```
function _computeOraclePrice() private view returns (uint256) {
        // calculates the price of the token in wei according to Uniswap pair
        return uniswapPair.balance * (10 ** 18) / token.balanceOf(uniswapPair);
    }
```
The code seems to be check the price to be 1:1 ratio between ETH (in Uniswap) and DVT token (in Uniswap).

The deployment contract gave us a generous amount of DVT:
```
// Uniswap exchange will start with 10 DVT and 10 ETH in liquidity
    const UNISWAP_INITIAL_TOKEN_RESERVE = ethers.utils.parseEther('10');
    const UNISWAP_INITIAL_ETH_RESERVE = ethers.utils.parseEther('10');

    const ATTACKER_INITIAL_TOKEN_BALANCE = ethers.utils.parseEther('1000');
    const ATTACKER_INITIAL_ETH_BALANCE = ethers.utils.parseEther('25');
    const POOL_INITIAL_TOKEN_BALANCE = ethers.utils.parseEther('100000')

```
Summary of the token distribution upon deployment:
| party | Token Name |amount |
| --------- | --------- | --------- |
| UNISWAP | ETH | 10 |
| UNISWAP | DVT | 10 |
| ATTACKER | ETH | 25 |
| ATTACKER | DVT | 1000 |
| PUPPETPOOL| DVT | 100000 |

With that amount of DVT, we can throw the `_computeOraclePrice()` off balance by swapping large amount of DVT in Uniswap:
```
Price before Swap = 10 / 10 = 1
Price After Swap = 10 / (10 + 1000) = 0.00990099...
```
Our step is much clearer now, is to manipulate the price and get all the token for a bargain. We can just borrow large amount of DVT token with very small amount of ETH.
- To interact with Uniswap, we can refer **_UniswapV1Exchange.json_**, a function that can input how many DVT token we need: `tokenToEthSwapInput()` to send all our DVT token to Uniswap pool. May refer [here](https://docs.uniswap.org/protocol/V1/reference/exchange) for extra details on Uniswap Doc.
- After swapping, call `calculateDepositRequired()` to get the amount of collateral we need to send to borrow DVT from Puppetpool.
- Execute `borrow()`

However, we seem to failed the second requirement if we follow this logic. Why? Lets check the requirement:
```
expect(
    await this.token.balanceOf(this.lendingPool.address)
).to.be.eq('0'); 
// Puppetpool DVT token must equal to 0

expect(
    await this.token.balanceOf(attacker.address)
).to.be.gt(POOL_INITIAL_TOKEN_BALANCE);
// Attacker's DVT token must be greater than 100000
```

If we follow this logic, our final DVT token should be just nice at 100000 which is the amount of *POOL_INITIAL_TOKEN_BALANCE*. To be greater than that, we simply subtract the amount sent to Uniswap by 1 we will just nicely touch the line of > than *POOL_INITIAL_TOKEN_BALANCE*.
```
 await attackUniSwap.tokenToEthSwapInput(
            ATTACKER_INITIAL_TOKEN_BALANCE.sub(1), // minus by 1 so by the end of transact our value is greater than POOL_INITIAL_TOKEN_BALANCE
            1, // Min return of ETH (doesn't matter the amount)
            (await ethers.provider.getBlock('latest')).timestamp * 2, // deadline
        )
```