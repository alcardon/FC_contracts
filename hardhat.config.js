const {
  mnemonic,
  privateKey,
  infuraProjectId,
  bscscanApiKey,
} = require("./secrets.json");

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task(
  "accounts",
  "👩🕵👨🙋👷 Prints the list of accounts (only for localhost)",
  async () => {
    const accounts = await ethers.getSigners();

    for (const account of accounts) {
      console.log(account.address);
    }
    console.log("👩🕵 👨🙋👷 these accounts only for localhost network.");
    console.log(
      'To see their private keys🔑🗝 when you run "npx hardhat node."'
    );
  }
);

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: bscscanApiKey,
  },
  defaultNetwork: "bsctestnet", // <-- change here for other network, default use hardhat network.
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {},
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 1000000000,
      accounts: [privateKey],
    },
    bsctestnet: {
      url: "https://bsc-testnet.public.blastapi.io",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [privateKey],
    },
  },
  solidity: {
    compilers: [{ version: "0.8.13" }],
  },
  settings: {
    optimizer: {
      enabled: true,
    },
  },

  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 20000,
  },
};
