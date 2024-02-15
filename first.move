module my_addrx::UpvoteGame{
    use std::signer;    
    use aptos_framework::account;
    use std::vector;
    use aptos_framework::managed_coin;
    use aptos_framework::coin;
    use aptos_std::type_info;
    use aptos_std::simple_map::{Self, SimpleMap};
    const Max_upvotes:u64=10;
    struct Wallet has key, store{
        coins:u64,
    }
    struct Proposal has store,copy,drop,key{
        name:vector<u8>,
        proposer:address,
        upvotes:u64,
        id:u64,
    }
    struct Proposals has key, store{
        proposals:vector<Proposal>,
    }
    public fun initialise_proposals(account: &signer){
        assert!(signer::address_of(account)==@my_addrx,0);
        if(!exists<Proposals>(@my_addrx)){
            move_to<Proposals>(account,Proposals{proposals: vector::empty<Proposal>()});
        };
    }
    fun coin_address<CoinType>(): address {
       let type_info = type_info::type_of<CoinType>();
       type_info::account_address(&type_info)
    }
    public fun get_wallet<CoinType>(account: &signer, value: u64){
        coin::transfer<CoinType>(account,@my_addrx,value);
        move_to(account, Wallet{ coins:value});
    }
    public fun create_proposal(given_name:vector<u8>, account: &signer):Proposal acquires Proposals{
        assert!(exists<Proposals>(@my_addrx),1);
        let oldlist= borrow_global_mut<Proposals>(@my_addrx);
        let n=vector::length<Proposal>(&oldlist.proposals);
        let new_proposal=Proposal{name:given_name, proposer:signer::address_of(account), upvotes:0, id:n};
        vector::push_back(&mut oldlist.proposals, new_proposal);
        new_proposal
    }
    public fun upvote_proposal(proposal:&Proposal, value:u64,account: &signer):u64 acquires Wallet, Proposals{
        let addr=signer::address_of(account);
        assert!(proposal.proposer!=addr,2);
        assert!(borrow_global<Wallet>(addr).coins>=value,3);
        let change=&mut borrow_global_mut<Wallet>(addr).coins;
        *change=*change-value;
        let oldlist=borrow_global_mut<Proposals>(@my_addrx);
        let inc_prop=&mut vector::borrow_mut<Proposal>(&mut oldlist.proposals, proposal.id).upvotes;
        *inc_prop=*inc_prop+value;
        if(*inc_prop>Max_upvotes){
            distribution(proposal.id);
        };
        value
    }
    fun distribution(id:u64)acquires Proposals{
        let oldlist= borrow_global_mut<Proposals>(@my_addrx);
        let n=vector::length<Proposal>(&oldlist.proposals);
        let to_winner=0;
        let to_dapp=0;
        while(n>0){
            let inc_prop=&mut vector::borrow_mut<Proposal>(&mut oldlist.proposals, n-1).upvotes;
            if(id==n-1){
                to_winner=to_winner+*inc_prop/2;
            };
            to_winner=to_winner+*inc_prop/2;
            to_dapp=to_dapp+*inc_prop/2;
            vector::pop_back(&mut oldlist.proposals);
            n=n-1;
        };
    }
}
