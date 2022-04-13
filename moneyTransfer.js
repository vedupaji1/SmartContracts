const {
    expect
} = require("chai");

describe('Money Transfer Test', () => {
    let owner, address1, address2, moneyTransfer, contract;

    describe('Deploying Contract', () => {
        beforeEach(async () => {
            [owner, address1, address2] = await ethers.getSigners();
            moneyTransfer = await ethers.getContractFactory("moneyTransfer");
            contract = await moneyTransfer.deploy();
        })
        it("showBalance, myRecords, myAddress Testing", async () => {
            console.log(await contract.myAddress());
            console.log(await contract.showBalance());
            console.log(await contract.myRecords());
        })
    })


    describe('Should Money Transfer', () => {
        it("Money Transfer", async () => {
            let transferRes = (await contract.sendMoney("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", {
                value: "100000000000000000000"
            }));
        })

        it("Should Record Money Transfer", async () => {
            let senderRecord = await contract.myRecords();
            expect(senderRecord[senderRecord.length - 1].amount).to.equal("100000000000000000000");
            expect(senderRecord[senderRecord.length - 1].isReceived).to.equal(false);
            console.log(senderRecord);

            let receiverRecord = await contract.connect(address1).myRecords();
            expect(receiverRecord[receiverRecord.length - 1].amount).to.equal("100000000000000000000");
            expect(receiverRecord[receiverRecord.length - 1].isReceived).to.equal(true);
            console.log(receiverRecord[receiverRecord.length - 1].time)
            console.log(receiverRecord);
        })
    })



})