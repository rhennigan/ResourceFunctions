MessageQuietedQ // ClearAll;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
MessageQuietedQ // Attributes = { HoldFirst };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
MessageQuietedQ[ msg: MessageName[ _Symbol, tag___ ] ] :=
    With[ { msgEval = msg },
        TrueQ @ Or[
            MatchQ[ msgEval, _$Off ],
            inheritingOffQ[ msgEval, tag ],
            messageQuietedQ @ msg
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inheritingOffQ*)
inheritingOffQ // ClearAll;

inheritingOffQ[ _String, ___ ] := False;

inheritingOffQ[ msg_, tag_ ] := MatchQ[ MessageName[ General, tag ], _$Off ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*messageQuietedQ*)
messageQuietedQ // ClearAll;

messageQuietedQ // Attributes = { HoldFirst };

messageQuietedQ[ msg: MessageName[ _Symbol, tag___ ] ] :=
    Module[ { stack, msgOrGeneral, msgPatt },

        stack        = Lookup[ $status = Internal`QuietStatus[ ], Stack ];
        msgOrGeneral = generalMessagePattern @ msg;
        msgPatt      = All | { ___, msgOrGeneral, ___ };

        TrueQ @ And[
            (* check if msg is unquieted via third arg of Quiet: *)
            FreeQ[ stack, { _, _, msgPatt }, 2 ],
            (* check if msg is not quieted via second arg of Quiet: *)
            ! FreeQ[ stack, { _, msgPatt, _ }, 2 ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generalMessagePattern*)
generalMessagePattern // ClearAll;

generalMessagePattern // Attributes = { HoldFirst };

generalMessagePattern[ msg: MessageName[ _Symbol, tag___ ] ] :=
    If[ StringQ @ msg,
        HoldPattern @ msg,
        HoldPattern[ msg | MessageName[ General, tag ] ]
    ];
