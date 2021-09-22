BeginPackage["RHResourceFunctions`"]

(* Declare your packages public symbols here. *)

SayHello

Begin["`Private`"]

(* Define your public and private symbols here. *)

SayHello[name_?StringQ] := Print["Hello ", name, "!"]


End[] (* End `Private` *)

EndPackage[]
