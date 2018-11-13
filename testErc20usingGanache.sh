account=0xdd07385605770bB40cB39CC90c32068a6a2bd383
destAccount=0x43D6D0611b9C065Ffa2b1038F599B912DCD35139

contract=$(./deploy.sh $account examples/erc20/abi.json < examples/erc20/erc20.evm)

node examples/erc20/testErc20.js $account $destAccount $contract examples/erc20/abi.json
