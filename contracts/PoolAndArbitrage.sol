//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "./Interfaces/IUniswapV2Callee.sol";
import "./Interfaces/IUniswapV2Factory.sol";
import "./Interfaces/IUniswapV2Router02.sol";
import "./Interfaces/IERC20.sol";
import "./Library/UniswapV2Library.sol";


contract PoolAndArbitrage{


    address uniswapFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address sushiFactory = 	0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    address sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address token20;



    event FillPoll(uint value1, uint value2, uint value3);
    event FillPollETH(uint value1, uint value2, uint value3);
    event ArbitrageReached(uint amountRepay, uint amountOut);



    function createPair(address tokenA, address tokenB, address factoryAddress)public{
        address newPair = IUniswapV2Factory(factoryAddress).createPair(tokenA, tokenB);
        token20 = tokenA;
    }



    function getPairAddress(address factoryAddress, address tokenA, address tokenB)public view returns(address){
        return IUniswapV2Factory(factoryAddress).getPair(tokenA, tokenB);
    }



    function addLiquidityToPool(
        address routerAddress,
        address tokenA,
        address tokenB,
        uint amountToFillA,
        uint amountToFillB,
        uint amountMinTokenA,
        uint amountMinTokenB

    )external returns(uint, uint, uint){

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountToFillA);
        IERC20(tokenA).approve(routerAddress, amountToFillA);

        IERC20(tokenB).transferFrom(msg.sender, address(this), amountToFillB);
        IERC20(tokenB).approve(routerAddress, amountToFillB);


        (
        uint amountTokenA,
        uint amountTokenB,
        uint liquidity
        ) = IUniswapV2Router02(routerAddress).addLiquidity(
            tokenA,
            tokenB,
            amountToFillA,
            amountToFillB,
            amountMinTokenA,
            amountMinTokenB,
            address(this),
            block.timestamp
        );

        emit FillPoll(amountTokenA, amountTokenB, liquidity);

        return(amountTokenA, amountTokenB, liquidity);
    }



    function addLiquidityToPoolWETH(
        address routerAddress,
        address tokenA,
        uint amountToFillA,
        uint amountMinTokenA
    )external payable returns(uint, uint, uint){

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountToFillA);
        IERC20(tokenA).approve(routerAddress, amountToFillA);


        (
        uint amountTokenA,
        uint amountETH,
        uint liquidity
        ) = IUniswapV2Router02(routerAddress).addLiquidityETH{value: msg.value}(
            tokenA,
            amountToFillA,
            amountMinTokenA,
            msg.value,
            address(this),
            block.timestamp
        );

        emit FillPollETH(amountTokenA, amountETH, liquidity);

        return (amountTokenA, amountETH, liquidity);
    }



    function checkProfitability(uint amountIn, uint amountOut)internal pure returns(bool){
        return amountOut > amountIn;
    }



    function placeATrade(
        address factory,
        address router,
        address tokenFrom,
        address tokenTo,
        uint amountTrade
    )internal returns(uint){
        address pairAddress = IUniswapV2Factory(factory).getPair(tokenFrom, tokenTo);

        require(pairAddress != address(0), "Pair not exist!");

        address[] memory path = new address[](2);
        path[0] = tokenFrom;
        path[1] = tokenTo;

        IERC20(tokenFrom).approve(router, amountTrade);

        uint amountOutMinFromTrade = IUniswapV2Router02(router).getAmountsOut(amountTrade, path)[1];

        uint amountReceivedFromTrade = IUniswapV2Router02(router).swapExactTokensForTokens(
            amountTrade,
            amountOutMinFromTrade,
            path,
            address(this),
            block.timestamp
        )[1];

        return amountReceivedFromTrade;
    }




    function startArbitrage(
        address tokenToBorrow,
        address tokenToPair,
        uint amountBorrow,
        address factory,
        address router1,
        address router2
    )external{

        address pairAddress = IUniswapV2Factory(factory).getPair(tokenToBorrow, WETH);

        require(pairAddress != address(0), "Pair Not Exist!");

        address token0 = IUniswapV2Pair(pairAddress).token0();
        address token1 = IUniswapV2Pair(pairAddress).token1();

        uint amount0Out = tokenToBorrow == token0 ? amountBorrow : 0;
        uint amount1Out = tokenToBorrow == token1 ? amountBorrow : 0;


        require(amount0Out == 0 || amount1Out == 0, "One of the amount must to be 0 !");

        bytes memory data = abi.encode(factory, router1, router2, amountBorrow, tokenToBorrow, tokenToPair);

        IUniswapV2Pair(pairAddress).swap(amount0Out, amount1Out, address(this), data);
    }


    function uniswapV2Call(address _sender, uint _amount0Out, uint _amount1Out, bytes calldata _data)external{

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();

        (
            address _factory,
            address _router,
            address _router2,
            uint _amountBorrow,
            address _tokenInBorrow,
            address _tokenToPair
        ) = abi.decode(_data, (address, address, address, uint, address, address));

        address pair = IUniswapV2Factory(_factory).getPair(token0, token1);

        require(_sender == address(this), "Sender is not the contract!");
        require(msg.sender == pair, "Caller is not the pair address");

        uint fees = ((_amountBorrow * 3) / 997) + 1;
        uint amountToRepay = fees + _amountBorrow;

        uint amountOutTrade1 = placeATrade(_factory, _router, _tokenInBorrow, _tokenToPair, _amountBorrow);

        uint amountOutTrade2 = placeATrade(_factory, _router2, _tokenToPair, _tokenInBorrow, amountOutTrade1);

        bool isProfitable = checkProfitability(amountToRepay, amountOutTrade2);
        require(isProfitable, "Arbitrage not Profitable! ");

        IERC20(_tokenInBorrow).transfer(msg.sender, amountToRepay);
        IERC20(_tokenInBorrow).transfer(tx.origin, (amountOutTrade2 - amountToRepay));

        emit ArbitrageReached(amountToRepay, (amountOutTrade2 - amountToRepay));

    }

    receive()external payable{}
}
