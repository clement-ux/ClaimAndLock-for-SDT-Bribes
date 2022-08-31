-include .env

testing :; 
	forge test \
	--fork-url "${MAINNET}" \
	--etherscan-api-key ${ETHERSCAN_KEY} \
	--fork-block-number 15408001 \
	--match-contract ClaimAndLockV2 \
	--match-test test \
	--gas-report \
	-vv