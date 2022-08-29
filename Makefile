-include .env

testing :; 
	forge test \
	--fork-url "${MAINNET}" \
	--etherscan-api-key ${ETHERSCAN_KEY} \
	--fork-block-number 15408001 \
	--match-contract Claim \
	--match-test test \
	-vv