// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "lib/forge-std/src/Script.sol";
import "src/ClaimAndLock.sol";

contract ClaimAndLockScript is Script {
    function run() public {
        vm.startBroadcast();

        ClaimAndLock claimAndLock = new ClaimAndLock();

        vm.stopBroadcast();
    }
}
