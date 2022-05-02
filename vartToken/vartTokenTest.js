const {
    expect
} = require("chai");

describe("VARt Token", () => {
    let owner, address1, address2, token, contract;
    describe("Deploying Contract", () => {
        beforeEach(async () => {
            [owner, address1, address2] = await ethers.getSigners();

            token = await ethers.getContractFactory("vartToken");
            contract = await token.deploy();
        })
        it("Basic Info", async () => {
            console.log(await contract.name());
            console.log(await contract.symbol());
            console.log(await contract.decimals());
            console.log(await contract.totalSupply());
            console.log(await contract.founder());
            console.log(await contract.myBalance());
        })
    })

    describe("Trasfer Testing", () => {
        it("Should Transfer Tokens", async () => {

            // Owner -> Address1, Amount:- 100.
            await contract.transfer(address1.address, 100) // Token Transferring From Owner To Address1.
            expect(await contract.myBalance()).to.equal(499999900); // Is Token Deducted From Owner Account, Checked.
            expect(await contract.connect(address1).myBalance()).to.equal(100); // Is Token Added To Address1 Account, Checked.

            // Address1 -> Address2, Amount:- 50.
            await contract.connect(address1).transfer(address2.address, 50); // Token Transferring From Address1 To Address2.
            expect(await contract.connect(address1).myBalance()).to.equal(50); // Is Token Deducted From Address1 Account, Checked.
            expect(await contract.connect(address2).myBalance()).to.equal(50); // Is Token Added To Address2 Account, Checked.

            // Owner -> Address2, Amount:- 1000.
            await contract.transfer(address2.address, 1000) // Token Transferring From Owner To Address2.
            expect(await contract.myBalance()).to.equal(499998900); // Is Token Deducted From Owner Account, Checked.
            expect(await contract.connect(address2).myBalance()).to.equal(1050); // Is Token Added To Address2 Account, Checked.

            // Address2 -> Address1, Amount:- 50.
            await contract.connect(address2).transfer(address1.address, 50); // Token Transferring From Address1 To Address2.
            expect(await contract.connect(address2).myBalance()).to.equal(1000); // Is Token Deducted From Address1 Account, Checked.
            expect(await contract.connect(address1).myBalance()).to.equal(100); // Is Token Added To Address2 Account, Checked.

            // Address2 -> Owner, Amount:- 500.
            await contract.connect(address2).transfer(owner.address, 500); // Token Transferring From Address2 To Owner.
            expect(await contract.connect(address2).myBalance()).to.equal(500); // Is Token Deducted From Address1 Account, Checked.
            expect(await contract.connect(owner).myBalance()).to.equal(499999400); // Is Token Added To Address2 Account, Checked.

        })

        it("Events Should Work Properly", async () => {

            /*
             // We Can Get All Time Events Record Using This Method.
             let eventData = contract.filters.Transfer() 
             let events = await contract.queryFilter(eventData, 0); // Use "latest" Instead Of 0 For Getting Latest Event Data.
            */

            let ownerEventData = contract.filters.Transfer(owner.address)
            let ownerEvents = await contract.queryFilter(ownerEventData, 0);
            console.log("Owner Records", ownerEvents);

            let address1EventData = contract.filters.Transfer(address1.address)
            let address1Events = await contract.queryFilter(address1EventData, 0);
            console.log("Address1 Records", address1Events);

            let address2EventData = contract.filters.Transfer(address2.address)
            let address2Events = await contract.queryFilter(address2EventData, 0);
            console.log("Address2 Records", address2Events);
        })

        it("Should Transfer Using Allowance", async () => {

            // By Address1, Owner -> Address2, Amount:- 50;
            // It Will Show Accounts Balance, Before Transfer Using Allowance.
            console.log("Owner Balance", await contract.myBalance());
            console.log("Address1 Balance", await contract.connect(address1).myBalance());
            console.log("Address2 Balance", await contract.connect(address2).myBalance());

            await contract.approve(address1.address, 100);
            console.log("\nOwner Account Has Provided Allowance Of " + await contract.allowance(owner.address, address1.address) + " Tokens");
            await contract.connect(address1).transferFrom(owner.address, address2.address, 50); // Transferring Tokens By Address1 From Owner To Address2, Using Allowance Provided.
            expect(await contract.allowance(owner.address, address1.address)).to.equal(50); // Is Allowance Balance Deducted, Checked

            // It Will Show Accounts Balance, After Transfer Using Allowance.
            console.log("\nOwner Balance", await contract.myBalance());
            console.log("Address2 Balance", await contract.connect(address2).myBalance());
            console.log("Remaining Allowance Of Address1 Is " + await contract.allowance(owner.address, address1.address));


            // By Address1, Address2 -> Owner, Amount:- 100;
            // It Will Show Accounts Balance, Before Transfer Using Allowance.
            console.log("Owner Balance", await contract.myBalance());
            console.log("Address1 Balance", await contract.connect(address1).myBalance());
            console.log("Address2 Balance", await contract.connect(address2).myBalance());

            await contract.connect(address2).approve(address1.address, 150);
            console.log("\nOwner Account Has Provided Allowance Of " + await contract.allowance(address2.address, address1.address) + " Tokens");
            await contract.connect(address1).transferFrom(address2.address, owner.address, 150); // Transferring Tokens By Address1 From Address2 To Owner, Using Allowance Provided.
            expect(await contract.allowance(address2.address, address1.address)).to.equal(00); // Is Allowance Balance Deducted, Checked

            // It Will Show Accounts Balance, After Transfer Using Allowance.
            console.log("\nOwner Balance", await contract.myBalance());
            console.log("Address2 Balance", await contract.connect(address2).myBalance());
            console.log("Remaining Allowance Of Address1 Is " + await contract.allowance(address2.address, address1.address));

        })

    })
})