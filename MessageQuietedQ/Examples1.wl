(* ::Section:: *)
(*Basic Examples*)


(* ::Text:: *)
(*Test if a message is disabled via <+Quiet+>:*)


Quiet @ { MessageQuietedQ @ Power::infy, 1/0 }


{ MessageQuietedQ @ Power::infy, 1/0 }


(* ::ExampleDelimiter:: *)


(* ::Text:: *)
(*Check when specific messages are quieted:*)


Quiet[ { MessageQuietedQ @ Power::infy, 1/0 }, Power::infy ]


Quiet[ { MessageQuietedQ @ Power::infy, 1/0 }, First::argx ]


(* ::Section:: *)
(*Scope*)


(* ::Text:: *)
(*Check for messages inherited from <+General+>:*)


Quiet[ { MessageQuietedQ @ First::normal, First[ 1 ] }, General::normal ]


Quiet[ { MessageQuietedQ @ General::normal, First[ 1 ] }, First::normal ]


(* ::Section:: *)
(*Options*)


(* ::Section:: *)
(*Applications*)


(* ::Section:: *)
(*Properties and Relations*)


(* ::Section:: *)
(*Possible Issues*)


(* ::Section:: *)
(*Neat Examples*)
