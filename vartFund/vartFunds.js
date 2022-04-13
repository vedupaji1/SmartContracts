const {
    expect
} = require("chai");


describe("VARtFunds ", () => {
    let owner, address1, address2, temp, contract;
    describe("Deploying Contract", () => {
        beforeEach(async () => {
            [owner, address1, address2] = await ethers.getSigners();
            temp = await ethers.getContractFactory("vartFunds");
            contract = await temp.deploy();
        })
        it("Basic Info", async () => {
            console.log(await contract.contractCreator());
            console.log(await contract.totalDonationFunds());
        })
    })

    describe("Create Donations", () => {
        it("Should Create Donation", async () => {
            //await contract.createDonationFund("Help For Silk Web", "We Want To Grow Silk Web More For People", "0x8ac7230489e80000", "vedupaji@gmail.com");
            await contract.createDonationFund("Help For Silk Web", "We Want To Grow Silk Web More For People", "500000000000000000000", "vedupaji@gmail.com"); // Here We Are Passing Value In Simple Number Form.
            await contract.createDonationFund("Help For Free Web", "We Want To Create Restriction Less Web", "0x3635c9adc5dea00000", "freeWeb@gmail.com"); // And Here We Are Passing Value In Hex Form Basically For Storing Big Numbers We Has To Use This Method
            await contract.createDonationFund("Help For Creating School", "We Want To Create School For Kids", "0x4563918244f40000", "VARt NGO");
            await contract.createDonationFund("Help For Komals Treatment", "We Want To Do Treatment Of Komal", "0x0de0b6b3a7640000", "vedupaji@gmail.com");
            //console.log(await contract.activeDonationsLists());
        })
    })

    describe("Transfer Ethers", () => {
        it("Should Transfer Ethers Donation", async () => {
            // await contract.donate(1,{value:"0x4563918244f40000"});
            // await contract.connect(address1).donate(1,{value:"0x06f776571d3f0000"});
            // await contract.donate(1,{value:"0x3782dace9d900000"});
            // await contract.connect(address2).donate(1,{value:"0x0de0b6b3a7640000"});


            await contract.donate(1,{value:"490000000000000000000"});
            await contract.connect(address1).donate(1,{value:"50000000000000000000"});
            // await contract.donate(1,{value:"5000000000000000000000"});
            // await contract.connect(address2).donate(1,{value:"5000000000000000000000"});

            console.log(await contract.donationFunds(1));
           // console.log(await contract.activeDonationsLists());
        })
    })
})