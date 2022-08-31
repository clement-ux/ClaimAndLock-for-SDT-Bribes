// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Helper
import "test/helper/Addresses.t.sol";
import "test/helper/MerkleProof.t.sol";

// Interfaces
import "src/interface/IMultiMerkleStash.sol";
import "src/interface/IVeSDT.sol";

// Contracts
import "src/ClaimAndLock.sol";

contract ClaimAndLockTest is Addresses, MerkleProofFile {
	ERC20 sdt = ERC20(SDT);
	ERC20 _3crv = ERC20(_3CRV);
	ERC20 gno = ERC20(GNO);

	IMultiMerkleStash merkle = IMultiMerkleStash(multiMerkleStash);
	IVeSDT veSDT = IVeSDT(VE_SDT);

	ClaimAndLock claimAndLockContract = new ClaimAndLock();

	IMultiMerkleStash.claimParam public claimParamSDT1;
	IMultiMerkleStash.claimParam public claimParamSDT2;
	IMultiMerkleStash.claimParam public claimParamGNO80;
	IMultiMerkleStash.claimParam[] public claimParamList;

	function setUp() public {
		generateMerkleProof();
		claimParamSDT2 = IMultiMerkleStash.claimParam(SDT, claimerSDT2Index, amountToClaimSDT2, merkleProofSDT2);
		claimParamGNO80 = IMultiMerkleStash.claimParam(GNO, claimerGNO80Index, amountToClaimGNO80, merkleProofGNO80);
		claimParamList.push(claimParamGNO80);
		claimParamList.push(claimParamSDT2);
	}

	function testClaimAndLockSDT() public {
		vm.startPrank(claimerSDT2);
		sdt.approve(address(claimAndLockContract), type(uint256).max);

		uint256 balBeforeVeSDTClaimer = veSDT.balanceOf(claimerSDT2);
		uint256 balBeforeSDTinVeSDT = sdt.balanceOf(VE_SDT);
		uint256 balBeforeSDTinMerkle = sdt.balanceOf(multiMerkleStash);
		bool claimedBefore = merkle.isClaimed(SDT, claimerSDT2Index);

		claimAndLockContract.claimAndLockSDT(claimerSDT2Index, amountToClaimSDT2, merkleProofSDT2);

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

	// new version gas : 277730 (-495)
	// old version gas : 278225

	function testClaimAndLockMulti() public {
		vm.startPrank(claimerSDT2);
		sdt.approve(address(claimAndLockContract), type(uint256).max);

		uint256 balBeforeVeSDTClaimer = veSDT.balanceOf(claimerSDT2);
		uint256 balBeforeSDTinVeSDT = sdt.balanceOf(VE_SDT);
		uint256 balBeforeSDTinMerkle = sdt.balanceOf(multiMerkleStash);
		uint256 balBeforeGNOClaimer = gno.balanceOf(claimerGNO80);
		uint256 balBeforeGNOinMerkle = gno.balanceOf(multiMerkleStash);
		bool claimedBeforeSDT = merkle.isClaimed(SDT, claimerSDT2Index);
		bool claimedBeforeGNO = merkle.isClaimed(GNO, claimerGNO80Index);

		claimAndLockContract.claimAndLockMulti(claimParamList);

		uint256 balAfterVeSDTClaimer = veSDT.balanceOf(claimerSDT2);
		uint256 balAfterSDTinVeSDT = sdt.balanceOf(VE_SDT);
		uint256 balAfterSDTinMerkle = sdt.balanceOf(multiMerkleStash);
		uint256 balAfterGNOClaimer = gno.balanceOf(claimerGNO80);
		uint256 balAfterGNOinMerkle = gno.balanceOf(multiMerkleStash);
		bool claimedAfterSDT = merkle.isClaimed(SDT, claimerSDT2Index);
		bool claimedAfterGNO = merkle.isClaimed(GNO, claimerGNO80Index);

		assertEq(claimedBeforeSDT, false);
		assertEq(claimedAfterSDT, true);
		assertTrue(balAfterVeSDTClaimer - balBeforeVeSDTClaimer > 0);
		assertEq(balBeforeSDTinVeSDT + amountToClaimSDT2, balAfterSDTinVeSDT);
		assertEq(balBeforeSDTinMerkle - amountToClaimSDT2, balAfterSDTinMerkle);

		assertEq(claimedBeforeGNO, false);
		assertEq(claimedAfterGNO, true);
		assertTrue(balAfterGNOClaimer - balBeforeGNOClaimer > 0);
		assertEq(balBeforeGNOinMerkle - amountToClaimGNO80, balAfterGNOinMerkle);
	}
	// new version gas : 327237 (-369)
	// old version gas : 327606
}

/* ---- Gas study ---- */

// 				With private function  	| Without private function
// Deployement : 			436632	 	|		480076 ❌
// ClaimSimple : 			277759  	|		277730 ✅
// ClaimMulti  : 			327266  	|		327237 ✅

// 				 	With diff balance 	| With for loop
// Deployement : 			511707 		| 		480076 ✅
// ClaimMulti  : 			328559		| 		327237 ✅
