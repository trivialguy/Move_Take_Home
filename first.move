module my_addrx::UpvoteGame
{
    use aptos_framework::coin;
    use std::vector;
    const Max_Upvotes:u64=10;
    struct Coin has key,store,drop { amount: u64 }

    struct Proposal has store,key,drop,copy{
        name:vector<u8>,
        acc:address,
        upvotes:u64
    }
    struct Proposals has store,key,drop,copy{
        proposal:vector<Proposal>
    }
    public fun get_wallet<CoinType>(y:u64,sender: &signer)
    {
        assert!(y>0,0);
        let _=std::signer::address_of(sender);

        let coins = coin::withdraw<CoinType>(sender, y);
        coin::deposit(@my_addrx, coins);
        move_to(sender, Coin { amount: y });
    }
    public fun create_proposal(y:vector<u8>,sender: &signer,proposals: &mut Proposals): Proposal{
        let addr=std::signer::address_of(sender);
        let proposal=Proposal{name:y,acc:addr,upvotes:0};
        return proposal
    }
    public fun add_proposal(proposal:Proposal, proposals: &mut Proposals){
        vector::push_back(&mut proposals.proposal, proposal);
    }
    public fun upvote_proposal(s: &mut Proposal,z:u64, account: &signer, proposals: &mut Proposals){
        let addr=std::signer::address_of(account);
        assert!(s.acc!=addr,0);
        s.upvotes=s.upvotes+z;
        let balance = &mut borrow_global_mut<Coin>(std::signer::address_of(account)).amount;
        *balance = *balance - z;
        Coin { amount:z };
        if(s.upvotes>=Max_Upvotes){
            distribution(s,proposals);
        }
    }

    fun distribution(s: &mut Proposal, proposals: &mut Proposals): u64{
        // assert!(std::signer::address_of(account)==@my_addrx,0);
        let i=0;
        let n=vector::length(&proposals.proposal);
        let res=s.upvotes/2;
        while( i < n ){
            res=res+vector::borrow_mut(&mut proposals.proposal,n-i-1).upvotes/2;
            vector::pop_back(&mut proposals.proposal);
            i=i+1;
        };
        
        return res
    }

    #[test]
    fun testing(sender: &signer)
    {
        get_wallet(1,sender);
    }
}
