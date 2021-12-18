BeginPackage[ "RH`ConvertDefinitionNotebook`" ];

ConvertDefinitionNotebook;

Begin[ "`Private`" ];

ConvertDefinitionNotebook // ClearAll;


(* ::Section::Closed:: *)
(*Options*)


(* ::Text:: *)
(*Options are planned for a future update:*)


ConvertDefinitionNotebook // Options = { };


(* ::Section::Closed:: *)
(*Messages*)


ConvertDefinitionNotebook::notemplate =
"Could not find a valid template file from `1`.";


ConvertDefinitionNotebook::invtemplate =
"The file `1` does not correspond to a valid template file.";


ConvertDefinitionNotebook::unknown =
"An unexpected error occurred in `1`.";


ConvertDefinitionNotebook::invnb =
"A valid Notebook or NotebookObject is expected at position `1` in `2`.";


ConvertDefinitionNotebook::invtgt =
"A valid repository name or template file is expected at position `1` in `2`.";


ConvertDefinitionNotebook::nonopt =
"Options expected (instead of `1`) beyond position `2` in `3`. An option must be a rule or a list of rules.";


(* ::Section:: *)
(*Argument patterns*)


(* ::Text:: *)
(*Notebooks:*)


$nb = _Notebook | _NotebookObject;


(* ::Text:: *)
(*Repository specification:*)


$repo = _String? StringQ | Automatic | None;


(* ::Text:: *)
(*Template file specification:*)


$template = _String? StringQ | _CloudObject | _URL | _LocalObject | _File;


(* ::Text:: *)
(*ConvertDefinitionNotebook can also accept any options for UpdateDefinitionNotebook:*)


$opts = OptionsPattern @ {
    ConvertDefinitionNotebook,
    DefinitionNotebookClient`UpdateDefinitionNotebook
};


(* ::Subsection::Closed:: *)
(*Repository name patterns*)


$WFRName   = "WFR";
$WIReSName = "WIReS";


$repoStr = "repo" | "repository";


(* ::Text:: *)
(*Alternative names for WFR:*)


$wfrStrings = Alternatives[
    "wfr",
    "wolfram function "~~$repoStr,
    "function "~~$repoStr,
    "public",
    "prd",
    "wolfram cloud",
    "wolframcloud.com"
];

$wfr = wfr_String /; StringMatchQ[ wfr, $wfrStrings, IgnoreCase -> True ];


(* ::Text:: *)
(*Alternative names for WIReS:*)


$wiresStrings = Alternatives[
    "wires",
    "internal",
    "internal function "~~$repoStr,
    "internal "~~$repoStr,
    "internalcloud",
    "internal cloud"
];

$wires = wires_String /; StringMatchQ[ wires, $wiresStrings, IgnoreCase -> True ];


(* ::Section:: *)
(*Main definition*)


ConvertDefinitionNotebook[ nb: $nb, repo: $repo|$template, opts: $opts ] :=
    Catch[
        patchTemplateApply[ ];
        convertUsingTemplateFile[
            nb,
            findTemplateFile[ nb, repo ],
            convertOpts @ opts,
            updateOpts @ opts
        ],
        $top
    ];


(* ::Subsubsection::Closed:: *)
(*Default arguments*)


ConvertDefinitionNotebook[ nb: $nb, opts: $opts ] :=
    ConvertDefinitionNotebook[ nb, Automatic, opts ];


ConvertDefinitionNotebook[ opts: $opts ] :=
    ConvertDefinitionNotebook[ InputNotebook[ ], opts ];


(* ::Subsubsection::Closed:: *)
(*Error cases*)


c: ConvertDefinitionNotebook[ Except[ $nb ], ___ ] :=
    messageFailure[ "invnb", 1, Short @ HoldForm @ c ];


c: ConvertDefinitionNotebook[ _, Except[ $repo|$template ], ___ ] :=
    messageFailure[ "invtgt", 2, Short @ HoldForm @ c ];


c: ConvertDefinitionNotebook[ _, _, inv: Except[ _? OptionQ ], ___ ] :=
    messageFailure[ "nonopt", HoldForm @ inv, 2, Short @ HoldForm @ c ];


(* ::Text:: *)
(*This should hopefully be unreachable:*)


ConvertDefinitionNotebook[ ___ ] :=
    messageFailure[ "unknown", SymbolName @ ConvertDefinitionNotebook ];


(* ::Section:: *)
(*Repository names*)


(* ::Text:: *)
(*Get a repo name from a URL:*)


toRepoName // ClearAll;


toRepoName[ $wires    ] := $WIReSName;
toRepoName[ $wfr      ] := $WFRName;
toRepoName[ Automatic ] := Automatic;
toRepoName[ None      ] := None;


toRepoName[ str_String /; StringEndsQ[ str, $repoStr, IgnoreCase -> True ] ] :=
    toRepoName @ toCamelCase @ StringDelete[ str, WhitespaceCharacter...~~$repoStr~~EndOfString ];


toRepoName[ str_String /; StringEndsQ[ str, "resource" ] ] :=
    toRepoName @ toCamelCase @ StringReplace[ str, "resource"~~EndOfString :> "Resource" ];


toRepoName[ (URL|CloudObject)[ url_String, ___ ] ] :=
    toRepoName @ url;


toRepoName[ url_String ] :=
    toRepoName[
        url,
        Replace[
            URLParse @ url,
            KeyValuePattern[ "Scheme" -> None ] :>
                URLParse @ StringJoin[ "https://", url ]
        ]
    ];


toRepoName[ url_String ] :=
    Module[ { parsed1, valid, parsed2 },
        parsed1 = URLParse @ url;
        valid   = StringQ @ parsed1[ "Scheme" ];
        parsed2 = If[ valid, parsed1, URLParse @ StringJoin[ "https://", url ] ];
        toRepoName[ url, parsed2 ]
    ];


toRepoName[ url_String, a: KeyValuePattern[ "Domain" -> domain_String ] ] :=
    toRepoName[ url, a, domain ];


toRepoName[ _, _, "wolframcloud.com"     ] := $WFRName;
toRepoName[ _, _, "www.wolframcloud.com" ] := $WFRName;


toRepoName[ _, _, "internalcloud.wolfram.com"     ] := $WIReSName;
toRepoName[ _, _, "www.internalcloud.wolfram.com" ] := $WIReSName;


toRepoName[ other_, ___ ] := other;


(* ::Section::Closed:: *)
(*Conversion*)


convertUsingTemplateFile // ClearAll;


convertUsingTemplateFile[ nb: $nb, file_, { cOpts___? OptionQ }, { uOpts___? OptionQ } ] :=
    Module[ { converted },
        converted = DefinitionNotebookClient`UpdateDefinitionNotebook[
            nb,
            uOpts,
            "TemplateFile" -> file
        ];
        converted /; MatchQ[ converted, $nb ]
    ];


