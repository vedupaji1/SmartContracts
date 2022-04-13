const {
  expect
} = require("chai");


describe('Temp Contract', () => {

  let owner, address1, address2, contract, temp;

  describe('Deploying Contract', () => {
    beforeEach(async () => {
      [owner, address1, address2] = await ethers.getSigners();
      contract = await ethers.getContractFactory("sendETH");
      temp = await contract.deploy();
    })

    it("Simple Contract Data", async function () {

      const userName = await temp.userAddress();
      console.log(userName);
      console.log(await temp.showBalance())

    });
  })

  describe('transferMoney', () => {
    it("Should Transfer Money", async () => {
      let isDone = (await temp.sendMoney("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", {
        value: "1000000000000000000"
      }));
    })

    it("Should Proper Data Update", async () => {
      expect(await temp.connect(address1).showBalance()).to.equal("10001000000000000000000")
      // assert.equal((await temp.connect(address).showBalance()),"10001000000000000000000")
      console.log(await temp.connect(address1).showBalance())
    })
  })
})