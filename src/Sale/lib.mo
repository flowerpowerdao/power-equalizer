import Ledger "canister:ledger";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";
import Buffer "mo:base/Buffer";
import { isSome } "mo:base/Option";

import AviateAccountIdentifier "mo:accountid/AccountIdentifier";
import Root "mo:cap/Root";
import Fuzz "mo:fuzz";

import AID "../toniq-labs/util/AccountIdentifier";
import Env "../Env";
import Types "types";
import RootTypes "../types";
import Utils "../utils";

module {
  public class Factory(config : RootTypes.Config, deps : Types.Dependencies) {

    /*********
    * STATE *
    *********/

    var _saleTransactions = Buffer.Buffer<Types.SaleTransaction>(0);
    var _salesSettlements = TrieMap.TrieMap<Types.AccountIdentifier, Types.Sale>(AID.equal, AID.hash);
    var _failedSales = Buffer.Buffer<(Types.AccountIdentifier, Types.SubAccount)>(0);
    var _tokensForSale = Buffer.Buffer<Types.TokenIndex>(0);
    var _whitelist = Buffer.Buffer<(Nat64, Types.AccountIdentifier, Types.WhitelistSlot)>(0);
    var _soldIcp = 0 : Nat64;
    var _sold = 0 : Nat;
    var _totalToSell = 0 : Nat;
    var _nextSubAccount = 0 : Nat;

    public func getChunkCount(chunkSize : Nat) : Nat {
      var count: Nat = _saleTransactions.size() / chunkSize;
      if (_saleTransactions.size() % chunkSize != 0) {
        count += 1;
      };
      Nat.max(1, count);
    };

    public func toStableChunk(chunkSize : Nat, chunkIndex : Nat) : Types.StableChunk {
      let start = chunkSize * chunkIndex;
      let saleTransactionChunk = if (_saleTransactions.size() == 0) {
        []
      }
      else {
        Buffer.toArray(Buffer.subBuffer(_saleTransactions, start, Nat.min(chunkSize, _saleTransactions.size() - start)));
      };

      if (chunkIndex == 0) {
        ?#v1({
          saleTransactionCount = _saleTransactions.size();
          saleTransactionChunk;
          salesSettlements = Iter.toArray(_salesSettlements.entries());
          failedSales = Buffer.toArray(_failedSales);
          tokensForSale = Buffer.toArray(_tokensForSale);
          whitelist = Buffer.toArray(_whitelist);
          soldIcp = _soldIcp;
          sold = _sold;
          totalToSell = _totalToSell;
          nextSubAccount = _nextSubAccount;
        });
      }
      else if (chunkIndex <= getChunkCount(chunkSize)) {
        return ?#v1_chunk({ saleTransactionChunk });
      }
      else {
        null;
      };
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      switch (chunk) {
        case (?#v1(data)) {
          _saleTransactions := Buffer.Buffer<Types.SaleTransaction>(data.saleTransactionCount);
          _saleTransactions.append(Buffer.fromArray(data.saleTransactionChunk));
          _salesSettlements := TrieMap.fromEntries(data.salesSettlements.vals(), AID.equal, AID.hash);
          _failedSales := Buffer.fromArray<(Types.AccountIdentifier, Types.SubAccount)>(data.failedSales);
          _tokensForSale := Buffer.fromArray<Types.TokenIndex>(data.tokensForSale);
          _whitelist := Buffer.fromArray<(Nat64, Types.AccountIdentifier, Types.WhitelistSlot)>(data.whitelist);
          _soldIcp := data.soldIcp;
          _sold := data.sold;
          _totalToSell := data.totalToSell;
          _nextSubAccount := data.nextSubAccount;
        };
        case (?#v1_chunk(data)) {
          _saleTransactions.append(Buffer.fromArray(data.saleTransactionChunk));
        };
        case (null) {};
      };
    };

    public func grow(n : Nat) : Nat {
      let fuzz = Fuzz.Fuzz();

      for (i in Iter.range(1, n)) {
        _saleTransactions.add({
          tokens = [fuzz.nat32.random()];
          seller = fuzz.principal.randomPrincipal(10);
          price = fuzz.nat64.random();
          buyer = fuzz.text.randomAlphanumeric(32);
          time = fuzz.int.randomRange(1670000000000000000, 2670000000000000000);
        });
      };

      _saleTransactions.size();
    };

    // *** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    // updates
    public func initMint(caller : Principal) : Result.Result<(), Text> {
      assert (caller == config.minter);

      if (deps._Tokens.getNextTokenId() != 0) {
        return #err("already minted");
      };

      // Mint
      mintCollection(Env.collectionSize);

      // turn whitelist into buffer for better performance
      for (whitelistTier in Env.whitelistTiers.vals()) {
        appendWhitelist(whitelistTier.price, whitelistTier.whitelist, whitelistTier.slot);
      };

      // get initial token indices (this will return all tokens as all of them are owned by "0000")
      _tokensForSale := switch (deps._Tokens.getTokensFromOwner("0000")) {
        case (?t) t;
        case (_) Buffer.Buffer<Types.TokenIndex>(0);
      };

      return #ok;
    };

    public func shuffleTokensForSale(caller : Principal) : async () {
      assert (caller == config.minter and Nat32.toNat(Env.collectionSize) == _tokensForSale.size());
      // shuffle indices
      let seed : Blob = await Random.blob();
      _tokensForSale := deps._Shuffle.shuffleTokens(_tokensForSale, seed);
    };

    public func airdropTokens(caller : Principal, startingIndex : Nat) : () {
      assert (caller == config.minter and _totalToSell == 0);

      if (not Env.airdropEnabled) {
        return;
      };

      // airdrop tokens
      var temp = 0;
      label airdrop for (a in Env.airdrop.vals()) {
        if (temp < startingIndex) {
          temp += 1;
          continue airdrop;
        } else if (temp >= startingIndex +1500) {
          break airdrop;
        };
        // nextTokens() updates _tokensForSale, removing consumed tokens
        deps._Tokens.transferTokenToUser(nextTokens(1)[0], a);
        temp += 1;
      };
    };

    public func enableSale(caller : Principal) : Nat {
      assert (caller == config.minter and _totalToSell == 0);
      _totalToSell := _tokensForSale.size();
      _tokensForSale.size();
    };

    public func reserve(amount : Nat64, quantity : Nat64, address : Types.AccountIdentifier, _subaccountNOTUSED : Types.SubAccount) : Result.Result<(Types.AccountIdentifier, Nat64), Text> {
      if (Env.openEdition and Time.now() > Env.saleEnd) {
        return #err("The sale has ended");
      };
      if (Time.now() < Env.publicSaleStart) {
        return #err("The sale has not started yet");
      };
      if (isWhitelisted(address) == false) {
        if (Time.now() < Env.whitelistTime) {
          return #err("The public sale has not started yet");
        };
      };
      if (availableTokens() == 0) {
        return #err("No more NFTs available right now!");
      };
      if (availableTokens() < Nat64.toNat(quantity)) {
        return #err("Not enough NFTs available!");
      };
      var total : Nat64 = (getAddressPrice(address) * quantity);
      var bp = getAddressBulkPrice(address);
      var lastq : Nat64 = 1;
      // check the bulk prices available
      for (a in bp.vals()) {
        // if there is a precise match, the end price is in the bulk price tuple
        // and we can replace total
        if (a.0 == quantity) {
          total := a.1;
        };
        lastq := a.0;
      };
      // we check that no one can buy more than specified in the bulk prices
      if (quantity > lastq) {
        return #err("Quantity error");
      };
      if (total > amount) {
        return #err("Price mismatch!");
      };
      let subaccount = getNextSubAccount();
      let paymentAddress : Types.AccountIdentifier = AID.fromPrincipal(config.canister, ?subaccount);

      // we only reserve the tokens here, they deducted from the available tokens
      // after payment. otherwise someone could stall the sale by reserving all
      // the tokens without paying for them
      let tokens : [Types.TokenIndex] = tempNextTokens(quantity);
      _salesSettlements.put(
        paymentAddress,
        {
          tokens = tokens;
          price = total;
          subaccount = subaccount;
          buyer = address;
          expires = Time.now() + Env.escrowDelay;
          slot = getSlot(address);
        },
      );

      // remove address from whitelist
      if (Env.whitelistOneTimeOnly == true) {
        if (isWhitelisted(address)) {
          removeFromWhitelist(address);
        };
      };

      #ok((paymentAddress, total));
    };

    public func retrieve(caller : Principal, paymentaddress : Types.AccountIdentifier) : async Result.Result<(), Text> {
      if (Option.isNull(_salesSettlements.get(paymentaddress))) {
        return #err("Nothing to settle");
      };

      let response : Types.Tokens = await Ledger.account_balance({
        account = switch (AviateAccountIdentifier.fromText(paymentaddress)) {
          case (#ok(accountId)) {
            Blob.fromArray(AviateAccountIdentifier.addHash(accountId));
          };
          case (#err(_)) {
            // this should never happen because account ids are always created from within the
            // canister which should guarantee that they are valid and we are able to decode them
            // to [Nat8]
            return #err("Failed to decode payment address");
          };
        };
      });

      // because of the await above, we check again if there is a settlement available for the paymentaddress
      let settlement = switch (_salesSettlements.get(paymentaddress)) {
        case (?settlement) { settlement };
        case (null) {
          return #err("Nothing to settle");
        };
      };

      if (response.e8s >= settlement.price) {
        if (settlement.tokens.size() > availableTokens()) {
          // Issue refund if not enough NFTs available
          deps._Disburser.addDisbursement({
            to = settlement.buyer;
            fromSubaccount = settlement.subaccount;
            amount = response.e8s - 10000;
            tokenIndex = 0;
          });
          _salesSettlements.delete(paymentaddress);
          return #err("Not enough NFTs - a refund will be sent automatically very soon");
        } else {
          var tokens = nextTokens(Nat64.fromNat(settlement.tokens.size()));
          for (a in tokens.vals()) {
            deps._Tokens.transferTokenToUser(a, settlement.buyer);
          };
          _saleTransactions.add({
            tokens = tokens;
            seller = config.canister;
            price = settlement.price;
            buyer = settlement.buyer;
            time = Time.now();
          });
          _soldIcp += settlement.price;
          _sold += tokens.size();
          _salesSettlements.delete(paymentaddress);
          let event : Root.IndefiniteEvent = {
            operation = "mint";
            details = [
              ("to", #Text(settlement.buyer)),
              ("price_decimals", #U64(8)),
              ("price_currency", #Text("ICP")),
              ("price", #U64(settlement.price)),
              // there can only be one token in tokens due to the reserve function
              ("token_id", #Text(Utils.indexToIdentifier(settlement.tokens[0], config.canister))),
            ];
            caller;
          };
          ignore deps._Cap.insert(event);
          // Payout
          // remove total transaction fee from balance to be splitted
          let bal : Nat64 = response.e8s - (10000 * Nat64.fromNat(Env.salesDistribution.size()));

          // disbursement sales
          for (f in Env.salesDistribution.vals()) {
            var _fee : Nat64 = bal * f.1 / 100000;
            deps._Disburser.addDisbursement({
              to = f.0;
              fromSubaccount = settlement.subaccount;
              amount = _fee;
              tokenIndex = 0;
            });
          };
          return #ok();
        };
      } else {
        // if the settlement expired and they still didnt send the full amount, we add them to failedSales
        if (settlement.expires < Time.now()) {
          _failedSales.add((settlement.buyer, settlement.subaccount));
          _salesSettlements.delete(paymentaddress);

          // add back to whitelist
          if (Env.whitelistOneTimeOnly and isSome(settlement.slot)) {
            ignore do ? {
              addToWhitelist(settlement.price, settlement.buyer, settlement.slot!);
            };
          };
          return #err("Expired");
        } else {
          return #err("Insufficient funds sent");
        };
      };
    };

    public func cronSalesSettlements(caller : Principal) : async () {
      // _saleSattlements can potentially be really big, we have to make sure
      // we dont get out of cycles error or error that outgoing calls queue is full.
      // This is done by adding the await statement.
      // For every message the max cycles is reset
      label settleLoop while (true) {
        switch (expiredSalesSettlements().keys().next()) {
          case (?paymentAddress) {
            try {
              ignore (await retrieve(caller, paymentAddress));
            } catch (e) {};
          };
          case null break settleLoop;
        };
      };
    };

    public func cronFailedSales() : async () {
      label failedSalesLoop while (true) {
        let last = _failedSales.removeLast();
        switch (last) {
          case (?failedSale) {
            let subaccount = failedSale.1;
            try {
              // check if subaccount holds icp
              let response : Types.Tokens = await Ledger.account_balance({
                account = Blob.fromArray(AviateAccountIdentifier.addHash(AviateAccountIdentifier.fromPrincipal(config.canister, ?subaccount)));
              });
              if (response.e8s > 10000) {
                var bh = await Ledger.transfer({
                  memo = 0;
                  amount = { e8s = response.e8s - 10000 };
                  fee = { e8s = 10000 };
                  from_subaccount = ?Blob.fromArray(subaccount);
                  to = switch (AviateAccountIdentifier.fromText(failedSale.0)) {
                    case (#ok(accountId)) {
                      Blob.fromArray(AviateAccountIdentifier.addHash(accountId));
                    };
                    case (#err(_)) {
                      // this should never happen because account ids are always created from within the
                      // canister which should guarantee that they are valid and we are able to decode them
                      // to [Nat8]
                      continue failedSalesLoop;
                    };
                  };
                  created_at_time = null;
                });
              };
            } catch (e) {
              // if the transaction fails for some reason, we add it back to the Buffer
              _failedSales.add(failedSale);
            };
          };
          case (null) {
            break failedSalesLoop;
          };
        };
      };
    };

    public func getNextSubAccount() : Types.SubAccount {
      var _saOffset = 4294967296;
      _nextSubAccount += 1;
      return Utils.natToSubAccount(_saOffset +_nextSubAccount);
    };

    // queries
    public func salesSettlements() : [(Types.AccountIdentifier, Types.Sale)] {
      Iter.toArray(_salesSettlements.entries());
    };

    public func failedSales() : [(Types.AccountIdentifier, Types.SubAccount)] {
      Buffer.toArray(_failedSales);
    };

    public func saleTransactions() : [Types.SaleTransaction] {
      Buffer.toArray(_saleTransactions);
    };

    public func getSold() : Nat {
      _sold;
    };

    public func getTotalToSell() : Nat {
      _totalToSell;
    };

    public func salesSettings(address : Types.AccountIdentifier) : Types.SaleSettings {
      var startTime = Env.whitelistTime;
      var endTime: Int = Env.saleEnd;
      // for whitelisted user return nearest and cheapest slot start time
      label l for (item in _whitelist.vals()) {
        if (item.1 == address and Time.now() <= item.2.end) {
          startTime := item.2.start;
          endTime := item.2.end;
          break l;
        };
      };

      return {
        price = getAddressPrice(address);
        salePrice = Env.salePrice;
        remaining = availableTokens();
        sold = _sold;
        totalToSell = _totalToSell;
        startTime = startTime;
        endTime = endTime;
        whitelistTime = Env.whitelistTime;
        whitelist = isWhitelisted(address);
        bulkPricing = getAddressBulkPrice(address);
        openEdition = Env.openEdition;
      } : Types.SaleSettings;
    };

    /*******************
    * INTERNAL METHODS *
    *******************/

    // getters & setters
    public func availableTokens() : Nat {
      if (Env.openEdition) {
        return 1;
      };
      _tokensForSale.size();
    };

    public func soldIcp() : Nat64 {
      _soldIcp;
    };

    // internals
    func tempNextTokens(qty : Nat64) : [Types.TokenIndex] {
      Array.freeze(Array.init<Types.TokenIndex>(Nat64.toNat(qty), 0));
    };

    func getAddressPrice(address : Types.AccountIdentifier) : Nat64 {
      getAddressBulkPrice(address)[0].1;
    };

    // Set different price types here
    func getAddressBulkPrice(address : Types.AccountIdentifier) : [(Nat64, Nat64)] {
      if (Env.dutchAuctionEnabled) {
        // dutch auction for everyone
        let everyone = Env.dutchAuctionFor == #everyone;
        // dutch auction for whitelist (tier price is ignored), then salePrice for public sale
        let whitelist = Env.dutchAuctionFor == #whitelist and isWhitelisted(address);
        // tier price for whitelist, then dutch auction for public sale
        let publicSale = Env.dutchAuctionFor == #publicSale and not isWhitelisted(address);

        if (everyone or whitelist or publicSale) {
          return [(1, getCurrentDutchAuctionPrice())];
        };
      };

      // we have to make sure to only return prices that are available in the current whitelist slot
      // if i had a wl in the first slot, but now we are in slot 2, i should not be able to buy at the price of slot 1

      // this method assumes the wl prices are added in ascending order, so the cheapest wl price in the earliest slot
      // is always the first one.
      for (item in _whitelist.vals()) {
        if (item.1 == address and Time.now() <= item.2.end) {
          return [(1, item.0)];
        };
      };

      return [(1, Env.salePrice)];
    };

    func getCurrentDutchAuctionPrice() : Nat64 {
      let start = if (Env.dutchAuctionFor == #publicSale) {
        // if the dutch auction is for public sale only, we take the start time when the whitelist time has expired
        Env.whitelistTime;
      } else {
        Env.publicSaleStart;
      };
      let timeSinceStart : Int = Time.now() - start; // how many nano seconds passed since the auction began
      // in the event that this function is called before the auction has started, return the starting price
      if (timeSinceStart < 0) {
        return Env.dutchAuctionStartPrice;
      };
      let priceInterval = timeSinceStart / Env.dutchAuctionInterval; // how many intervals passed since the auction began
      // what is the discount from the start price in this interval
      let discount = Nat64.fromIntWrap(priceInterval) * Env.dutchAuctionIntervalPriceDrop;
      // to prevent trapping, we check if the start price is bigger than the discount
      if (Env.dutchAuctionStartPrice > discount) {
        return Env.dutchAuctionStartPrice - discount;
      } else {
        return Env.dutchAuctionReservePrice;
      };
    };

    func nextTokens(qty : Nat64) : [Types.TokenIndex] {
      if (Env.openEdition) {
        deps._Tokens.mintNextToken();
        _tokensForSale := switch (deps._Tokens.getTokensFromOwner("0000")) {
          case (?t) t;
          case (_) Buffer.Buffer<Types.TokenIndex>(0);
        };
      };

      if (_tokensForSale.size() >= Nat64.toNat(qty)) {
        var ret : List.List<Types.TokenIndex> = List.nil();
        while (List.size(ret) < Nat64.toNat(qty)) {
          switch (_tokensForSale.removeLast()) {
            case (?token) {
              ret := List.push(token, ret);
            };
            case _ return [];
          };
        };
        List.toArray(ret);
      } else {
        [];
      };
    };

    public func appendWhitelist(price : Nat64, addresses : [Types.AccountIdentifier], slot : Types.WhitelistSlot) {
      let buffer = Buffer.Buffer<(Nat64, Types.AccountIdentifier, Types.WhitelistSlot)>(addresses.size());
      for (address in addresses.vals()) {
        buffer.add((price, address, slot));
      };
      _whitelist.append(buffer);
    };

    // this method is timesensitive now and only returns true, iff the address is whitelist
    // in the current slot
    func isWhitelisted(address : Types.AccountIdentifier) : Bool {
      if (Env.whitelistDiscountLimited == true and Time.now() >= Env.whitelistTime) {
        return false;
      };
      for (element in _whitelist.vals()) {
        if (element.1 == address and Time.now() >= element.2.start and Time.now() <= element.2.end) {
          return true;
        };
      };
      return false;
    };

    func getSlot(address : Types.AccountIdentifier) : ?Types.WhitelistSlot {
      if (Env.whitelistDiscountLimited == true and Time.now() >= Env.whitelistTime) {
        return null;
      };
      for (element in _whitelist.vals()) {
        if (element.1 == address and Time.now() >= element.2.start and Time.now() <= element.2.end) {
          return ?element.2;
        };
      };
      return null;
    };

    // remove first occurrence from whitelist
    // when removing, we have to make sure we remove the correct whitelist spot in the correct slot
    // could be that there is an unused wl spot from an earlier slot in the list
    func removeFromWhitelist(address : Types.AccountIdentifier) : () {
      var found : Bool = false;
      _whitelist.filterEntries(
        func(_, a) : Bool {
          if (found) {
            return true;
          } else {
            if (a.1 != address) {
              return true;
            };
            // if there are whitelist spots from slots that are not active anymore, remove them
            // without stopping the loop to decrease cost
            if (a.2.end < Time.now()) {
              return false;
            };
            found := true;
            return false;
          };
        },
      );
    };

    func addToWhitelist(price : Nat64, address : Types.AccountIdentifier, slot : Types.WhitelistSlot) : () {
      _whitelist.add((price, address, slot));
    };

    func mintCollection(collectionSize : Nat32) {
      deps._Tokens.mintCollection(collectionSize);
    };

    func expiredSalesSettlements() : TrieMap.TrieMap<Types.AccountIdentifier, Types.Sale> {
      TrieMap.mapFilter<Types.AccountIdentifier, Types.Sale, Types.Sale>(
        _salesSettlements,
        AID.equal,
        AID.hash,
        func(a : (Types.AccountIdentifier, Types.Sale)) : ?Types.Sale {
          switch (a.1.expires < Time.now()) {
            case (true) {
              ?a.1;
            };
            case (false) {
              null;
            };
          };
        },
      );
    };
  };
};
