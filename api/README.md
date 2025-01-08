# How to run it


## prerequisites
1. Has the auction and NFT contract deployed.

## Run go app

1. update main.go

the ContractAddress is the address of Auction contract.

const (
	NodeURL         = "http://127.0.0.1:8545"
	ContractAddress = "9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"
	ChainID         = 31337
)

2. start app
> go run .

## call API

call go api
key is the privte key from anvil 
```
curl -H "key: <privte key>" -X POST --data '{"opening_bid": 1, "duration": 120}' localhost:8080/auction/start
```


call go api to bid
```
curl -H "key: <privte key>" -X POST --data '{"value": 6}' localhost:8080/bids
```
