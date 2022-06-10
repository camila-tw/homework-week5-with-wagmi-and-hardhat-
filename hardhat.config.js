require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ENDPOINT_URL = process.env.ENDPOINT_URL;

module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: ENDPOINT_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  }
};