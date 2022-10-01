// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

/**
 * @dev Interface for Curve.Fi deposit contract for 3-pool.:
 */
interface ICurveFi_Deposittripool {
    function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount)
        external;

    function remove_liquidity(uint256 _amount, uint256[3] calldata min_amounts)
        external;

    function remove_liquidity_imbalance(
        uint256[3] calldata amounts,
        uint256 max_burn_amount
    ) external;

    function coins(int128 i) external view returns (address);

    function token() external view returns (address);
}
