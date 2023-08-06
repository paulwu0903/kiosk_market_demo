module kiosk_market_demo::market{
    //import module
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap, PurchaseCap};
    use sui::object::{ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{Self};
    use sui::sui::{SUI};
    use sui::coin::{Self, Coin};
    use std::option::{Self,};
    use sui::transfer_policy::{Self, TransferPolicy};

    const PRICE: u64 = 10000;
    const EBalanceNtEnough: u64 = 0;

    // create a kiosk market place
    public entry fun create_market(ctx: &mut TxContext){
        let (kiosk, kiosk_cap) = kiosk::new(ctx);

        transfer::public_transfer(kiosk_cap, tx_context::sender(ctx));
        transfer::public_share_object(kiosk);
    }

    // place nft to market place, but not to sale.
    public entry fun place_nft<T: key + store>(
        kiosk_obj: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        nft: T, 
    ){
        kiosk::place<T>(kiosk_obj, kiosk_cap, nft);
    }

    // let placed/locked nft to sale
    public entry fun list_nft<T: key + store>(
        kiosk_obj: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        id: ID,
        price: u64, ){
        
        kiosk::list<T>(kiosk_obj, kiosk_cap, id, price, );
    }

    // withdraw the balance of kiosk
    public entry fun withdraw_rewards(
        kiosk_obj: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        ctx: &mut TxContext,
    ){
        let none = option::none<u64>();
        let rewards = kiosk::withdraw(kiosk_obj, kiosk_cap, none, ctx);
        transfer::public_transfer(rewards, tx_context::sender(ctx));
    }

    // let placed/locked nft to sale with purchase_cap
    public entry fun list_nft_with_purchase_cap<T: key + store>(
        kiosk_obj: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        id: ID,
        min_price: u64, 
        ctx: &mut TxContext
    ){
        let purchase_cap = kiosk::list_with_purchase_cap<T>(
            kiosk_obj,
            kiosk_cap,
            id,
            min_price,
            ctx,
        );

        transfer::public_transfer(purchase_cap, tx_context::sender(ctx));
    }
    // get back the place nft
    public entry fun take_nft<T: store + key>(
        kiosk_obj: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        id: ID,
        ctx: &mut TxContext
    ){
        let nft = kiosk::take<T>(
            kiosk_obj,
            kiosk_cap,
            id,
        );

        transfer::public_transfer(nft, tx_context::sender(ctx));
    }
    // delist the nft, then nft can not be bought
    public entry fun delist_nft<T: store + key>(
        kiosk_obj: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        id: ID,
    ){
        kiosk::delist<T>(
            kiosk_obj,
            kiosk_cap,
            id,
        );
    }

    // 
    public entry fun purchase_nft<T: store + key>(
        kiosk_obj: &mut Kiosk,
        policy: &mut TransferPolicy<T>,
        id: ID,
        payments: Coin<SUI>,
        ctx: &mut TxContext,
    ){
        let (nft, transfer_req) = kiosk::purchase<T>(
            kiosk_obj,
            id,
            payments,
        );

        transfer_policy::confirm_request(policy, transfer_req);
        transfer::public_transfer(nft, tx_context::sender(ctx));

    }

    public entry fun purchase_nft_with_cap<T: store + key>(
        kiosk_obj: &mut Kiosk,
        purchase_cap: PurchaseCap<T>,
        policy: &mut TransferPolicy<T>,
        payments: Coin<SUI>,
        ctx: &mut TxContext,
    ){
        
        let min_price = kiosk::purchase_cap_min_price(&purchase_cap);
        assert!( coin::value(&payments) >= min_price, EBalanceNtEnough);

        let (nft, transfer_req) = kiosk::purchase_with_cap(
            kiosk_obj,
            purchase_cap,
            payments,
        );

        transfer_policy::confirm_request(policy, transfer_req);

        transfer::public_transfer(nft, tx_context::sender(ctx));

    }
}