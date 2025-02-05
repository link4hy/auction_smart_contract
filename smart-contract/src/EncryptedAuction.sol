// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@fhevm/lib/TFHE.sol";
import  { SepoliaZamaFHEVMConfig } "@fhevm/config/ZamaFHEVMConfig.sol";


contract EncryptedAuction {
    // events
    event Start(uint startTime, uint endTime);
    event Bid(address indexed bidder, uint value);
    // event End(??);  //TODO
    event Withdraw(address indexed bidder, uint value);

    // auction state
    bool public started;
    bool public ended;
    uint public endTime;

    // mapping(address => Bid) public allBids;
    Bid[] public allBids;
    // Bid[] public allBids_settled;

    struct Bid {
        address bidder;
        uint amount;
        uint price;
        uint unitPrice;
        uint bidTime;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call the function");
        _;
    }

    // for constructor
    address payable public immutable owner;
    uint public immutable amount;
    ERC20 public immutable nft;

    constructor(address _nft, uint _amount) {
        // init values
        // owner and NFT
        owner = payable(msg.sender);
        nft = ERC20(_nft);
        nftId = _amount;
    }

    function bid(uint _amount) external payable {
        // validations
        require(started, "Auction has not started");
        require(block.timestamp < endTime, "Auction has ended");

        allBids.push({
            bidder: msg.sender,
            amount: _amount,
            price: msg.value,
            unitPrice: msg.value / _amount,
            bidTime: block.timestamp
        });

        // allBids[msg.sender] = Bid({amount: _amount, price: msg.value});

        emit Bid(msg.sender, msg.value);
    }

    function start(uint _openingBid, uint _duration) external onlyOwner {
        // validations
        require(!started, "Auction has already started");

        nft.transferFrom(owner, address(this), amount);

        started = true;
        endTime = block.timestamp + _duration;

        emit Start(block.timestamp, endTime);
    }

    function end() external onlyOwner {
        // validations
        require(started, "Auction has not started");
        require(block.timestamp >= endTime, "Auction has not ended");
        require(!ended, "Auction has already ended");

        ended = true;

        allocateNFT();

        //TODO
        // emit End(??);
    }

    function withdraw() external {
        
        // bider can't withdraw money during auction progress.
        require(!started, "Auction has started");

        // bidder to receive fund from the all bids state
        uint price_withdrawed;

        for (uint i = 0; i < allBids.length; i++) {
            if(msg.sender == allBids[i].bidder ){
                payable(msg.sender).transfer(allBids[i].price);
                price_withdrawed += allBids[i].price;
                remove(i);
            }
        }
        emit Withdraw(msg.sender, price_withdrawed);
    }


    //NFT owner get the money, bidders get the NFT
    function allocateNFT() internal {
        sortBids();

        uint remain = amount;

        for (uint i = 0; i < allBids.length; i++) {
            if (remain <= 0) return;

            if(remain > allBids[i].amount){
                nft.transferFrom(address(this), allBids[i].bidder, allBids[i].amount);
                owner.transfer(allBids[i].price);

                allBids[i].amount = 0;
                allBids[i].price = 0;
                allBids[i].unitPrice = 0;
            } else {
                nft.transferFrom(address(this), allBids[i].bidder, remain);
                owner.transfer(allBids[i].unitPrice * remain);

                allBids[i].amount = allBids[i].amount - remain; //bidder still need bid this amount of NFT.
                allBids[i].price = allBids[i].price - allBids[i].unitPrice * remain;
                // allBids[i].unitPrice = 0;
            } 
        }
    }

    function sortBids() internal {
        for (uint i = 0; i < allBids.length; i++) {
            for (uint j = i + 1; j < allBids.length; j++) {
                if (
                    allBids[i].unitPrice < allBids[j].unitPrice ||
                    allBids[i].amount < allBids[j].amount ||
                    allBids[i].amount > allBids[j].bidTime
                ) {
                    //SWAP element i and j
                    //Not sure if it works or not, need test it.
                    Bid _bid = allBids[i];
                    allBids[i] = allBids[j];
                    allBids[j] = _bid;
                }
            }
        }
    }

    function removeBid(uint256 index) internal {
        if (index >= allBids.length) return;

        for (uint i = index; i<allBids.length-1; i++){
            allBids[i] = allBids[i+1];
        }
        allBids.pop();
    }

}
