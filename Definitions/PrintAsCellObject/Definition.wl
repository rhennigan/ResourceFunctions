(* !Excluded
This notebook was automatically generated from [Definitions/PrintAsCellObject](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/PrintAsCellObject).
*)

PrintAsCellObject // ClearAll;

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Options*)

(* This option is no longer used, but it's left in to avoid potential
   <+PrintAsCellObject::optx+> messages in existing code: *)
PrintAsCellObject // Options = { TimeConstraint -> Automatic };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
PrintAsCellObject[ args___ ] /; $Notebooks :=
    With[ { cell = makePrintCell @ args },
        MathLink`CallFrontEnd @ FrontEnd`CellPrintReturnObject @ cell
    ];

PrintAsCellObject[ args___ ] := (
    Print @ args;
    Missing[ "FrontEndNotAvailable" ]
);

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makePrintCell*)
makePrintCell // ClearAll;
makePrintCell // Attributes = { HoldAllComplete };

makePrintCell[ ] :=
    Cell[ BoxData[ "\"\"" ],
          "Print",
          $printCellOpts
    ];

makePrintCell[ expr_ ] :=
    Cell[ BoxData @ MakeBoxes[ expr, StandardForm ],
          "Print",
          $printCellOpts
    ];

makePrintCell[ exprs__ ] :=
    Cell[ BoxData @ MakeBoxes[ SequenceForm @ exprs, StandardForm ],
          "Print",
          $printCellOpts
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$printCellOpts*)
$printCellOpts := Sequence[
    CellAutoOverwrite -> Inherited,
    CellLabel         -> "During evaluation of In["<> ToString @ $Line <>"]:=",
    GeneratedCell     -> Inherited
];

(* :!CodeAnalysis::EndBlock:: *)