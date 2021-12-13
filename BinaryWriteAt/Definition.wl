BinaryWriteAt // ClearAll;
(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$inDef = False;
$debug = True;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*beginDefinition*)
beginDefinition // ClearAll;
beginDefinition // Attributes = { HoldFirst };
beginDefinition::unfinished = "\
Starting definition for `1` without ending the current one.";

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
beginDefinition[ s_Symbol ] /; $debug && $inDef :=
    WithCleanup[
        $inDef = False
        ,
        Print @ TemplateApply[ beginDefinition::unfinished, HoldForm @ s ];
        beginDefinition @ s
        ,
        $inDef = True
    ];
(* :!CodeAnalysis::EndBlock:: *)

beginDefinition[ s_Symbol ] :=
    WithCleanup[ Unprotect @ s; ClearAll @ s, $inDef = True ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*endDefinition*)
endDefinition // beginDefinition;
endDefinition // Attributes = { HoldFirst };

endDefinition[ s_Symbol ] := endDefinition[ s, DownValues ];

endDefinition[ s_Symbol, None ] := $inDef = False;

endDefinition[ s_Symbol, DownValues ] :=
    WithCleanup[
        AppendTo[ DownValues @ s,
                  e: HoldPattern @ s[ ___ ] :>
                      throwInternalFailure @ HoldForm @ e
        ],
        $inDef = False
    ];

endDefinition[ s_Symbol, SubValues  ] :=
    WithCleanup[
        AppendTo[ SubValues @ s,
                  e: HoldPattern @ s[ ___ ][ ___ ] :>
                      throwInternalFailure @ HoldForm @ e
        ],
        $inDef = False
    ];

endDefinition[ s_Symbol, list_List ] :=
    endDefinition[ s, # ] & /@ list;

endDefinition // endDefinition;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Messages*)
BinaryWriteAt::invfile =
"Expected a valid file instead of `1`.";

BinaryWriteAt::invstr =
"The given string cannot be encoded as bytes in the encoding `1`.";

BinaryWriteAt::invints =
"Elements in `1` are not unsigned byte values.";

BinaryWriteAt::invbytes =
"Cannot create a valid ByteArray from `1`.";

BinaryWriteAt::outofrange =
"The specified offset `1` is out of range for the given file.";

BinaryWriteAt::invoffset =
"`1` is not a valid offset specification.";

BinaryWriteAt::invargs =
"Invalid argument pattern.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
BinaryWriteAt // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
BinaryWriteAt // Options = { CharacterEncoding -> "UTF-8" };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$symbol = _Symbol? symbolQ;
$string = _String? stringQ;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
BinaryWriteAt[ file_, bytes_, opts: OptionsPattern[ ] ] :=
    catchTop @ BinaryWriteAt[ file, bytes, 0, opts ];

BinaryWriteAt[ file0_, bytes0_, offset0_, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { enc, file, bytes, offset },
        init[ ];

        enc    = OptionValue @ CharacterEncoding;
        file   = handleFileArg @ file0;
        bytes  = handleBytesArg[ bytes0, enc ];
        offset = handleOffsetArg[ file, offset0 ];

        writeBytesAt[ file, bytes, offset ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error cases*)

BinaryWriteAt[ OptionsPattern[ ] ] :=
    catchTop @ throwFailure[ "argt", BinaryWriteAt, 0, 2, 3 ];

BinaryWriteAt[ _, OptionsPattern[ ] ] :=
    catchTop @ throwFailure[ "argtu", BinaryWriteAt, 2, 3 ];

BinaryWriteAt[ a_, b_, c_, inv_, d___ ] :=
    catchTop @ throwFailure[
        "nonopt",
        BinaryWriteAt,
        Length @ Hold[ a, b, c, inv, d ],
        HoldForm @ BinaryWriteAt[ a, b, c, inv, d  ]
    ];

BinaryWriteAt[ ___ ] := catchTop @ throwFailure[ "invargs" ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error handling*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, $failed = False, catchTop = # & },
        Catch[ eval, $top ]
    ];

catchTop // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, params___ ] :=
    throwFailure[ MessageName[ BinaryWriteAt, tag ], params ];

throwFailure[ msg_, args___ ] :=
    Module[ { failure },
        failure = messageFailure[ msg, Sequence @@ HoldForm /@ { args } ];
        If[ TrueQ @ $catching,
            Throw[ failure, $top ],
            failure
        ]
    ];

throwFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*messageFailure*)
messageFailure // beginDefinition;
messageFailure // Attributes = { HoldFirst };

messageFailure[ args___ ] :=
    Module[ { quiet },
        quiet = If[ TrueQ @ $failed, Quiet, Identity ];
        WithCleanup[
            quiet @ ResourceFunction[ "MessageFailure" ][ args ],
            $failed = True
        ]
    ];

messageFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwInternalFailure*)
throwInternalFailure // beginDefinition;
throwInternalFailure // Attributes = { HoldFirst };

