# Challenge#9 Drain all DVT in pool

Checking at the contract, since its similar to previous challenge "Puppet" we start by looking at how the contract calculate its price for swapping.
```
// fetches and sorts the reserves for a pair
function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
    (address token0,) = sortTokens(tokenA, tokenB);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
}

// given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
    require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
    require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
    amountB = amountA.mul(reserveB) / reserveA;
}
```
Essentially, this 2 function responsible for fetching the oracle price, instead of putting a math formula they let the [Uniswap contract](https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol) calculates and fetch it. In theory, it should be safe. However when we start reviewing the deployment contract:

**Summary of the token distribution upon deployment**
| party | Token Name | amount |
| --------- | --------- | --------- |
| UNISWAP | WETH | 10 |
| UNISWAP | DVT | 100 |
| ATTACKER | ETH | 20 |
| ATTACKER | DVT | 100000 |
| PUPPETPOOL| DVT | 1000000 |

The contract can still be easily manipulated because
- reserveA (DVT token) is pair with and reserveB (WETH token) is a pair
- Their oracle price is computed with ratio WETH / DVT 
- Attacker is having hugEEEEEEEE amount of DVT token compared to Uniswap pool which can easily skew the ratio to 10 / 100100 = 0.0000999.

So the approach is exactly the same as previous challenge, we need to interact with Uniswap then we:
- Approve DVT token to be transact on Uniswap
- Swap all DVT to WETH to heavily devalue WETH (roughly gets us 9.9xxx amount of WETH)
 
However at this point we will face a problem that is to swap all the _PuppetPool_'s DVT token (1 mil of them) we will need at least 29.49 WETH. We only have 9.9 WETH, although combining with our initial ETH balance 20 is more than enough, so to make this challenge cleaner and simple we just need to :
- Approve DVT token to be transact on Uniswap
- Swap all DVT to ETH using [Uniswap's function](https://docs.uniswap.org/protocol/V2/reference/smart-contracts/router-02#swapexacttokensforeth).
- Swap enough ETH to WETH, may refer this [link](https://ethereum.stackexchange.com/questions/101367/trying-to-swap-eth-for-weth-solidity-but-always-reverting)
- Approve WETH to be transact on Puppetpool
- Execute `borrow()` to
