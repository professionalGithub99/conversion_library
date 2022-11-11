import Hex "../Hex";
import Account "../Account";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Blob "mo:base/Blob";
import Ledger "canister:ledger";
actor {
public type Result<Ok,Err> = Result.Result<Ok, Err>;
public type DecodeError = Hex.DecodeError;


public shared({caller}) func accountIdentifier():async Account.AccountIdentifier {
  return Account.accountIdentifier(caller,Account.defaultSubaccount());
};

public shared({caller}) func accountIdTextToNat8Array(accountIdText:Text):async Result<[Nat8],DecodeError> {
  return Hex.decode(accountIdText);
};

public shared({caller}) func accountIdNat8ArrayToText(accountIdNat8Array:[Nat8]):async Text {
  return Hex.encode(accountIdNat8Array);
};

// This function iterates through pairs of characters in the text string, converts the char pair to the decimal value of the hex it represents and then converts that value to a Nat8 decimal, i.e. 12 = 18, 0a = 10, 61 = 97. It then puts that decimal value into a nat8 Array. An example inputting 120a35 = a nat8 vector of values [12 = 18, 0a = 10, 30 = 48]. Note these steps are abstracted away in Hex.decode. The return values printed when calling in terminal are shown as the hex for each blob/Nat8Array element. I.e. for [12,0a] we get "\12\0a". There is a special case of char pairs I left out. It seems if the char pair has an ascii character with the decimal value of it (the common ones A-Z,a-z, 0-9, and a few more), i.e. 35 = "\35" = '0', then what is shown in the blob is 0. So 120a35 = [12 = 18, 0a = 10, 30 = 48 ='0'] = "\12\0a\0"
//note, ascii chars made of multiple char pairs will not be outputted as a char like the € will be outputted as \e2\82\ac, due to the way Hex.Decode works. See the inner workings if you must.
// note this function requires you to have chars that fit hex digits and that the string is even in length

  public query func textToNat8Array(_text: Text) : async Result<[Nat8],DecodeError> {
    return Hex.decode(_text);
  };

//This function iterates through pairs of characters in the text string, converts the character to the respective ascii decimal value. I.e. "a\\5€" gives a = 97, \ = 92, 5 = 53, € = 14844588. It then puts that ascii decimal value into a Nat8 Array [a = 97 = \61, \ = 92 = \5c , 5 = 53 =\83,€ = 14844588 = \e2\82\ac] (note the third equal has hex in it just for mapping in your head) and spits out the hex value of the character if the decimal of that character DOES NOT map to a common character I think 1-127 the a-z, A-Z 0-9. If the output hex/its decimal value maps to one of the common characters then that character is displayed instead. The total output is "a\5c5\e2\82\ac".
//€ and \ are not common characters withhex values of \5c and \e2\82\ac respectively so you see them outputted as the hex values while a and 5 are just the characters themselves. 
  public query func textToBlobUtf8Encode(_text: Text) : async Blob {
    return Text.encodeUtf8(_text);
  };
  public func blobToNat8Array(_blob: Blob) : async [Nat8] {
    return Blob.toArray(_blob);
  };
  public func nat8ArrayToBlob(_nat8Array: [Nat8]) : async Blob {
    return Blob.fromArray(_nat8Array);
  };


//BlobToText and Nat8ArrayToText are the same function essentially since candid and nat8 and blob types. 
//This function(s) is essentially opposite of TextToNat8Array. It It takes a blob and iterates through each element, either as a \<charpair as hex> or an individual char. It takes that char or \<charpair as hex> and converts it into a decimal. For each decimal, it converts that number into hexidecimal. And then concatenates the first and second digit of that hex into a string. It does that for every \<charpair as hex> and individual char in the blob.
  public func blobToText(_blob: Blob) : async Text {
    for(vals in Blob.toArray(_blob).vals()){
      Debug.print("vals "#debug_show(vals)#"\n");
    };
    return Hex.encode(Blob.toArray(_blob));
  };
  public func nat8ArrayToText(_nat8Array: [Nat8]) : async Text {
    for(vals in _nat8Array.vals()){
      Debug.print("vals "#debug_show(vals)#"\n");
    };
    return Hex.encode(_nat8Array);
  };


  //This function is essentially the opposite of the encodeutf8. It takes a blob and iterates through each element, either as a \<charpair as hex> or an individual char. It takes that char or \<charpair as hex> and converts it into a decimal. I.e. blob "\67\\\5c\e2\82\ac€" has decimals of \67 = 103 \\ = 92, \5c = 92, \e2\82\ac = 14844588, € = 14844588. It then finds the the text char with that decimal and spits it out. If there is no char fitting that value you just get a null. For this output you get \67 = 103 = g, \\ = 92 = \\ (note it actaully only equals one \ but the escape char), \5c = 92 = \\ (same here since \5c is the \\ char and you get same output), \e2\82\ac = 14844588 = €, € = 14844588 = €. Our final output is a text of all the chars after the 2nd equal signs "g\\\\€€"
  public func blobToTextUtf8Decode(_blob: Blob) : async ?Text {
    return Text.decodeUtf8(_blob);
  };
};