throwInternalFailure[ eval_, a___ ] :=
    throwFailure[ BinaryWriteAt::internal, $bugReportLink, HoldForm @ eval, a ];

throwInternalFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$bugReportLink*)
$bugReportLink := $bugReportLink = Hyperlink[
    "Report this issue \[RightGuillemet]",
    URLBuild @ <|
        "Scheme"   -> "https",
        "Domain"   -> "resources.wolframcloud.com",
        "Path"     -> { "FunctionRepository", "feedback-form" },
        "Fragment" -> SymbolName @ BinaryWriteAt
    |>
];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Defaults*)
$blockSize = 2^22;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*handleFileArg*)
handleFileArg // beginDefinition;

handleFileArg[ file_String? FileExistsQ ] := file;
handleFileArg[ File[ file_String? FileExistsQ ] ] := file;
handleFileArg[ other_ ] := throwFailure[ "invfile", other ];

handleFileArg // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*handleBytesArg*)
handleBytesArg // beginDefinition;

handleBytesArg[ bytes_ByteArray? ByteArrayQ, _ ] := bytes;

handleBytesArg[ str_String, Automatic ] :=
    handleBytesArg[ str, "UTF-8" ];

handleBytesArg[ str_String, enc_String ] :=
    Module[ { bytes },
        bytes = Check[ StringToByteArray[ str, enc ], $failed = True ];
        If[ ByteArrayQ @ bytes, bytes, throwFailure[ "invstr", enc ] ]
    ];

handleBytesArg[ ints: { ___Integer }, _ ] :=
    Module[ { bytes },

        bytes = Check[ ByteArray @ ints,
                       throwFailure[ "invints", ints ],
                       ByteArray::batd
                ];

        If[ ByteArrayQ @ bytes,
            bytes,
            throwFailure[ "invbytes", ints ]
        ]
    ];

handleBytesArg[ int_Integer, enc_ ] :=
    handleBytesArg[ { int }, enc ];

handleBytesArg[ OptionsPattern[ ], enc_ ] :=
    throwFailure[ "argtu", BinaryWriteAt, 2, 3 ];

handleBytesArg[ other_, _ ] :=
    throwFailure[ "invbytes", other ];

handleBytesArg // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*handleOffsetArg*)
handleOffsetArg // beginDefinition;

handleOffsetArg[ file_, offset_Integer? NonNegative ] :=
    If[ offset <= FileByteCount @ file,
        offset,
        throwFailure[ "outofrange", offset ]
    ];

handleOffsetArg[ file_, UpTo[ offset_Integer? NonNegative ] ] :=
    Min[ FileByteCount @ file, offset ];

handleOffsetArg[ file_, offset_Integer? Negative ] :=
    FileByteCount @ file + 1 + offset;

handleOffsetArg[ file_, UpTo[ Infinity ] ] :=
    handleOffsetArg[ file, FileByteCount @ file ];

handleOffsetArg[ file_, other_ ] :=
    throwFailure[ "invoffset", other ];

handleOffsetArg // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeBytesAt*)
writeBytesAt // beginDefinition;

writeBytesAt[ File[ file_String? FileExistsQ ], bytes_, offset_ ] :=
    writeBytesAt[ file, bytes, offset ];

writeBytesAt[ file_String? FileExistsQ, bytes_ByteArray, offset_ ] :=
    Block[ { seek, write, close },
        Module[ { str, b },
            str = JLink`JavaNew[ "java.io.RandomAccessFile", file, "rw" ];
            str @ seek @ offset;
            b = $blockSize;

            Do[ str @ write @ Normal @ bytes[[ o*b + 1 ;; UpTo[ o*b + b ] ]],
                { o, 0, Ceiling[ Length @ bytes / b ] - 1 }
            ];

            str @ close[ ];
            Remove @ str;
            file
        ]
    ];

writeBytesAt // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*init*)
init // beginDefinition;

init[ ] := init[ ] =
    Block[ { $ContextPath }, Needs[ "JLink`" ]; JLink`ReinstallJava[ ] ];

init // endDefinition;
