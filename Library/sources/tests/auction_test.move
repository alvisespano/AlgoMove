module algomove::auction_test {

	use algomove::auction_with_item as au;
	use algomove::asset::{Self};

	struct EUR {}

	struct Car has store {
		name: vector<u8>,
		power: u64
	}

	struct Prize has key {
		car: Car
	}

	public entry fun start(acc: &signer) {
		let item = Car { name: b"Golf8", power: 160 };
		let base = asset::withdraw<EUR>(acc, 20000);
        au::start_auction(acc, base, item);
    }

	public entry fun finalize(acc: &signer) {
		au::finalize_auction<EUR, Car>(acc)
	}

	public entry fun bidder(acc: &signer, auc: address) {
		let amt = 20001;	
		while (amt < 30000) {
			let a = asset::withdraw<EUR>(acc, amt);
			au::bid<EUR, Car>(acc, auc, a);
			amt = amt + 1000;
		};
		let car = au::retrieve_prize<EUR, Car>(acc, auc);
		move_to(acc, Prize { car });
	}
	
}