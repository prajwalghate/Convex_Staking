const { getNamedAccounts, deployments, network } = require("hardhat")
// const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    // const chainId = network.config.chainId

    const lpstake = await deploy("lpstake", {
        from: deployer,
        args: [
            "0xE592427A0AEce92De3Edee1F18E0157C05861564",
            "0xC36442b4a4522E871399CD717aBDD847Ab11FE88",
        ],
        log: true,
        // we need to wait if on a live network so we can verify properly
        // waitConfirmations: network.config.blockConfirmations || 1,
        waitConfirmations: 1,
    })
    log(`lpstake deployed at ${lpstake.address}`)
}

module.exports.tags = ["all", "lpstake"]