convertUsingTemplateFile[ ___ ] :=
    throwFailure[ "unknown", SymbolName @ convertUsingTemplateFile ];


(* ::Section:: *)
(*Template file locations*)


$defaultTemplateLocation := $defaultTemplateLocation =
    DefinitionNotebookClient`DefinitionTemplateLocation[ "Function" ];


$internalTemplateLocation := $internalTemplateLocation =
    CloudObject[ "https://www.internalcloud.wolfram.com/obj/resourcesystem/published/FunctionRepository/Template.nb" ];


(* ::Subsection::Closed:: *)
(*automaticTemplateFile*)


automaticTemplateFile // ClearAll;


automaticTemplateFile[ nb: $nb ] :=
    automaticTemplateFile[
        DefinitionNotebookClient`NotebookResourceType @ nb,
        DefinitionNotebookClient`DefinitionTemplateLocation @ nb
    ];


automaticTemplateFile[ "Function", co_CloudObject ] :=
    If[ cloudObjectUUID @ co === cloudObjectUUID @ $internalTemplateLocation,
        $defaultTemplateLocation,
        $internalTemplateLocation
    ];


automaticTemplateFile[ "Function", file_ ] :=
    Module[ { default },
        default = $defaultTemplateLocation;
        If[ ExpandFileName @ default === ExpandFileName @ file,
            $internalTemplateLocation,
            default
        ]
    ];


automaticTemplateFile[ rtype_, file_? FileExistsQ ] := file;


automaticTemplateFile[ rtype_String, _ ] :=
    Module[ { file },
        file = DefinitionNotebookClient`DefinitionTemplateLocation @ rtype;
        file /; FileExistsQ @ file
    ];


automaticTemplateFile[ ___ ] := $defaultTemplateLocation;


(* ::Subsection::Closed:: *)
(*findTemplateFile*)


findTemplateFile // ClearAll;


findTemplateFile[ nb_, Automatic ] :=
    automaticTemplateFile @ nb;


findTemplateFile[ nb_, None ] :=
    Module[ { file },
        file = DefinitionNotebookClient`DefinitionTemplateLocation @ nb;
        file /; FileExistsQ @ file
    ];


findTemplateFile[ _, template_? templateFileQ ] :=
    template;


findTemplateFile[ _, rtype_String ] :=
    Module[ { file },
        file = DefinitionNotebookClient`DefinitionTemplateLocation @ rtype;
        file /; FileExistsQ @ file
    ];


findTemplateFile[ nb_, repo_ ] :=
    findTemplateFile[ nb, repo, toRepoName @ repo ];


