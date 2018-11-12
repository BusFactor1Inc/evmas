contract=$(./deploy.sh 0xdd07385605770bB40cB39CC90c32068a6a2bd383 examples/erc20/abi.json < examples/erc20/erc20.evm)

node examples/erc20/testErc20.js 0xdd07385605770bB40cB39CC90c32068a6a2bd383 $contract examples/erc20/abi.json
