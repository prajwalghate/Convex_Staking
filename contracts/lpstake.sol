// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "./ICurveFi_Deposittripool.sol";
import "./IdepositConvex.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "hardhat/console.sol";

contract lpstake {
    address owner;
    uint8 immutable _decimalsUSDC = 6;
    struct StakeItem {
        uint256 USDT;
        uint256 WBTC;
        uint256 WETH;
    }
    
    mapping(address => StakeItem) public stakingBalance;
    ISwapRouter public immutable swapRouter;
    address public curveFi_tripool;
    address public curveFi_LPToken;
    address public depositConvex;
    uint256 public  pid;


    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;//ethereum mainnet
    address public constant WETH9 =0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 ;//ethereum mainnet
    address public constant WBTC=0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 ;//ethereum mainnet
    address public constant USDT= 0xdAC17F958D2ee523a2206206994597C13D831ec7;//ethereum mainnet



    constructor(ISwapRouter _swapRouter,address _tripool,address _depositConvex,uint256 _pid  ) {
        swapRouter = _swapRouter;//0xE592427A0AEce92De3Edee1F18E0157C05861564
        curveFi_tripool=_tripool;//0xD51a44d3FaE010294C616388b506AcdA1bfAAE46
        curveFi_LPToken=ICurveFi_Deposittripool(_tripool).token();
        depositConvex=_depositConvex;//0xF403C135812408BFbE8713b5A23a04b3D48AAE31
        owner = msg.sender;
        pid=_pid;//38
    }

    function depositTokens(uint256 _amount) public {
        // amount should be > 0
        require(_amount>0);
        uint256 division= _amount/3;

        TransferHelper.safeTransferFrom(USDC, msg.sender, address(this), _amount);

        TransferHelper.safeApprove(USDC, address(swapRouter),_amount);

        uint256 wbtcDivision = swapExactInputSingle(division,USDC,WBTC);
        uint256 wethDivision = swapExactInputSingle(division,USDC,WETH9);
        uint256 usdtDivision = swapExactInputSingle(division,USDC,USDT);
        // update staking balance
        stakingBalance[msg.sender] = StakeItem(usdtDivision,wbtcDivision,wethDivision);
        depostitInCurvefi();
    }


    function swapExactInputSingle(uint256 amountIn,address inToken,address outToken) internal returns (uint256 amountOut) {
          
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: inToken,
                tokenOut: outToken,
                fee: 3000,
                // recipient: msg.sender,
                recipient:address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }

    function depostitInCurvefi() internal {
        address[3] memory stablecoins=[USDT,WBTC,WETH9] ;
        uint256[3] memory amounts=[stakingBalance[msg.sender].USDT,stakingBalance[msg.sender].WBTC,stakingBalance[msg.sender].WETH] ;
        for (uint256 i = 0; i < stablecoins.length; i++) {
            TransferHelper.safeApprove(stablecoins[i], address(curveFi_tripool),amounts[i]);
        }

        //- deposit stablecoins and get Curve.Fi LP tokens
        ICurveFi_Deposittripool(curveFi_tripool).add_liquidity(amounts, 0); //0 to mint all Curve has to
        uint256 curveLPBalance = IERC20(curveFi_LPToken).balanceOf(address(this)); 
        console.log("curveLPBalance",curveLPBalance);

        depostitInConvex(curveLPBalance);

    }

    function depostitInConvex(uint256 curveLPBalance) internal {
        TransferHelper.safeApprove(curveFi_LPToken,depositConvex, curveLPBalance);
        IdepositConvex(depositConvex).deposit(pid,curveLPBalance,true);
        console.log("depostitInConvex done");
    }
    


  
}
