module algomove::auction_monomorphic {

    use algomove::asset::{ Self, Asset };
    use algomove::utils;

    struct Auction has key {
        auctioneer: address,
        top_bidder: address,
        expired: bool
    }

    struct Bid<Dollar> has key {
        assets: Asset<Dollar>
    }

    struct Dollar has store {
        amount: u64
    }

    public fun start_auction(acc: &signer, base: Asset<Dollar>) {
        let auctioneer = utils::address_of_signer(acc);
        let auction = Auction { auctioneer, top_bidder: auctioneer, expired: false };
        move_to(acc, auction);
        move_to(acc, Bid { assets: base });
    }

    public fun bid(acc: &signer, auctioneer: address, assets: Asset<Dollar>) acquires Auction, Bid {
        let auction = borrow_global_mut<Auction>(auctioneer);
        let Bid { assets: top_bid } = move_from<Bid<Dollar>>(auction.top_bidder);
        assert!(!auction.expired, 1);
        assert!(asset::value(&assets) > asset::value(&top_bid), 2);
        asset::deposit(auction.top_bidder, top_bid);
        auction.top_bidder = utils::address_of_signer(acc);
        move_to(acc, Bid { assets });
    }

    public fun finalize_auction(acc: &signer) acquires Auction, Bid {
        let auctioneer = utils::address_of_signer(acc);
        let auction = borrow_global_mut<Auction>(auctioneer);
        assert!(auctioneer == auction.auctioneer, 3);
        auction.expired = true;
        let Bid { assets: top_bid } = move_from<Bid<Dollar>>(auction.top_bidder);
        asset::deposit(auctioneer, top_bid);
    }

}