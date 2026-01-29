module algomove::auction_fast {

    use algomove::asset;
    use algomove::utils;

    struct Auction has key {
        auctioneer: address,
        top_bidder: address,
        top_bid: u64,
        expired: bool,
    }

    public fun start_auction<AssetType>(acc: &signer, base: u64) {
        let auctioneer = utils::address_of_signer(acc);
        let auction = Auction { auctioneer, top_bidder: auctioneer, expired: false, top_bid: base };
        move_to(acc, auction);
    }

    public fun bid<AssetType>(acc: &signer, auctioneer: address, amount: u64) acquires Auction {
        let auction = borrow_global_mut<Auction>(auctioneer);
        assert!(!auction.expired, 1);
        assert!(amount > auction.top_bid, 2);
        asset::transfer<AssetType>(acc, auction.top_bidder, auction.top_bid);
        auction.top_bidder = utils::address_of_signer(acc);
//        asset::transfer(acc, auction.top_bidder, auction.top_bid);
    }

    public fun finalize_auction<AssetType>(acc: &signer) acquires Auction {
        let auctioneer = utils::address_of_signer(acc);
        let auction = borrow_global_mut<Auction>(auctioneer);
        assert!(auctioneer == auction.auctioneer, 3);
        auction.expired = true;
  //      asset::transfer(auctioneer, top_bid);
    }


}