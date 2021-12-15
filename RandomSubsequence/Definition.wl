RandomSubsequence // ClearAll;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
RandomSubsequence[ seq_? validSequenceQ ] :=
    RandomSubsequence[ seq, Automatic ];

RandomSubsequence[ seq_? validSequenceQ, Automatic ] :=
    RandomSubsequence[ Unevaluated @ seq,
                       RandomInteger @ Length @ Unevaluated @ seq
    ];

RandomSubsequence[ seq_? validSequenceQ, len_ ] :=
    Module[ { lenMax, start },
        lenMax = Length @ Unevaluated @ seq;
        If[ len === lenMax,
            seq,
            start = RandomInteger[ lenMax - len ] + 1;
            Unevaluated[ seq ][[ start ;; start + len - 1 ]]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validSequenceQ*)
validSequenceQ // Attributes = { HoldFirst };

validSequenceQ[ seq_ ] := TrueQ[ Depth @ Unevaluated @ seq >= 2 ];