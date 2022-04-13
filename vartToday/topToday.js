const {
    expect
} = require("chai");


describe("VARtFunds ", () => {
    let owner, address1, address2, address3, address4, address5, address6, temp, contract;
    describe("Deploying Contract", () => {
        beforeEach(async () => {
            [owner, address1, address2, address3, address4, address5, address6] = await ethers.getSigners();
            temp = await ethers.getContractFactory("topToday");
            contract = await temp.deploy();
        })
        it("Basic Info", async () => {
            console.log(await contract.contractCreator());
            console.log(await contract.priceInterval());
            console.log(await contract.totalUsers());
            console.log(await contract.totalDataItems());
        })
    })

    describe("Creating User Account", () => {
        it("Should Create Account", async () => {
            await contract.createAccount("Vedupaji", "I Am Good Guy");
            await contract.connect(address1).createAccount("Vedu", "I Am Good Guy");
            expect(await contract.userNames("Vedupaji")).to.equal(owner.address);
            expect(await contract.userNames("Vedu")).to.equal(address1.address);
            // console.log(await contract.usersData(owner.address,0));
            // console.log(await contract.usersData(address1.address,0));        
        })
    })

    describe("Adding Data In User Account", () => {
        it("Should Add Data", async () => {
            await contract.setData("Visit vedupaji.com", "This Is My Blogging Site");
            await contract.connect(address1).setData("I Like Solidity", "Its My View");
            await contract.connect(address1).setData("I Like Java", "Its My View");
            // console.log(await contract.getData(owner.address,1));
            // console.log(await contract.getData(address1.address,1));   
            // console.log(await contract.usersData(address1.address,2));      
        })
    })
    describe("Getting Data From User Account", () => {
        it("Should Get Data", async () => {
            // console.log(await contract.getData("Vedupaji"));
            // console.log(await contract.getData("Vedu"));
        })
    })

    describe("Setting TopData", () => {
        it("Should Set Data", async () => {
            await contract.setTopData(1, "Visit SilkWeb For Buying Any Product", "It Is Open Source Site Where Anyone Can Sell Their Product", {
                value: "10000"
            });
            await contract.connect(address1).setTopData(5, "Op Bhai", " Hello", {
                value: "100"
            });

            // console.log(await contract.getTopData());
            // console.log(await contract.getTopDataItemsPrice());
            await contract.connect(address1).setTopData(1, "Visit PornHub", "It Is Porn Website", {
                value: "10002"
            });
            // console.log(await contract.getTopData());
            // console.log(await contract.getTopDataItemsPrice());
            // console.log(await contract.getData("Vedupaji"));
            // console.log(await contract.getData("Vedu"));
        })
    })

    describe("Setting TopData Price", () => {
        it("Should Set Price", async () => {
            await contract.setTopDataPrice(2,10000000);
            await contract.setTopDataPrice(4,200000);
            // console.log(await contract.getTopDataItemsPrice());         
        })
    })

    describe("Setting Price Interval", () => {
        it("Should Set Price", async () => {
            await contract.setPriceInterval(5);   
            console.log(await contract.priceInterval());         
        })
    })


});