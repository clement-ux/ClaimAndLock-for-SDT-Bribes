// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "lib/forge-std/src/Test.sol";

contract Addresses is Test {
	/* ---- Token ---- */
	address public constant _3CRV = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
	address public constant GNO = address(0x6810e776880C02933D47DB1b9fc05908e5386b96);
	address public constant SDT = address(0x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F);

	/* ---- Contract ---- */
	address public constant VE_SDT = address(0x0C30476f66034E11782938DF8e4384970B6c9e8a);
	address public multiMerkleStash = address(0x03E34b085C52985F6a5D27243F20C84bDdc01Db4);
}
