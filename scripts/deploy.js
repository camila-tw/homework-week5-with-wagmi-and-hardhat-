const hre = require("hardhat");

async function main() {
  const KnotNFT = await hre.ethers.getContractFactory("KnotNFT");
  const knotNFT = await KnotNFT.deploy();

  await knotNFT.deployed();

  console.log("Deployed to:", knotNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });