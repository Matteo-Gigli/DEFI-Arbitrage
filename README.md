# DEFI-Arbitrage


<h1>💡 DEFI ARBITRAGE</h1>
<br>
<h3>Scope of this project is to create 3 new pool, on Uniswap-Sushiswap, fill them proportionally to create an Arbitrage possibility, </h3>
<h3>and then create an Arbitrage Bot to perfom it.</h3>
<br>
<br>

<h1>💰 Token20.sol/Token201.sol</h1>
<br>
<h3>As we can see, we created two ERC20 Tokens( Token20, Token201 ), this are our Custom ERC20.</h3>
<h3>These are 2 simplest ERC20 tokens, and the only thing to mentionate is that we will use it to create pools on Uniswap and Sushiswap.</h3>
<h3>The parameters we need to deploy this contracts are: uint totalAmount, address contractToApproveAmount.</h3>
<h3>totalAmount, refers to the amount of tokens we want to create.</h3>
<h3>address contractToApproveAmount refers to the address of PoolAndArbitrage.sol .</h3>
<br>
<br>

<h1>📊 PoolAndArbitrage.sol</h1>
<h3>There are different functions to explain.</h3>
<h3>As we can see, here we are starting to use Uniswap protocol.</h3>
<br>

<h2>function createPair(address tokenA, address tokenB, address factoryAddress).</h2>
<h3>This function allow us to create a new pool of tokens.</h3>
<h3>Just passing the address of tokenA, address of tokenB and the factoryAddress.</h3>
<h3>factoryAddress refers to the factory we choose to create the pair, should be Uniswap, Sushiswap, PancakeSwap... and all the Dex built on Uniswap using the same code.</h3>
<br>

<h2>getPairAddress(address factoryAddress, address tokenA, address tokenB)</h2>
<h3>Is a view function, and will get us back the pair address.</h3>
<br>

<h2>addLiquidityToPool(address routerAddress,address tokenA,address tokenB,uint amountToFillA,uint amountToFillB,uint amountMinTokenA,uint amountMinTokenB)</h2>
<h3>This functions get a series of parameter and it's used to add liquidity to a pool.</h3>
<h3>It cannot be used to fill a pool with ETH, we can use it only for other ERC20 tokens.</h3>
<h3>routerAddress refers to the router where the new pair is.</h3>
<h3>Let's supposed we create a new pair on uniswap factory, now to add liquidity to that pool, i have to connect with the uniswap router.</h3>
<h3>AddressTokenA, AddressTokenB are the token addresses in the new pair.(Pool DAI/WETH, addressPair = 0x32hnmgt6yu6j625453erer547675, 
address DAI(TokenA) = 0x4y8y4586u4586u895648ht, address SAND(TokenB) = 0xchbfhvbfeiugfwefh3h0924432)</h3>
<h3>amountToFillA, amountToFillB, amountMinTokenA, amountMinTokenB.</h3>
<h3>amountToFillA, amountToFillB are the amounts of tokens we want to add to the pool.</h3>
<h3>amountMinTokenA, amountMinTokenB are the min amounts of tokens can be added to the pool.</h3>
<br>


<h2>addLiquidityToPoolWETH(routerAddress, tokenA,uint amountToFillA, amountMinTokenA).</h2>
<h3>This functions get a series of parameter and it's used to add liquidity to a pool.</h3>
<h3>It's different from the addLiquidityToPool() function because it's used to fill a pool with ETH.</h3>
<h3>In fact, as we can see, this function is marked as payable.</h3>
<h3>For the rest is the same function of before.</h3>
<br>

<h2>checkProfitability(uint amountIn, uint amountOut).</h2>
<h3>Internal function that gives me back a boolean.</h3>
<br>


<h2>placeATrade(address factory, address router, address tokenFrom, address tokenTo, uint amountTrade).</h2>
<h3>Internal Function that take some parameter and perform a trade.</h3>
<br>


<h2>startArbitrage(address tokenToBorrow, address tokenToPair, uint amountBorrow, address factory,address router1,address router2).</h2>
<h3>This function will perform the Arbitrage and accord to Uniswap documentation, this function call another function that is</h3>
<h3>uniswapV2Call(address _sender, uint _amount0Out, uint _amount1Out, bytes calldata _data).</h3>
<h3>startArbitrage function have some parameter like:</h3>
<h3>tokenToBorrow, address tokenToPair, amountBorrow that refers on the token we want to get in borrow and the token we want to buy, and the amount of borrow.</h3>
<h3>factory, address router1, address router2 refers to the factory where the pair is been created, and routers is where we are going to perform arbitrage.</h3>
<h3>So in our case we will passing factory where we created the token/WETH pair, and then as tokenToBorrow we take token20, as tokenToPair we take token201.</h3>
<h3>At the end if the arbitrage is not profitable just revert the transaction, otherwise perform the arbitrage.</h3>
<br>

<h2>🔧 Stack Used:</h2>

<h3>Solidity</h3>
<h3>Uniswap</h3>
<h3>Hardhat</h3>
<h3>Ethers.js</h3>
<h3>Openzeppelin</h3>
