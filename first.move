module my_addrx::UpvoteGame
{
    use aptos_framework::coin;

    struct Coin has key { amount: u64 }

    struct Proposal has drop{
        name:vector<u8>,
        acc:address,
        upvotes:u64
    }

    fun get_wallet<CoinType>(y:u64,sender: &signer)
    {
        assert!(y>0,101);
        let _=std::signer::address_of(sender);

        let coins = coin::withdraw<CoinType>(sender, y);
        coin::deposit(@my_addrx, coins);
        move_to(sender, Coin { amount: y });
    }
    fun create_proposal(y:vector<u8>,sender: &signer){
        let addr=std::signer::address_of(sender);
        let proposal=Proposal{name:y,acc:addr,upvotes:0};
    }
    fun upvote_proposal(addr:address){
        
    }
}module my_addrx::UpvoteGame
{
    use aptos_framework::coin;

    struct Coin has key { amount: u64 }

    struct Proposal has drop{
        name:vector<u8>,
        acc:address,
        upvotes:u64
    }

    fun get_wallet<CoinType>(y:u64,sender: &signer)
    {
        assert!(y>0,101);
        let _=std::signer::address_of(sender);

        let coins = coin::withdraw<CoinType>(sender, y);
        coin::deposit(@my_addrx, coins);
        move_to(sender, Coin { amount: y });
    }
    fun create_proposal(y:vector<u8>,sender: &signer){
        let addr=std::signer::address_of(sender);
        let proposal=Proposal{name:y,acc:addr,upvotes:0};
    }
    fun upvote_proposal(addr:address){
        
    }
}