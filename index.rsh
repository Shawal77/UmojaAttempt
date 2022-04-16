'reach 0.1';
//'use strict';
//user interfaces
//introduce participants
export const main = Reach.App(()=>{
    const Auctioneer=Participant('Auctioneer',{
        bidFloor: UInt,
        deadline: UInt,
        seeBid: Fun([Address, UInt], Null),
    });
    const Bidder = API('Bidder',{
        amountBid:Fun([],UInt)
    });
    //init the app
    init();

    //Auctioneer tells us
    Auctioneer.only(()=>{
        const bidFloor=declassify(interact.bidFloor);
        const deadline=declassify(interact.deadline);
    })
    Auctioneer.publish( bidFloor, deadline );

    const prices=new Map(Address,UInt);
    prices[Auctioneer] = bidFloor;
    //parallel reduce to find WinnerBidder and the price they pay 
    const [isTimeOn,winnerBidder,amountToPay]=
    parallelReduce([ true, Auctioneer, bidFloor ])
      .invariant(balance=previousPrice)
      .while(isTimeOn)
      .api(Bidder.amountBid,
        ((amountBid)=>{
          require( amountBid > bidFloor, "bid is low" )
          prices[this] = amountBid;
          return [ true, this, price[-2]]
          Auctioneer.interact.seeBid(this,amountBid)
        })
      )
      .timeout(relativeTime(deadline), () => { 
        Anybody.publish();
        return [ false, winnerBidder, amountToPay ];
       });
    //transfer money to auctioneer from highest bidder
    transfer(amountToPay).to(Auctioneer);
    //Anounce the results
  commit();
  exit();
});

