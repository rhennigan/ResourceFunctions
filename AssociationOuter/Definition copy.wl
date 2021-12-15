AssociationOuter // ClearAll;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main Definition*)
AssociationOuter[ f_, args___ ] :=
    Module[ { rules, assoc },
        rules = makeRules[ f, args ];
        assoc = makeAssoc @ rules;
        AssociationKeyDeflatten @ assoc
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeRules*)
makeRules // ClearAll;
makeRules // Attributes = { HoldAllComplete };
makeRules[ f_, a___ ] :=
    Replace[ Unevaluated /@ HoldComplete @ a,
             HoldComplete[ e___ ] :> Flatten @ Outer[ makeOuterFunc @ f, e ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeAssoc*)
makeAssoc // ClearAll;
makeAssoc[ { rules___ } ] :=
    UnevaluatedAssociation @@ (HoldComplete @ rules /. keys -> List);

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeOuterFunc*)
makeOuterFunc // ClearAll;
makeOuterFunc // Attributes = { HoldAllComplete };
makeOuterFunc[ f_ ] := Function[ Null, keys @ ## -> f @ ##, HoldAllComplete ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*keys*)
keys // ClearAll;
keys // Attributes = { HoldAllComplete };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*External Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*AssociationKeyDeflatten*)
AssociationKeyDeflatten // ClearAll;
AssociationKeyDeflatten := AssociationKeyDeflatten =
    ResourceFunction[ "AssociationKeyDeflatten", "Function" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*UnevaluatedAssociation*)
UnevaluatedAssociation // ClearAll;
UnevaluatedAssociation := UnevaluatedAssociation =
    ResourceFunction[ "UnevaluatedAssociation", "Function" ];
