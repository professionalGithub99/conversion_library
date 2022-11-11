import CRC32     "./CRC32";
import SHA224    "./SHA224";
import Ledger "canister:ledger";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module 
{       
public type AccountIdentifier = Ledger.AccountIdentifier;
public type SubAccount = Ledger.SubAccount;
  public func beBytes(n:Nat32):[Nat8] {
        func byte(n : Nat32) : Nat8 {
      Nat8.fromNat(Nat32.toNat(n & 0xff))
    };
    [byte(n >> 24), byte(n >> 16), byte(n >> 8), byte(n)]
  };
  public func defaultSubaccount() : SubAccount {
    Blob.fromArrayMut(Array.init(32, 0 : Nat8))
  };

  public func accountIdentifier(principal: Principal, subaccount:SubAccount):AccountIdentifier{
    //account identifier account_identifier(principal,subaccount_identifier) = CRC32(h) || h
    //h = sha224(“\x0Aaccount-id” || principal || subaccount_identifier)

    let hash = SHA224.Digest();  
    hash.write([0x0A]);    
    hash.write(Blob.toArray(Text.encodeUtf8("account-id")));
    hash.write(Blob.toArray(Principal.toBlob(principal)));
    hash.write(Blob.toArray(subaccount));
    let hashSum = hash.sum();
    let crc32Bytes = beBytes(CRC32.ofArray(hashSum));
    return Blob.fromArray(Array.append(crc32Bytes,hashSum));
  };    

    public func blobToSubaccount(blob: Blob) : Blob {
    let idHash = SHA224.Digest();
    idHash.write(Blob.toArray(blob));
    let hashSum = idHash.sum();
    let crc32Bytes = beBytes(CRC32.ofArray(hashSum));
    let buf = Buffer.Buffer<Nat8>(32);
    Blob.fromArray(Array.append(crc32Bytes, hashSum));
  };

  public func principalToBlob(principal:Principal):Blob{
    return Principal.toBlob(principal);
  };

  
};
