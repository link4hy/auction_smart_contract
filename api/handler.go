package main

import (
    "math/big"
    "net/http"

    "github.com/ethereum/go-ethereum/accounts/abi/bind"
    "github.com/ethereum/go-ethereum/crypto"
    "github.com/gin-gonic/gin"
    "github.com/rs/zerolog/log"

    contract "api/auction"
)

type Handler struct {
    auction *contract.Auction
}

func NewHandler(auction *contract.Auction) *Handler {
    return &Handler{
        auction: auction,
    }
}

func txOpts(c *gin.Context) (*bind.TransactOpts, error) {
    privateKey, err := crypto.HexToECDSA(c.Request.Header["Key"][0])
    if err != nil {
        return nil, err
    }

    return bind.NewKeyedTransactorWithChainID(privateKey, big.NewInt(ChainID))
}

func (h *Handler) startAuction(c *gin.Context) {
    opts, err := txOpts(c)
    if err != nil {
        log.Err(err).Msg("Failed to create opts")
        c.String(http.StatusBadRequest, "invalid auth")
        return
    }

    var req StartAuctionRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.String(http.StatusBadRequest, "invalid request body")
        return
    }

    tx, err := h.auction.Start(opts, big.NewInt(req.OpeningBid), big.NewInt(req.Duration))
    if err != nil {
        log.Err(err).Msg("Error occurred while starting the auction")
        c.String(http.StatusInternalServerError, err.Error())
        return
    }

    c.String(http.StatusOK, tx.Hash().String())
}

func (h *Handler) endAuction(c *gin.Context) {
    opts, err := txOpts(c)
    if err != nil {
        log.Err(err).Msg("Failed to create txOpts")
        c.String(http.StatusBadRequest, "invalid auth")
        return
    }
    tx, err := h.auction.End(opts)
    if err != nil {
        log.Err(err).Msg("Error occurred while starting the auction")
        c.String(http.StatusInternalServerError, err.Error())
        return
    }

    c.String(http.StatusOK, tx.Hash().String())
}

func (h *Handler) withdraw(c *gin.Context) {
    opts, err := txOpts(c)
    if err != nil {
        log.Err(err).Msg("Failed to create txOpts")
        c.String(http.StatusBadRequest, "invalid auth")
        return
    }
    tx, err := h.auction.Withdraw(opts)
    if err != nil {
        log.Err(err).Msg("Error occurred while starting the auction")
        c.String(http.StatusInternalServerError, err.Error())
        return
    }

    c.String(http.StatusOK, tx.Hash().String())
}

func (h *Handler) createBid(c *gin.Context) {
    var req BidRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.String(http.StatusBadRequest, "invalid request body")
        return
    }

    opts, err := txOpts(c)
    if err != nil {
        log.Err(err).Msg("Failed to create txOpts")
        c.String(http.StatusBadRequest, "invalid auth")
        return
    }
    opts.Value = big.NewInt(req.Value)
    tx, err := h.auction.Bid(opts)
    if err != nil {
        log.Err(err).Msg("Error occurred while starting the auction")
        c.String(http.StatusInternalServerError, err.Error())
        return
    }
    c.String(http.StatusOK, tx.Hash().String())
}
