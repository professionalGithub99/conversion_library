import Principal "mo:base/Principal";
import Map "mo:hashmap/Map";
module{
  let {phash} = Map;
    public type HashUtils<K> = Map.HashUtils<K>;
    public func remove_or_put<K, V>(isZero: (V) -> Bool, map: Map.Map<K, V>, hashUtils: HashUtils<K>, keyParam: K,_value:V):?V{
    if(isZero(_value) == false){
      return Map.put(map,hashUtils,keyParam,_value);
    }
    else{
      return Map.remove(map,hashUtils,keyParam);
    };
  };
  public func isZeroNat64(value:Nat64):Bool{
    return (value == 0);
  };
};

