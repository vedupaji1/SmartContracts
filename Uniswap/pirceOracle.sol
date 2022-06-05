// SPDX-License-Identifier:MIT

pragma solidity 0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "hardhat/console.sol";

contract priceOracle {
    address public contractCreator = msg.sender;

    function getPrice() public returns (uint256) {
        address poolAddress;
        address token1 = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC Mainnet Address
        address token2 = 0x111111111117dC0aa78b770fA6A738034120C302; // Oneinch Mainnet Address
        poolAddress = IUniswapV3Factory(
            0x1F98431c8aD98523631AE4a59f267346ea31F984 // Factory Address, Obtained From Documetation.
        ).getPool(token1, token2, 3000);
        (int24 tick, ) = OracleLibrary.consult(poolAddress, 10);
        uint256 amount = OracleLibrary.getQuoteAtTick(
            tick,
            1000000, // 1000000=1 USDC, Because USDC Have 6 Decimals
            token1,
            token2
        );
        console.log(amount);
        return 0;
    }
}
