# Challenge#10 Send all 6 NFT from market place to buyer

Challenge consist of contract **_FreeRiderBuyer.sol_**, **_FreeRiderNFTMarketplace.sol_**.
- **_FreeRiderBuyer.sol_** mainly is to implement `onERC721Received()` function to [receive NFT token](https://immutablesoft.github.io/ImmutableEcosystem/docs/IERC721ReceiverUpgradeable.html). This contract also checks if we submitted 6 NFT to buyer, if yes it will transfer 45 ETH to attacker.
- **_FreeRiderNFTMarketplace.sol_** let users to offer NFT to sell and buy NFT either by bulk or 1 by 1 purchase / sell. 

Our main target is the contract to buy NFT since we want to take them out its logically to look at function that will bring the NFT out: `_buyOne()` and `buyMany()`.

After looking at the functions:
- `buyMany()` runs loop to loop through number of NFT available then trigger `_buyOne()` to buy them 1 by 1. However this function does not check "total price of NFT sold" but instead check only 
```
require(msg.value >= priceToPay, "Amount paid is not enough");
// That means we can buy all NFT with only price of 1
```
So...how should we continue? Through the title given attacker only start with 0.5 ETH which is way lesser than the price of 1 NFT (15 ETH). Looking at deployment contract for clues:

**Summary of the token distribution upon deployment**
| party | Token Name | amount |
| --------- | --------- | --------- |
| ATTACKER | ETH | 0.5 |
| UNISWAP | WETH | 9,000 |

Notice that deployment contract deployed as well 
```
UniswapV2Pair.json
UniswapV2Factory.json
UniswapV2Router02.json
```
Checking at UniswapV2 contract, we can find a [flash swap](https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/using-flash-swaps). Similar to flash loan, exactly the thing we need. Since we are dealing with ERC721 token (NFT), note that we need to implement transfer using [this](https://ethereum.stackexchange.com/questions/120996/what-is-the-difference-between-safetransferfrom-and-transferfrom-functions-i) method and implement [this](https://ethereum.stackexchange.com/questions/68461/onerc721recieved-implementation) method to receive NFT to avoid errors

Our attack plan should looks something like this:
- Flash swap loan 15 ether
- Buy all 6 NFT using price of 1
- Send all NFT to buyer
- Return loan