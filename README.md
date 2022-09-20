# Damn Vulnerable Defi Solution
This repo contains solution to Damn Vulnerable Defi challenge.
The challenge's code are documented as such:
- [`./contracts`](https://github.com/janus9/damn-vulnerable-defi/tree/master/contracts) <br/>
Each folder represent a single challenge containing exploitable smart contract for user to 'attack'
- [`./contracts/attacker-contracts`](https://github.com/janus9/damn-vulnerable-defi/tree/master/contracts/attacker-contracts) <br/>
Folder to resite smart contract deployed to 'attack' the exploitable smart contract
- [`./test`](https://github.com/janus9/damn-vulnerable-defi/tree/master/test) <br/>
Each folder represent a single challenge containing test script for deployment of exploitable smart contract and a simple 'README.md' for my thought process.

## Environment Setup
Install dependencies
```
npm install
```
Run test script
```
npm run <CHALLENGE_NAME_FOLLOWING_TEST_FOLDER_NAME>
// eg: npm run backdoor
```

# Credit:
![](cover.png)

**A set of challenges to learn offensive security of smart contracts in Ethereum.**

Featuring flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks, and more!

## Play

Visit [damnvulnerabledefi.xyz](https://damnvulnerabledefi.xyz)

## Disclaimer

All Solidity code, practices and patterns in this repository are DAMN VULNERABLE and for educational purposes only.

DO NOT USE IN PRODUCTION.
