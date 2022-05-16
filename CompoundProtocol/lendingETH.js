const {
    expect
} = require("chai");

describe("temp Contract", () => {
    let tempContract, contract;
    describe("Deploying Contract And Testing Basic Functions", () => {
        beforeEach("Deploy Contract", async () => {
            tempContract = await ethers.getContractFactory("temp");
            contract = await tempContract.deploy();
        })
        it("Basic Functions Should Work", async () => {
            await contract.getSupplyRate();
            await contract.getExchangeRate();
        })
    })

    describe("Deposit Method Should Work", () => {
        it("Depositing Ethers", async () => {
            await contract.depositETH({
                value: "1000000000000000000"
            })
            let res = await contract.showBalance();
            let logs = await res.wait();
            let iface = new ethers.utils.Interface(["event ShowBalance(address user,uint balance)"]); // Parsing Event Logs For Extracting Data, Visit "https://github.com/ethers-io/ethers.js/issues/487" For More Info
            console.log(iface.parseLog(logs.logs[0]))
            console.log(await contract.contractBalance());
        })
    })

    describe("Withdrawn Method Should Work", () => {
        it("Withdrawing Ethers", async () => {
            // await contract.withdrawn(4984728787);
            await contract.withdrawn("1000000000000000000");
            console.log(await contract.contractBalance());
            let res = await contract.showBalance();
            let logs = await res.wait();
            let iface = new ethers.utils.Interface(["event ShowBalance(address user,uint balance)"]); // Parsing Event Logs For Extracting Data, Visit "https://github.com/ethers-io/ethers.js/issues/487" For More Info
            console.log(iface.parseLog(logs.logs[0]))
            console.log(await contract.contractBalance());
        })
    })


})