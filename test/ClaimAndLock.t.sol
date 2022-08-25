// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Helper
import "test/helper/Addresses.t.sol";
import "test/helper/MerkleProof.t.sol";

// Interfaces
import "script/interface/IMultiMerkleStash.sol";
import "script/interface/IVeSDT.sol";

// Contracts
import "src/ClaimAndLock.sol";

contract ClaimAndLockTest is Addresses, MerkleProofFile, ClaimAndLock {

    ERC20 sdt = ERC20(SDT);
    ERC20 _3crv = ERC20(_3CRV);
    ERC20 gno = ERC20(GNO);


    IMultiMerkleStash merkle = IMultiMerkleStash(multiMerkleStash);
    IVeSDT veSDT = IVeSDT(VE_SDT);

    ClaimAndLock claimAndLockContract = new ClaimAndLock();

    ClaimParam public claimParamSDT1;
    ClaimParam public claimParamSDT2;
    ClaimParam public claimParamGNO80;
    ClaimParam[] public claimParamList;


    function setUp() public {
        vm.prank(claimerSDT2);
        sdt.approve(address(claimAndLockContract), amountToClaimSDT2);

        generateMerkleProof();
        claimParamSDT2 = ClaimParam(SDT,claimerSDT2Index,amountToClaimSDT2, merkleProofSDT2, true);
        claimParamGNO80 = ClaimParam(GNO,claimerGNO80Index,amountToClaimGNO80, merkleProofGNO80, false);
        claimParamList.push(claimParamSDT2);
        claimParamList.push(claimParamGNO80);
    }

    function testClaimAndLockSDT() public {
        uint256 balBeforeVeSDTClaimer = veSDT.balanceOf(claimerSDT2);
        uint256 balBeforeSDTinVeSDT = sdt.balanceOf(VE_SDT);
        uint256 balBeforeSDTinMerkle = sdt.balanceOf(multiMerkleStash);
        bool claimedBefore = merkle.isClaimed(SDT, claimerSDT2Index);

        claimAndLockContract.claimAndLock(
            SDT,
            claimerSDT2Index,
            claimerSDT2,
            amountToClaimSDT2,
            merkleProofSDT2, 
            true
        );

        uint256 balAfterSDTClaimer = veSDT.balanceOf(claimerSDT2);
        uint256 balAfterSDTinVeSDT = sdt.balanceOf(VE_SDT);
        uint256 balAfterSDTinMerkle = sdt.balanceOf(multiMerkleStash);
        bool claimedAfter = merkle.isClaimed(SDT, claimerSDT2Index);

        assertEq(claimedBefore, false);
        assertEq(claimedAfter, true);
        assertTrue(balAfterSDTClaimer - balBeforeVeSDTClaimer > 0);
        assertEq(balBeforeSDTinVeSDT + amountToClaimSDT2, balAfterSDTinVeSDT);
        assertEq(balBeforeSDTinMerkle - amountToClaimSDT2, balAfterSDTinMerkle);
    }

    function testClaimAndNoLockSDT() public {
        uint256 balBeforeSDTClaimer = sdt.balanceOf(claimerSDT2);
        uint256 balBeforeSDTinVeSDT = sdt.balanceOf(VE_SDT);
        uint256 balBeforeSDTinMerkle = sdt.balanceOf(multiMerkleStash);
        bool claimedBefore = merkle.isClaimed(SDT, claimerSDT2Index);

        claimAndLockContract.claimAndLock(
            SDT,
            claimerSDT2Index,
            claimerSDT2,
            amountToClaimSDT2,
            merkleProofSDT2, 
            false
        );

        uint256 balAfterSDTClaimer = sdt.balanceOf(claimerSDT2);
        uint256 balAfterSDTinVeSDT = sdt.balanceOf(VE_SDT);
        uint256 balAfterSDTinMerkle = sdt.balanceOf(multiMerkleStash);
        bool claimedAfter = merkle.isClaimed(SDT, claimerSDT2Index);

        assertEq(claimedBefore, false);
        assertEq(claimedAfter, true);
        assertEq(balAfterSDTClaimer - balBeforeSDTClaimer, amountToClaimSDT2);
        assertEq(balBeforeSDTinVeSDT, balAfterSDTinVeSDT);
        assertEq(balBeforeSDTinMerkle - amountToClaimSDT2, balAfterSDTinMerkle);
    }

    function testClaimAndLockGNO() public {
        uint256 balBeforeGNOClaimer = gno.balanceOf(claimerGNO80);
        uint256 balBeforeGNOinMerkle = gno.balanceOf(multiMerkleStash);
        bool claimedBefore = merkle.isClaimed(GNO, claimerGNO80Index);

        claimAndLockContract.claimAndLock(
            GNO,
            claimerGNO80Index,
            claimerGNO80,
            amountToClaimGNO80,
            merkleProofGNO80, 
            true
        );

        uint256 balAfterGNOClaimer = gno.balanceOf(claimerGNO80);
        uint256 balAfterGNOinMerkle = gno.balanceOf(multiMerkleStash);
        bool claimedAfter = merkle.isClaimed(GNO, claimerGNO80Index);

        assertEq(claimedBefore, false);
        assertEq(claimedAfter, true);
        assertTrue(balAfterGNOClaimer - balBeforeGNOClaimer > 0);
        assertEq(balBeforeGNOinMerkle - amountToClaimGNO80, balAfterGNOinMerkle);
    }
    
    function testClaimAndLockMulti() public {
        uint256 balBeforeVeSDTClaimer = veSDT.balanceOf(claimerSDT2);
        uint256 balBeforeSDTinVeSDT = sdt.balanceOf(VE_SDT);
        uint256 balBeforeSDTinMerkle = sdt.balanceOf(multiMerkleStash);
        uint256 balBeforeGNOClaimer = gno.balanceOf(claimerGNO80);
        uint256 balBeforeGNOinMerkle = gno.balanceOf(multiMerkleStash);
        bool claimedBeforeSDT = merkle.isClaimed(SDT, claimerSDT2Index);
        bool claimedBeforeGNO = merkle.isClaimed(GNO, claimerGNO80Index);

        claimAndLockContract.claimAndLockMulti(claimerSDT2, claimParamList);

        uint256 balAfterSDTClaimer = veSDT.balanceOf(claimerSDT2);
        uint256 balAfterSDTinVeSDT = sdt.balanceOf(VE_SDT);
        uint256 balAfterSDTinMerkle = sdt.balanceOf(multiMerkleStash);
        uint256 balAfterGNOClaimer = gno.balanceOf(claimerGNO80);
        uint256 balAfterGNOinMerkle = gno.balanceOf(multiMerkleStash);
        bool claimedAfterSDT = merkle.isClaimed(SDT, claimerSDT2Index);
        bool claimedAfterGNO = merkle.isClaimed(GNO, claimerGNO80Index);

        assertEq(claimedBeforeSDT, false);
        assertEq(claimedAfterSDT, true);
        assertTrue(balAfterSDTClaimer - balBeforeVeSDTClaimer > 0);
        assertEq(balBeforeSDTinVeSDT + amountToClaimSDT2, balAfterSDTinVeSDT);
        assertEq(balBeforeSDTinMerkle - amountToClaimSDT2, balAfterSDTinMerkle);

        assertEq(claimedBeforeGNO, false);
        assertEq(claimedAfterGNO, true);
        assertTrue(balAfterGNOClaimer - balBeforeGNOClaimer > 0);
        assertEq(balBeforeGNOinMerkle - amountToClaimGNO80, balAfterGNOinMerkle);
    }
}

// forge test --fork-url "https://eth-mainnet.alchemyapi.io/v2/98WsmgUS7hN0dAjOLyu1-i-nsjoott_X" --etherscan-api-key 6TZZN635QSPNJVF1QJH9ANF53FP1Y3DRN9 --fork-block-number 15408000 --match-contract ClaimAndLock  -vvvv