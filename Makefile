# Makefile for Foundry Ethereum Development Toolkit

.PHONY: build test format snapshot anvil deploy deploy-anvil cast help subgraph

build:
	@echo "Building with Forge..."
	@forge build

test-forge:
	@echo "Testing with Forge..."
	@forge test

test-hardhat:
	@echo "Testing with Hardhat..."
	@npx hardhat test


format:
	@echo "Formatting with Forge..."
	@forge fmt

snapshot:
	@echo "Creating gas snapshot with Forge..."
	@forge snapshot

anvil:
	@echo "Starting Anvil local Ethereum node..."
	@anvil

deploy-anvil:
	@echo "Deploying with Forge to Anvil..."
	@forge create ./src/Generic.sol:Generic --rpc-url anvil --interactive --constructor-args 3073193977 "your_ipfs_hash_here" "ipfs://"  | tee deployment-anvil.txt

deploy:
	@eval $$(curl -H "x-auth-token: $${BTP_SERVICE_TOKEN}" -s $${BTP_CLUSTER_MANAGER_URL}/ide/foundry/$${BTP_SCS_ID}/env | sed 's/^/export /'); \
	if [ -z "$${BTP_FROM}" ]; then \
		echo "\033[1;33mWARNING: No keys are activated on the node, falling back to interactive mode...\033[0m"; \
		echo ""; \
		if [ -z "$${BTP_GAS_PRICE}" ]; then \
			forge create ./src/Generic.sol:Generic $${EXTRA_ARGS} --rpc-url $${BTP_RPC_URL} --interactive --legacy --constructor-args 3073193977 "your_ipfs_hash_here" "ipfs://" | tee deployment.txt; \
		else \
			forge create ./src/Generic.sol:Generic $${EXTRA_ARGS} --rpc-url $${BTP_RPC_URL} --interactive --legacy --gas-price $${BTP_GAS_PRICE} --constructor-args 3073193977 "your_ipfs_hash_here" "ipfs://" | tee deployment.txt; \
		fi; \
	else \
		if [ -z "$${BTP_GAS_PRICE}" ]; then \
			forge create ./src/Generic.sol:Generic $${EXTRA_ARGS} --rpc-url $${BTP_RPC_URL} --from $${BTP_FROM} --unlocked --constructor-args 3073193977 "your_ipfs_hash_here" "ipfs://" | tee deployment.txt; \
		else \
			forge create ./src/Generic.sol:Generic $${EXTRA_ARGS} --rpc-url $${BTP_RPC_URL} --from $${BTP_FROM} --unlocked --gas-price $${BTP_GAS_PRICE} --legacy --constructor-args 3073193977 "your_ipfs_hash_here" "ipfs://" | tee deployment.txt; \
		fi; \
	fi


cast:
	@echo "Interacting with EVM via Cast..."
	@cast $(SUBCOMMAND)


subgraph:
	@echo "Deploying the subgraph..."
	@rm -Rf subgraph/subgraph.config.json
	@DEPLOYED_ADDRESS=$$(grep "Deployed to:" deployment.txt | awk '{print $$3}') yq e -p=json -o=json '.datasources[0].address = env(DEPLOYED_ADDRESS) | .chain = env(BTP_NODE_UNIQUE_NAME)' subgraph/subgraph.config.template.json > subgraph/subgraph.config.json
	@cd subgraph && npx graph-compiler --config subgraph.config.json --include node_modules/@openzeppelin/subgraphs/src/datasources ./datasources --export-schema --export-subgraph
	@cd subgraph && yq e '.specVersion = "1.0.0"' -i generated/solidity-statemachine.subgraph.yaml
	@cd subgraph && yq e '.description = "Solidity Statemachine"' -i generated/solidity-statemachine.subgraph.yaml
	@cd subgraph && yq e '.repository = "https://github.com/settlemint/solidity-statemachine"' -i generated/solidity-statemachine.subgraph.yaml
	@cd subgraph && yq e '.indexerHints.prune = "auto"' -i generated/solidity-statemachine.subgraph.yaml
	@cd subgraph && yq e '.features = ["nonFatalErrors", "fullTextSearch", "ipfsOnEthereumContracts"]' -i generated/solidity-statemachine.subgraph.yaml
	@cd subgraph && npx graph codegen generated/solidity-statemachine.subgraph.yaml
	@cd subgraph && npx graph build generated/solidity-statemachine.subgraph.yaml
	@eval $$(curl -H "x-auth-token: $${BTP_SERVICE_TOKEN}" -s $${BTP_CLUSTER_MANAGER_URL}/ide/foundry/$${BTP_SCS_ID}/env | sed 's/^/export /'); \
	if [ "$${BTP_MIDDLEWARE}" == "" ]; then \
		echo "You have not launched a graph middleware for this smart contract set, aborting..."; \
		exit 1; \
	else \
		cd subgraph; \
		npx graph create --node $${BTP_MIDDLEWARE} $${BTP_SCS_NAME}; \
		npx graph deploy --version-label v1.0.$$(date +%s) --node $${BTP_MIDDLEWARE} --ipfs $${BTP_IPFS}/api/v0 $${BTP_SCS_NAME} generated/solidity-statemachine.subgraph.yaml; \
	fi

help:
	@echo "Forge help..."
	@forge --help
	@echo "Anvil help..."
	@anvil --help
	@echo "Cast help..."
	@cast --help