findTemplateFile[ nb_, repo_, $WIReSName ] :=
    $internalTemplateLocation;


findTemplateFile[ nb_, repo_, $WFRName ] :=
    $defaultTemplateLocation;


findTemplateFile[ nb_, original_, rtype_ ] :=
    Module[ { file },
        file = DefinitionNotebookClient`DefinitionTemplateLocation @ rtype;
        file /; FileExistsQ @ file
    ];


findTemplateFile[ nb_, file_? FileExistsQ, ___ ] :=
    throwFailure[ "invtemplate", file ];


findTemplateFile[ nb_, repo_, ___ ] :=
    throwFailure[ "notemplate", repo ];


(* ::Subsection::Closed:: *)
(*templateFileQ*)


templateFileQ // ClearAll;


templateFileQ[ file_? FileExistsQ ] :=
    Module[ { valid },
        valid = templateFileQ[ file, Import[ file, { "Package", "HeldExpressions" } ] ];
        (templateFileQ[ file ] = valid) /; valid
    ];


templateFileQ[ file_, { nb: HoldComplete[ _Notebook ] } ] :=
    ! FreeQ[ nb, _TemplateSlot ];


templateFileQ[ ___ ] :=
    False;


(* ::Section:: *)
(*Option filtering*)


(* ::Subsection::Closed:: *)
(*convertOpts*)


$convertOptionNames := $convertOptionNames =
    ToString /@ Keys @ Options @ ConvertDefinitionNotebook;


convertOpts // ClearAll;


convertOpts[ opts___ ] :=
    Normal @ KeyMap[
        ToString,
        Association[ Reverse @ FilterRules[ { opts }, $convertOptionNames ] ]
    ];


(* ::Subsection::Closed:: *)
(*updateOpts*)


$updateOptionNames := $updateOptionNames =
    ToString /@ Keys @ Options @ DefinitionNotebookClient`UpdateDefinitionNotebook;


updateOpts // ClearAll;


updateOpts[ opts___ ] :=
    Normal @ KeyMap[
        ToString,
        Association[ Reverse @ FilterRules[ { opts }, $updateOptionNames ] ]
    ];


(* ::Section:: *)
(*Error handling utilities*)


(* ::Subsection::Closed:: *)
(*messageFailure*)


(* ::Text:: *)
(*Print a message and return a Failure object:*)


messageFailure // ClearAll;


messageFailure[ msgTag_, args___ ] :=
    With[ { msg := MessageName[ ConvertDefinitionNotebook, msgTag ] },
        ResourceFunction[ "ResourceFunctionMessage" ][ msg, args ];
        Failure[
            "ConvertDefinitionNotebook",
            <|
                "MessageTag" -> msgTag,
                "MessageTemplate" -> msg,
                "MessageParameters" -> { args }
            |>
        ]
    ];


(* ::Subsection::Closed:: *)
(*throwFailure*)


(* ::Text:: *)
(*Print a message and throw a Failure object to top level:*)


throwFailure // ClearAll;


throwFailure[ msgTag_, args___ ] :=
    Throw[ messageFailure[ msgTag, args ], $top ];


(* ::Section:: *)
(*Other utilities*)


(* ::Subsection::Closed:: *)
(*cloudObjectUUID*)


cloudObjectUUID // ClearAll;


cloudObjectUUID[ url_String ] := cloudObjectUUID @ url;


cloudObjectUUID[ obj_CloudObject ] :=
    Enclose[
        cloudObjectUUID[ obj ] =
            ConfirmBy[ Information[ obj, "UUID" ], StringQ ]
    ];


(* ::Subsection::Closed:: *)
(*toCamelCase*)


toCamelCase // ClearAll;


toCamelCase[ str_String ] := StringJoin @ Capitalize @ StringSplit @ str;


(* ::Subsection::Closed:: *)
(*patchTemplateApply*)


patchTemplateApply // ClearAll;


patchTemplateApply[ ] := patchTemplateApply[ ] =
    With[
        {
            updateDefinitionNotebook = DefinitionNotebookClient`UpdateDefinitionNotebook`PackagePrivate`updateDefinitionNotebook,
            templateApply = DefinitionNotebookClient`UpdateDefinitionNotebook`PackagePrivate`templateApply
        },
        DefinitionNotebookClient`UpdateDefinitionNotebook;
        DownValues[ updateDefinitionNotebook ] = ReplaceAll[
            DownValues @ updateDefinitionNotebook,
            HoldPattern @ templateApply[ a_, b: Except[ _DeleteCases ], c___ ] :> templateApply[
                a,
                DeleteCases[ b, _Missing | _?FailureQ | {_Missing | _?FailureQ} ],
                c
            ]
        ]
    ];


End[ ];

EndPackage[ ];