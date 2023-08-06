module kiosk_market_demo::nft{
    //import module
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{Self};
    use sui::sui::{SUI};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::package;
    use sui::transfer_policy::{Self};
    use std::string::{utf8};
    use sui::display::{Self};

    const PRICE: u64 = 10000;
    const EBalanceNtEnough: u64 = 0;

    // counter
    struct Counter has store, key{
        id: UID,
        counter: u64,
    }

    // otw
    struct NFT has drop{}

    // NFT Object
    struct StudentNFT has key, store {
        id: UID,
        name: vector<u8>,
        image_url: vector<u8>,
        tag: u64,
    }

    //nft rewards collector
    struct Nft_fund has key{
        id: UID,
        balance: Balance<SUI>,
    }

    #[allow(unused_function)]
    fun init (witness: NFT, ctx: &mut TxContext){

        let publisher = package::claim(witness, ctx);
        
        // create transfer policy for NFT
        let (policy, cap) = transfer_policy::new<StudentNFT>(&publisher, ctx);
        transfer::public_share_object(policy);
        transfer::public_transfer(cap, tx_context::sender(ctx));

        // set NFT metadata to Display object
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            utf8(b"Paul"),
            utf8(b"https://drive.google.com/file/d/1iDc_JcnAkMbDdhMhJpg3GUIOOk8bigG4/view?usp=sharing"),
            utf8(b"https://drive.google.com/file/d/1iDc_JcnAkMbDdhMhJpg3GUIOOk8bigG4/view?usp=sharing"),
            utf8(b"A true Hero of the Sui ecosystem!"),
            utf8(b"https://drive.google.com/file/d/1iDc_JcnAkMbDdhMhJpg3GUIOOk8bigG4/view?usp=sharing"),
            utf8(b"Paul")
        ];

        // create Display object
        let display = display::new_with_fields<StudentNFT>(
            &publisher,
            keys,
            values,
            ctx,
        );
        // update_vesion function can active the settings.
        display::update_version(&mut display);

        transfer::public_share_object(display);

        // NFT tag
        let counter = Counter{
            id: object::new(ctx),
            counter: 0
        };
        
        let nft_fund = Nft_fund{
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
        };

        transfer::share_object(nft_fund);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_share_object(counter);
    }

    public entry fun transfer_nft(
        nft: StudentNFT,
        to: address,
    ){
        transfer::public_transfer(nft, to);
    }

    public entry fun mint_nft(
        nft_fund: &mut Nft_fund, 
        counter: &mut Counter, 
        payment: Coin<SUI>, 
        ctx: &mut TxContext
    ){
        assert!(coin::value(&payment) == PRICE, EBalanceNtEnough);
        
        let payment_balance = coin::into_balance<SUI>(payment);
        balance::join<SUI>(&mut nft_fund.balance, payment_balance);

        let nft = StudentNFT{
            id: object::new(ctx),
            name: b"SUI Builder Student",
            image_url: b"",
            tag: counter.counter,
        };

        counter.counter = counter.counter +1 ;
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

}