require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
      forking:{
        url: process.env.ALCHEMY_API_URL
      }
    }
  },
};
