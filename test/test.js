const{expect} = require("chai");
const{expectRevert} = require("@openzeppelin/test-helpers");
const IERC20 = require("@uniswap/v2-core/build/IERC20.json").abi;


describe("Testing contract functionalities", function() {


    let Contract, contract, owner, account1,
        WETH_TOKEN, Token20, token20, Token201, token201;


    const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; //18
    const uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const sushiFactory = "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac";
    const sushiRouter = "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F";


    before(async () => {

        [owner, account1] = await ethers.getSigners();


        Contract = await ethers.getContractFactory("PoolAndArbitrage");
        contract = await Contract.deploy();
        await contract.deployed();


        Token20 = await ethers.getContractFactory("Token20");
        token20 = await Token20.deploy(ethers.utils.parseEther("10000000"), contract.address);
        await token20.deployed();

        Token201 = await ethers.getContractFactory("Token201");
        token201 = await Token20.deploy(ethers.utils.parseEther("10000000"), contract.address);
        await token201.deployed();


        WETH_TOKEN = await ethers.getContractAt(IERC20, WETH, owner);

    });


    ///Create a pool Token20/WETH on Uniswap

    it("should be able to create a pair on Uniswap and get the address", async () => {
        await contract.createPair(token20.address, WETH, uniswapFactory);

        let pairAddress = await contract.getPairAddress(uniswapFactory, token20.address, WETH);

        console.log("")
        console.log("Token20/WETH Pool created on Uniswap at address: ", pairAddress);
        console.log("")
    });


    ///Create a pool Token20/Token201 on Uniswap

    it("should be able to create a pair on Uniswap of token20/token201 and get the address", async () => {
        await contract.createPair(token20.address, token201.address, uniswapFactory);

        let pairAddress = await contract.getPairAddress(uniswapFactory, token20.address, token201.address);

        console.log("Token20/Token201 Pool created on UniSwap at address: ", pairAddress);
        console.log("")
    });



    ///Create a pool Token20/Token201 on Sushiswap

    it("should be able to create a pair on SushiSwap of token20/token201 and get the address", async () => {
        await contract.createPair(token20.address, token201.address, sushiFactory);

        let pairAddress = await contract.getPairAddress(sushiFactory, token20.address, token201.address);

        console.log("Token20/Token201 Pool created on SushiSwap at address: ", pairAddress);
        console.log("")
    });



    //Fill Pool token20/token201 on Uniswap

    it("should be able to fill pool on Uniswap", async()=>{

        let tx = await contract.addLiquidityToPool(
            uniswapRouter,
            token20.address,
            token201.address,
            ethers.utils.parseEther("1000000"),
            ethers.utils.parseEther("2000000"),
            ethers.utils.parseEther("1000000"),
            ethers.utils.parseEther("2000000")
            );

        await tx.wait();

        contract.on("FillPoll", (amountTokenA, amountTokenB, liquidity) => {
            console.log("TokenA Amount Accepted: ", amountTokenA/10**18);
            console.log("TokenB Amount Accepted: ", amountTokenB/10**18);
            console.log("Liquidity: ", liquidity.toString());
        });

        console.log("")


        await new Promise(res => setTimeout(() => res(null), 5000));
    });




    //Fill Pool token20/token201 on Sushiswap

    it("should be able to fill pool on Uniswap", async()=>{

        let tx = await contract.addLiquidityToPool(
            sushiRouter,
            token20.address,
            token201.address,
            ethers.utils.parseEther("1000000"),
            ethers.utils.parseEther("1000000"),
            ethers.utils.parseEther("1000000"),
            ethers.utils.parseEther("1000000")
            );

        await tx.wait();

        contract.on("FillPoll", (amountTokenA, amountTokenB, liquidity) => {
            console.log("TokenA Amount Accepted: ", amountTokenA/10**18);
            console.log("TokenB Amount Accepted: ", amountTokenB/10**18);
            console.log("Liquidity: ", liquidity.toString());
        });

        console.log("")


        await new Promise(res => setTimeout(() => res(null), 5000));
    });




    //Fill Pool token20/WETH on Uniswap

    it("should be able to fill pool on Uniswap", async()=>{

        let tx = await contract.addLiquidityToPoolWETH(
            uniswapRouter,
            token20.address,
            ethers.utils.parseEther("5000000"),
            ethers.utils.parseEther("5000000"),
            {value: ethers.utils.parseEther("25")},
            );

        await tx.wait();

        contract.on("FillPollETH", (amountTokenA, amountETH, liquidity) => {
            console.log("Token Amount Accepted: ", amountTokenA/10**18);
            console.log("ETH Amount Accepted: ", amountETH/10**18);
            console.log("Liquidity: ", liquidity.toString());
        });

        console.log("")


        await new Promise(res => setTimeout(() => res(null), 5000));
    });




    it("should be able to perform an arbitrage between the DEX", async()=> {
        await owner.sendTransaction({to: contract.address, value: ethers.utils.parseEther("1")})

        let token20BalanceBeforeArbitrageAccount1 = await token20.balanceOf(account1.address);
        console.log("Account1 Balance Token20 Before Arbitrage: ", token20BalanceBeforeArbitrageAccount1/10**18);
        console.log("");


        await contract.connect(account1).startArbitrage(
            token20.address,
            token201.address,
            ethers.utils.parseEther("100"),
            uniswapFactory,
            uniswapRouter,
            sushiRouter
        );


        let token20BalanceAfterArbitrageAccount1 = await token20.balanceOf(account1.address);
        console.log("Account1 Balance Token20 After Arbitrage: ", token20BalanceAfterArbitrageAccount1/10**18);
        console.log("");


        contract.on("ArbitrageReached", (amountRepay, amountReached) => {
            console.log("Token Amount Repayed: ", amountRepay/10**18);
            console.log("Token Amount for user: ", amountReached/10**18);
        });


        await new Promise(res => setTimeout(() => res(null), 5000));
    });
})

