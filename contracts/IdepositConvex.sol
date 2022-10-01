// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

/**
 * @dev Interface for Curve.Fi deposit contract for 3-pool.:
 */
interface IdepositConvex {
    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);
}
