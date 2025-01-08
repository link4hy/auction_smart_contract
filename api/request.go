package main

type StartAuctionRequest struct {
    OpeningBid int64 `json:"opening_bid"`
    Duration   int64 `json:"duration"`
}

type BidRequest struct {
    Value int64 `json:"value"`
}
