const {
    expect
} = require("chai");

describe("ERC1155Prac Contract Test", () => {
    let owner, address1, address2, address3, address4, ERC1155, contract;
    describe("Deploying Contract And Using Some Methods", () => {
        beforeEach("Deploy Contract", async () => {
            [owner, address1, address2, address3, address4] = await ethers.getSigners();
            ERC1155 = await ethers.getContractFactory("ERC1155Prac");
            contract = await ERC1155.deploy();
        })

        it("Should Work Basic Functions", async () => {
            console.log(await contract.name());
            console.log(await contract.symbol());
        })
    })

    describe('Minting Should Work', async () => {
        it("Should Mint", async () => {
            await contract.mint(address1.address, 1, 1, "0x00");
            expect(await contract.minter(1)).to.equal(address1.address);
            expect(await contract.balanceOf(address1.address, 1)).to.equal(1);

            await contract.mint(owner.address, 2, 10, "0x00");
            expect(await contract.minter(2)).to.equal(owner.address);
            expect(await contract.balanceOf(owner.address, 2)).to.equal(10);

            await contract.connect(address1).mint(address2.address, 3, 12, "0x00");
            expect(await contract.minter(3)).to.equal(address2.address);
            expect(await contract.balanceOf(address2.address, 3)).to.equal(12);

            await contract.connect(address3).mint(address3.address, 4, 200, "0x00");
            expect(await contract.minter(4)).to.equal(address3.address);
            expect(await contract.balanceOf(address3.address, 4)).to.equal(200);

            await contract.connect(address3).mint(address3.address, 5, 1000, "0x00");
            expect(await contract.minter(5)).to.equal(address3.address);
            expect(await contract.balanceOf(address3.address, 5)).to.equal(1000);
        })
    })

    describe('Balance Shower And Total Supply Methods Should Work', async () => {
        it("Should Show Balance", async () => {
            console.log(await contract.balanceOfBatch([
                address1.address,
                owner.address,
                address2.address,
                address3.address,
                address3.address
            ], [1, 2, 3, 4, 5]))
        })

        it("Should Show Total Supply", async () => {
            expect(await contract.totalSupply(1)).to.equal(1);
            expect(await contract.totalSupply(2)).to.equal(10);
            expect(await contract.totalSupply(3)).to.equal(12);
            expect(await contract.totalSupply(4)).to.equal(200);
            expect(await contract.totalSupply(5)).to.equal(1000);
        })
    })

    describe('Approvals Should Work', async () => {
        it("Should Provide Approval", async () => {
            await contract.setApprovalForAll(address1.address, true);
            expect(await contract.isApprovedForAll(owner.address, address1.address)).to.equal(true);

            await contract.setApprovalForAll(address2.address, false);
            expect(await contract.isApprovedForAll(owner.address, address2.address)).to.equal(false);

            await contract.connect(address1).setApprovalForAll(owner.address, true);
        })
    })

    describe('Transfer Methods Should Work', async () => {
        it("Single Transfer By Owner Of Account", async () => {
            await contract.safeTransferFrom(owner.address, address1.address, 2, 8, "0x00");
            expect(await contract.balanceOf(owner.address, 2)).to.equal(2);
            expect(await contract.balanceOf(address1.address, 2)).to.equal(8);

            await contract.connect(address3).safeTransferFrom(address3.address, address1.address, 5, 100, "0x00");
            await contract.connect(address3).safeTransferFrom(address3.address, owner.address, 5, 200, "0x00");
            expect(await contract.balanceOf(address3.address, 5)).to.equal(700);
            expect(await contract.balanceOf(owner.address, 5)).to.equal(200);
            expect(await contract.balanceOf(address1.address, 5)).to.equal(100);
        })

        it("Single Transfer By Operator Of Account", async () => {
            await contract.safeTransferFrom(address1.address, owner.address, 1, 1, "0x00");
            await contract.safeTransferFrom(address1.address, owner.address, 2, 8, "0x00");
            await contract.safeTransferFrom(address1.address, owner.address, 5, 100, "0x00");
            expect(await contract.balanceOf(address1.address, 1)).to.equal(0);
            expect(await contract.balanceOf(address1.address, 2)).to.equal(0);
            expect(await contract.balanceOf(address1.address, 5)).to.equal(0);

            expect(await contract.balanceOf(owner.address, 1)).to.equal(1);
            expect(await contract.balanceOf(owner.address, 2)).to.equal(10);
            expect(await contract.balanceOf(owner.address, 5)).to.equal(300);

        })
    })

    describe("Displaying Event Logs", () => {
        it("should Show Logs", async () => {
            console.log(contract.filters.Mint(owner.address));
            console.log(contract.filters.TransferSingle(owner.address));
            console.log(contract.filters.ApprovalForAll(owner.address));
        })

    })


})