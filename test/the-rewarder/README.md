# Challenge#5 Take all the reward token

Challenge consists of four contracts:
- _RewardToken.sol_ <br/>
ERC-20 token to mint *RewardToken* every 5 days. 

- _TheRewarderPool.sol_ <br/>
Deposit *DamnValuableToken* to be rewarded *RewardTokens* every 5 days.

- _AccountingToken.sol_ <br/>
ERC20Snapshot token use to keep historical balances of *DamnValuableToken* deposited into _TheRewarderPool_.

- _DamnValuableToken.sol_ <br/>
ERC-20 token use as liquidity token to be deposited into _TheRewardedPool_ to earn *RewardToken*

- _FlashLoanerPool.sol_ <br/>
Contract to provide flash loans of *DamnValuableToken*

To start somewhere, we take a look at how the rewards are distributed:
```
function distributeRewards() public returns (uint256) {
        uint256 rewards = 0;

        if(isNewRewardsRound()) {
            _recordSnapshot();
        }        
        
        uint256 totalDeposits = accToken.totalSupplyAt(lastSnapshotIdForRewards);
        uint256 amountDeposited = accToken.balanceOfAt(msg.sender, lastSnapshotIdForRewards);

        if (amountDeposited > 0 && totalDeposits > 0) {
            rewards = (amountDeposited * 100 * 10 ** 18) / totalDeposits;

            if(rewards > 0 && !_hasRetrievedReward(msg.sender)) {
                rewardToken.mint(msg.sender, rewards);
                lastRewardTimestamps[msg.sender] = block.timestamp;
            }
        }

        return rewards;     
    }
```
Looking at the function `distributeRewards()`, it calculates rewards based on mathematical formula using `amountDeposited` (by user) and `totalDeposits` (total supply of *DamnVauluableToken* historical snapshot).

The problem with this distribution method is, what if we took out all the *DamnValuableToken* through flash loan before `distributeRewards()` trigger snapshot, deposit all the token into *RewardPool* to receive the reward and return the *DamnValuableToken* all in the same transaction?



