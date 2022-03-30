import Array "mo:base/Array";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

actor {
    // quickSort
    func qSort(arr : [var Int], l : Nat, r : Nat){
        if (l >= r) return;
        var q = arr[l]; var i = l; var j = r;
        while(i < j){
            while (i < j and arr[j] >= q) j -= 1;
            arr[i] := arr[j];
            while (i < j and arr[i] <= q) i += 1;
            arr[j] := arr[i];
        };
        arr[j] := q;
        if(i >= 1) qSort(arr, l, i - 1);
        qSort(arr, i + 1, r);
    };

    public func quickSort(arr : [Int]) : async [Int] {
        var newArr : [var Int] = Array.thaw(arr);
        qSort(newArr, 0, newArr.size() - 1);
        Array.freeze(newArr)
    };
};



/*
$ dfx deploy

$ dfx canister call newsite quickSort "(vec{3;2;1;6;7;5;3;3})"
(vec { 1 : int; 2 : int; 3 : int; 3 : int; 3 : int; 5 : int; 6 : int; 7 : int })

$ dfx canister call newsite quickSort "(vec{1;1;1})"
(vec { 1 : int; 1 : int; 1 : int })

$ dfx canister call newsite quickSort "(vec{3;2;1})"
(vec { 1 : int; 2 : int; 3 : int })
*/