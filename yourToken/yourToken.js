const {
    expect
} = require("chai");
/* Contract Is Fully Tested But Their Test Cases Are Remaining To Write, If You Want To Contribute So You Can Write. */
describe('YourToken Test', () => {
    let owner, address1, address2, moneyTransfer, contract;

    describe('Deploying Contract', () => {
        beforeEach(async () => {
            [owner, address1, address2] = await ethers.getSigners();
            moneyTransfer = await ethers.getContractFactory("yourToken");
            contract = await moneyTransfer.deploy("0x70997970c51812dc3a010c7d01b50e0d17dc79c8");
        })
        it("Should Show Creator Address And Total Tokes For Testing", async () => {
            console.log(await contract.contractCreator());
            console.log(await contract.totalTokens());
        })
    })

    describe("Create And Transfer Tokens", () => {
        it("Should Create Tokens", async () => {
            await contract.createToken("VToken", 1000, 10, 0);
        })

        it("Should Buy Tokens", async () => {
            await contract.buyTokens(100, 1, {
                value: "1000"
            });
        })
    })
})