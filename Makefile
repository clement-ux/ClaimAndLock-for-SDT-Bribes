-include .env

testing :; 
	forge test \
	--fork-url "${MAINNET}" \
	--etherscan-api-key ${ETHERSCAN_KEY} \
	--fork-block-number 15408001 \
	--match-contract ClaimAndLock \
	--match-test test \
	--gas-report \
	-vv

testing_deploy :; 
	forge script \
	script/ClaimAndLock.s.sol:ClaimAndLockScript \
	--fork-url ${MAINNET} \
 	--private-key ${PK} \
	-vvvv

real_deploy :;
	forge script \
	script/ClaimAndLock.s.sol:ClaimAndLockScript \
	--rpc-url ${MAINNET} \
 	--private-key ${} \
	--broadcast \
	--verify \
	--etherscan-api-key ${ETHERSCAN_KEY} \
	-vvvv

verify :;
	forge verify-contract --chain-id 1 \
	--num-of-optimizations 200 \
    --compiler-version v0.8.16+commit.07a7930e 0x5f8f6e921dc872b181cbe0f0585dcb21d82874d8 src/ClaimAndLock.sol:ClaimAndLock  ${ETHERSCAN_KEY}