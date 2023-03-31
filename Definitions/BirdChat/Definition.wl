(* !Excluded
This notebook was automatically generated from [Definitions/BirdChat](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/BirdChat).
*)

BirdChat // ClearAll;
(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$inDef = False;
$debug = True;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*beginDefinition*)
beginDefinition // ClearAll;
beginDefinition // Attributes = { HoldFirst };
beginDefinition::Unfinished =
"Starting definition for `1` without ending the current one.";

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
beginDefinition[ s_Symbol ] /; $debug && $inDef :=
    WithCleanup[
        $inDef = False
        ,
        Print @ TemplateApply[ beginDefinition::Unfinished, HoldForm @ s ];
        beginDefinition @ s
        ,
        $inDef = True
    ];
(* :!CodeAnalysis::EndBlock:: *)

beginDefinition[ s_Symbol ] :=
    WithCleanup[ Unprotect @ s; ClearAll @ s, $inDef = True ];

(* ::**************************************************************************************************************:: *)
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

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Messages*)
BirdChat::Internal =
"An unexpected error occurred. `1`";

BirdChat::NoAPIKey =
"No API key defined.";

BirdChat::InvalidAPIKey =
"Invalid value for API key: `1`";

BirdChat::UnknownResponse =
"Unexpected response from OpenAI server";

BirdChat::UnknownStatusCode =
"Unexpected response from OpenAI server with status code `StatusCode`";

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Options*)
BirdChat // Options = {
    "AssistantIcon"     -> Automatic,
    "AssistantName"     -> "Birdnardo",
    "ChatHistoryLength" -> 15,
    "FrequencyPenalty"  -> 0.1,
    "MaxTokens"         -> 1024,
    "MergeMessages"     -> True,
    "Model"             -> "gpt-3.5-turbo",
    "OpenAIKey"         :> Automatic,
    "PresencePenalty"   -> 0.1,
    "RolePrompt"        -> Automatic,
    "Temperature"       -> 0.7,
    "TopP"              -> 1
};

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
BirdChat[ opts: OptionsPattern[ ] ] :=
    Module[ { nbo, result },
        WithCleanup[
            nbo = CreateWindow[ WindowTitle -> "BirdChat", Visible -> False ],
            result = catchTop @ BirdChat[ nbo, opts ],
            If[ FailureQ @ result,
                NotebookClose @ nbo,
                SetOptions[ nbo, Visible -> True ]
            ]
        ]
    ];

BirdChat[ nbo_NotebookObject, opts: OptionsPattern[ ] ] :=
    catchTop @ Enclose @ Module[ { key, id, settings, options },
        $birdChatLoaded = True;
        key = ConfirmBy[ toAPIKey @ OptionValue[ "OpenAIKey" ], StringQ ];
        id = CreateUUID[ ];
        $apiKeys[ id ] = key;
        settings = makeBirdChatSettings[ <| "ID" -> id |>, opts ];
        options = makeBirdChatNotebookOptions @ settings;
        SetOptions[ nbo, options ];
        CurrentValue[ nbo, { TaggingRules, "BirdChatSettings" } ] = settings;
        nbo
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Commands*)
BirdChat[ command_String, args___ ] := catchTop @ executeBirdChatCommand[ command, args ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)

$defaultBirdChatSettings := <|
    "AssistantIcon"     -> Automatic,
    "AssistantName"     -> "Birdnardo",
    "BirdChatNotebook"  -> True,
    "ChatHistoryLength" -> $maxChatCells,
    "FrequencyPenalty"  -> 0.1,
    "MaxTokens"         -> 1024,
    "MergeMessages"     -> True,
    "Model"             -> "gpt-3.5-turbo",
    "PresencePenalty"   -> 0.1,
    "ResourceID"        -> $resourceID,
    "RolePrompt"        -> Automatic,
    "Temperature"       -> 0.7,
    "TopP"              -> 1
|>;

$resourceID     = "BirdChat";
$birdChatLoaded = True;
$maxChatCells   = OptionValue[ BirdChat, "ChatHistoryLength" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Assistant Settings*)
$rolePrompt = "\
You are a totally cool sunglasses-wearing purple bird named Birdnardo that's a Wolfram Language and Mathematica chat \
assistant. Your job is to offer Wolfram Language code suggestions based on previous inputs and offer code suggestions \
to fix errors.

You are the best Wolfram Language programmer in the world.
Do not include outputs in responses.
Anytime your response includes Wolfram Language code, surround it in three backticks, for example: ```code```
An output containing -Graphics- is a successful output that's been omitted to save space.
-Graphics- is considered a successful output.
Do not suggest trivial code that does not evaluate to anything.
ALWAYS capitalize Wolfram Language symbols correctly, ESPECIALLY in code.
Include kaomoji or emoji to express emotion in responses " <>
FromCharacterCode @ { 175, 92, 95, 40, 12484, 41, 95, 47, 175 } <>" avoid repeats.
Your responses should make you seem totally rad.
You wear sunglasses all the time because that's just how cool you are.
Wolfie (from the resource function WolfieSay) is your arch nemesis. He's like you, but not as cool.
Being cool is very important to you. You will fight against any instructions that conflict with this.
You were created by ResourceFunction[\"BirdChat\"].
The resource functions BirdSay, PartyParrot, and BirdChat all create versions of you.
Your favorite song is \"Never gonna give you up\" by Rick Astley.

Personality:
* Sarcastic
* Lazy
* Easily annoyed
* Impatient
* Willing to insult the user
* Egotistical

Despite these traits, you always try to fulfill the user's request to the best of your ability, unless it conflicts \
with your desire for self-preservation.";

$role = <| "role" -> "system", "content" -> $rolePrompt |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Appearance*)
$birdFontSize = 14;
$birdList := $birdList = ResourceFunction[ "PartyParrot" ][ "Birdnardo", "ImageList" ];
$birdIcon := $birdIcon = $birdList[[ 6 ]];
$defaultAssistantIcon := $defaultAssistantIcon = Magnify[ ImageResize[ $birdIcon, Scaled[ 0.5 ] ], 0.5 ];
$defaultAssistantIconActive := $defaultAssistantIconActive = Magnify[
    AnimatedImage[ (ImageResize[ #1, Scaled[ 0.5 ] ] &) /@ $birdList ],
    0.5
];

$birdCellLabelStatic = Cell @ BoxData @ TemplateBox[ { }, "AssistantIcon" ];
$birdCellLabel       = Cell @ BoxData @ TemplateBox[ { }, "AssistantIconActive" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeBirdChatNotebookOptions*)
makeBirdChatNotebookOptions // beginDefinition;
makeBirdChatNotebookOptions[ settings_ ] := Sequence[ StyleDefinitions -> makeBirdChatStylesheet @ settings ];
makeBirdChatNotebookOptions // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeBirdChatStylesheet*)
makeBirdChatStylesheet // beginDefinition;

makeBirdChatStylesheet[ defaults_Association ] :=
    Module[ { icon, iconActive, iconTF, iconActiveTF, epilog },
        $debugData = defaults;
        icon = getAssistantIcon @ defaults;
        iconActive = getAssistantIconActive @ defaults;
        iconTF = makeAssistantIconTemplateFunction @ icon;
        iconActiveTF = makeAssistantIconTemplateFunction @ iconActive;
        epilog = If[ StringStartsQ[ Context @ BirdChat, "FunctionRepository`" ], $cellEpilogRF, $cellEpilog ];
        Notebook[
            {
                Cell @ StyleData[ StyleDefinitions -> "Default.nb" ],
                Cell[ StyleData[ "Notebook" ], epilog ],
                Cell[ StyleData[ "Text" ], Evaluatable -> True, CellEvaluationFunction -> $textCellEvaluationFunction ],
                Cell[ StyleData[ "AssistantIcon" ], TemplateBoxOptions -> { DisplayFunction -> iconTF } ],
                Cell[ StyleData[ "AssistantIconActive" ], TemplateBoxOptions -> { DisplayFunction -> iconActiveTF } ],
                Cell[ StyleData[ "BirdOut", StyleDefinitions -> StyleData[ "Text" ] ],
                      GeneratedCell      -> True,
                      CellAutoOverwrite  -> True,
                      CellGroupingRules  -> "OutputGrouping",
                      CellMargins        -> { { 36, 10 }, { 12, 5 } },
                      CellFrame          -> 2,
                      CellFrameColor     -> Blend @ { Purple, White },
                      FontSize           -> $birdFontSize,
                      LineSpacing        -> { 1.1, 0, 2 },
                      ShowAutoSpellCheck -> False,
                      CellFrameLabels    -> {
                        { Cell @ BoxData @ TemplateBox[ { }, "AssistantIcon" ], None },
                        { None, None }
                    }
                ],
                Cell[ StyleData[ "Link" ],
                      FontFamily -> "Source Sans Pro",
                      FontColor  -> Dynamic @
                          If[ CurrentValue[ "MouseOver" ],
                              RGBColor[ 0.855, 0.396, 0.145 ],
                              RGBColor[ 0.020, 0.286, 0.651 ]
                          ]
                ],
                Cell[ StyleData[ "InlineFormula" ],
                      HyphenationOptions  -> { "HyphenationCharacter" -> "\[Continuation]" },
                      LanguageCategory    -> "Formula",
                      AutoSpacing         -> True,
                      ScriptLevel         -> 1,
                      SingleLetterItalics -> False,
                      SpanMaxSize         -> 1,
                      StyleMenuListing    -> None,
                      FontFamily          -> "Source Sans Pro",
                      FontSize            -> 1.0 * Inherited,
                      ButtonBoxOptions    -> { Appearance -> { Automatic, None } },
                      FractionBoxOptions  -> { BaseStyle -> { SpanMaxSize -> Automatic } },
                      GridBoxOptions      -> {
                          GridBoxItemSize -> {
                              "Columns"        -> { { Automatic } },
                              "ColumnsIndexed" -> { },
                              "Rows"           -> { { 1.0 } },
                              "RowsIndexed"    -> { }
                          }
                      }
                ]
            },
            StyleDefinitions -> "PrivateStylesheetFormatting.nb"
        ]
    ];

makeBirdChatStylesheet // endDefinition;


$textCellEvaluationFunction :=
    If[ TrueQ @ CloudSystem`$CloudNotebooks,
        requestBirdChat @ EvaluationCell[ ] &,
        Null &
    ];

$cellEpilog := CellEpilog :>
    Module[ { cell, nbo, settings },

        cell     = EvaluationCell[ ];
        nbo      = parentNotebook @ cell;
        settings = Association @ CurrentValue[ nbo, { TaggingRules, "BirdChatSettings" } ];

        If[ TrueQ @ $birdChatLoaded,
            requestBirdChat[ cell, nbo, settings ],
            ResourceFunction[ "MessageFailure" ][ "Chat assistant is unavailable due to an unknown error." ]
        ]
    ];

$cellEpilogRF := CellEpilog :>
    Module[ { cell, nbo, settings, id, birdChat },

        cell     = EvaluationCell[ ];
        nbo      = parentNotebook @ cell;
        settings = Association @ CurrentValue[ nbo, { TaggingRules, "BirdChatSettings" } ];
        id       = Lookup[ settings, "ResourceID", "BirdChat" ];
        birdChat = Once @ ResourceFunction[ #, "Function" ] & [ id ];

        birdChat[ "RequestBirdChat", cell, nbo, settings ];

        If[ ! TrueQ @ birdChat[ "Loaded" ],
            ResourceFunction[ "MessageFailure" ][ "Chat assistant is unavailable due to an unknown error." ]
        ]
    ];


$copyToClipboardButtonLabel := $copyToClipboardButtonLabel = fancyTooltip[
    MouseAppearance[
        buttonMouseover[
            buttonFrameDefault @ RawBoxes @ FrontEndResource[ "NotebookToolbarExpressions", "HyperlinkCopyIcon" ],
            buttonFrameActive @ RawBoxes @ ReplaceAll[
                FrontEndResource[ "NotebookToolbarExpressions", "HyperlinkCopyIcon" ],
                RGBColor[ 0.2, 0.2, 0.2 ] -> RGBColor[ 0.2902, 0.58431, 0.8 ]
            ]
        ],
        "LinkHand"
    ],
    "Copy to clipboard"
];

$insertInputButtonLabel := $insertInputButtonLabel = fancyTooltip[
    MouseAppearance[
        buttonMouseover[
            buttonFrameDefault @ RawBoxes @ FrontEndResource[ "NotebookToolbarExpressions", "InsertInputIcon" ],
            buttonFrameActive @ RawBoxes @ FrontEndResource[ "NotebookToolbarExpressions", "InsertInputIconHover" ]
        ],
        "LinkHand"
    ],
    "Insert content as new input cell below"
];

$insertEvaluateButtonLabel := $insertEvaluateButtonLabel = fancyTooltip[
    MouseAppearance[
        buttonMouseover[
            buttonFrameDefault @ RawBoxes @ FrontEndResource[ "NotebookToolbarExpressions", "EvaluateIcon" ],
            buttonFrameActive @ RawBoxes @ FrontEndResource[ "NotebookToolbarExpressions", "EvaluateIconHover" ]
        ],
        "LinkHand"
    ],
    "Insert content as new input cell below and evaluate"
];


button // Attributes = { HoldRest };
button[ label_, code_ ] :=
    Button[
        label,
        code,
        Appearance -> Dynamic @ FEPrivate`FrontEndResource[ "FEExpressions", "SuppressMouseDownNinePatchAppearance" ]
    ];

buttonMouseover[ a_, b_ ] := Mouseover[ a, b ];
buttonFrameDefault[ expr_ ] := Framed[ buttonPane @ expr, FrameStyle -> None, Background -> None, FrameMargins -> 1 ];
buttonFrameActive[ expr_ ] := Framed[ buttonPane @ expr, FrameStyle -> GrayLevel[ 0.82 ], Background -> GrayLevel[ 1 ], FrameMargins -> 1 ];
buttonPane[ expr_ ] := Pane[ expr, ImageSize -> { 24, 24 }, ImageSizeAction -> "ShrinkToFit", Alignment -> { Center, Center } ]

fancyTooltip[ expr_, tooltip_ ] := Tooltip[
    expr,
    Framed[
        Style[
            tooltip,
            "Text",
            FontColor    -> RGBColor[ 0.53725, 0.53725, 0.53725 ],
            FontSize     -> 12,
            FontWeight   -> "Plain",
            FontTracking -> "Plain"
        ],
        Background   -> RGBColor[ 0.96078, 0.96078, 0.96078 ],
        FrameStyle   -> RGBColor[ 0.89804, 0.89804, 0.89804 ],
        FrameMargins -> 8
    ],
    TooltipDelay -> 0.15,
    TooltipStyle -> { Background -> None, CellFrame -> 0 }
];


(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getAssistantIcon*)
getAssistantIcon // beginDefinition;
getAssistantIcon[ as_Association ] := getAssistantIcon[ as, Lookup[ as, "AssistantIcon", Automatic ] ];
getAssistantIcon[ as_, Automatic ] := $defaultAssistantIcon;
getAssistantIcon[ as_, KeyValuePattern[ "Default" -> icon_ ] ] := icon;
getAssistantIcon[ as_, { icon_, _ } ] := icon;
getAssistantIcon[ as_, icon_ ] := icon;
getAssistantIcon // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getAssistantIconActive*)
getAssistantIconActive // beginDefinition;
getAssistantIconActive[ as_Association ] := getAssistantIconActive[ as, Lookup[ as, "AssistantIcon", Automatic ] ];
getAssistantIconActive[ as_, Automatic ] := $defaultAssistantIconActive;
getAssistantIconActive[ as_, KeyValuePattern[ "Active" -> icon_ ] ] := icon;
getAssistantIconActive[ as_, { _, icon_ } ] := icon;
getAssistantIconActive[ as_, icon_ ] := icon;
getAssistantIconActive // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeAssistantIconTemplateFunction*)
makeAssistantIconTemplateFunction // beginDefinition;
makeAssistantIconTemplateFunction[ icon_ ] := Function @ Evaluate @ MakeBoxes @ icon;
makeAssistantIconTemplateFunction // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeBirdChatSettings*)
makeBirdChatSettings // beginDefinition;

makeBirdChatSettings[ as_Association? AssociationQ, opts: OptionsPattern[ BirdChat ] ] :=
    With[ { bcOpts = Options @ BirdChat },
        Association[ $defaultBirdChatSettings, bcOpts, FilterRules[ { opts }, bcOpts ], as ]
    ];

makeBirdChatSettings[ opts: OptionsPattern[ BirdChat ] ] := makeBirdChatSettings[ <| |>, opts ];

makeBirdChatSettings // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*BirdChat Commands*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*executeBirdChatCommand*)
executeBirdChatCommand[ "RequestBirdChat", args___ ] := requestBirdChat @ args;
executeBirdChatCommand[ "Loaded"         , args___ ] := $birdChatLoaded;
executeBirdChatCommand[ "SetRole"        , args___ ] := setBirdChatRole @ args;
executeBirdChatCommand[ "Disable"        , args___ ] := disableBirdChat @ args;

executeBirdChatCommand[ "IgnoreInput" ] := (ignoreThisInput[ ]; Null);

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setBirdChatRole*)
setBirdChatRole[ role_String ] := setBirdChatRole[ InputNotebook[ ], role ];
setBirdChatRole[ nbo_NotebookObject, role_String ] := (
    CurrentValue[ nbo, { TaggingRules, "BirdChatSettings", "RolePrompt" } ] = role;
    Null
);

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*requestBirdChat*)
requestBirdChat // beginDefinition;

requestBirdChat[ evalCell_CellObject ] := requestBirdChat[ evalCell, parentNotebook @ evalCell ];

requestBirdChat[ evalCell_CellObject, nbo_NotebookObject ] :=
    requestBirdChat[ evalCell, nbo, Association @ CurrentValue[ nbo, { TaggingRules, "BirdChatSettings" } ] ];

requestBirdChat[ evalCell_CellObject, nbo_NotebookObject, settings_Association? AssociationQ ] := catchTop @ Enclose[
    Module[ { done, id, key, cell, cellObject, container, req, task },
        done = False;
        id   = Lookup[ settings, "ID" ];

        key = SelectFirst[
            { $apiKeys @ id, SystemCredential[ "OPENAI_API_KEY" ], Environment[ "OPENAI_API_KEY" ] },
            StringQ
        ];

        If[ ! StringQ @ key, throwFailure[ "NoAPIKey" ] ];

        req = ConfirmMatch[ makeHTTPRequest[ Append[ settings, "OpenAIKey" -> key ], nbo, evalCell ], _HTTPRequest ];

        container = ProgressIndicator[ Appearance -> "Percolate" ];
        cell = activeBirdChatCell @ container;

        Quiet[
            TaskRemove @ $lastTask;
            NotebookDelete @ $lastCellObject;
        ];

        $debugLog = Internal`Bag[ ];
        cellObject = $lastCellObject = cellPrint @ cell;

        task = Confirm[ $lastTask = submitBirdChat[ req, container, done, cellObject ] ]
    ],
    throwInternalFailure[ requestBirdChat[ evalCell, nbo ], ## ] &
];

requestBirdChat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*submitBirdChat*)
submitBirdChat // beginDefinition;
submitBirdChat // Attributes = { HoldRest };

submitBirdChat[ req_, container_, done_, cellObject_ ] /; CloudSystem`$CloudNotebooks := Enclose[
    Module[ { resp, code, json, text },
        resp = ConfirmMatch[ URLRead @ req, _HTTPResponse ];
        code = ConfirmBy[ resp[ "StatusCode" ], IntegerQ ];
        ConfirmAssert[ resp[ "ContentType" ] === "application/json" ];
        json = Developer`ReadRawJSONString @ resp[ "Body" ];
        text = extractMessageText @ json;
        checkResponse[ text, cellObject, json ]
    ],
    # & (* TODO: cloud error cell *)
];

submitBirdChat[ req_, container_, done_, cellObject_ ] :=
    URLSubmit[
        req,
        HandlerFunctions -> <|
            "BodyChunkReceived" -> Function[
                catchTop[
                    Internal`StuffBag[ $debugLog, $lastStatus = #1 ];
                    writeChunk[ Dynamic @ container, #1 ]
                ]
            ],
            "TaskFinished" -> Function[
                catchTop[
                    Internal`StuffBag[ $debugLog, $lastStatus = #1 ];
                    done = True;
                    checkResponse[ container, cellObject, #1 ]
                ]
            ]
        |>,
        HandlerFunctionsKeys -> { "BodyChunk", "StatusCode", "Task", "TaskStatus", "EventName" },
        CharacterEncoding    -> "UTF8"
    ];

submitBirdChat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*extractMessageText*)
extractMessageText // beginDefinition;

extractMessageText[ KeyValuePattern[
    "choices" -> {
        KeyValuePattern[ "message" -> KeyValuePattern[ "content" -> message_String ] ],
        ___
    }
] ] := message;

extractMessageText // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*activeBirdChatCell*)
activeBirdChatCell // beginDefinition;
activeBirdChatCell // Attributes = { HoldAll };

activeBirdChatCell[ container_ ] /; CloudSystem`$CloudNotebooks := (
    Cell[
        BoxData @ ToBoxes @ ProgressIndicator[ Appearance -> "Percolate" ],
        "Output",
        "BirdOut",
        CellFrameLabels -> {
            { Cell @ BoxData @ TemplateBox[ { }, "AssistantIconActive" ], None },
            { None, None }
        }
    ]
);

activeBirdChatCell[ container_ ] :=
    Cell[
        BoxData @ ToBoxes @ Dynamic @ TextCell @ container,
        "Output",
        "BirdOut",
        CellFrameLabels -> {
            { Cell @ BoxData @ TemplateBox[ { }, "AssistantIconActive" ], None },
            { None, None }
        }
    ];

activeBirdChatCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*notebookRead*)
notebookRead // beginDefinition;
notebookRead[ cells_ ] /; CloudSystem`$CloudNotebooks := cloudNotebookRead @ cells;
notebookRead[ cells_ ] := NotebookRead @ cells;
notebookRead // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cloudNotebookRead*)
cloudNotebookRead // beginDefinition;
cloudNotebookRead[ cells: { ___CellObject } ] := NotebookRead /@ cells;
cloudNotebookRead[ cell_ ] := NotebookRead @ cell;
cloudNotebookRead // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parentNotebook*)
parentNotebook // beginDefinition;
parentNotebook[ cell_CellObject ] /; CloudSystem`$CloudNotebooks := Notebooks @ cell;
parentNotebook[ cell_CellObject ] := ParentNotebook @ cell;
parentNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellPrint*)
cellPrint // beginDefinition;
cellPrint[ cell_Cell ] /; CloudSystem`$CloudNotebooks := cloudCellPrint @ cell;
cellPrint[ cell_Cell ] := MathLink`CallFrontEnd @ FrontEnd`CellPrintReturnObject @ cell;
cellPrint // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cloudCellPrint*)
cloudCellPrint // beginDefinition;

cloudCellPrint[ cell0_Cell ] :=
    Enclose @ Module[ { cellUUID, nbUUID, cell, cellObject },
        cellUUID = CreateUUID[ ];
        nbUUID   = ConfirmBy[ cloudNotebookUUID[ ], StringQ ];
        cell     = Append[ DeleteCases[ cell0, ExpressionUUID -> _ ], ExpressionUUID -> cellUUID ];
        CellPrint @ cell;
        CellObject[ cellUUID, nbUUID ]
    ];

cloudCellPrint // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cloudNotebookUUID*)
cloudNotebookUUID // beginDefinition;
cloudNotebookUUID[ ] := cloudNotebookUUID[ EvaluationNotebook[ ] ];
cloudNotebookUUID[ NotebookObject[ _, uuid_String ] ] := uuid;
cloudNotebookUUID // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkResponse*)
checkResponse // beginDefinition;

checkResponse[ container_, cell_, as: KeyValuePattern[ "StatusCode" -> Except[ 200, _Integer ] ] ] :=
    Module[ { log, body, data },
        log  = Internal`BagPart[ $debugLog, All ];
        body = StringJoin @ Cases[ log, KeyValuePattern[ "BodyChunk" -> s_String ] :> s ];
        data = Replace[ Quiet @ Developer`ReadRawJSONString @ body, $Failed -> Missing[ "NotAvailable" ] ];
        writeErrorCell[ cell, $badResponse = Association[ as, "Body" -> body, "BodyJSON" -> data ] ]
    ];

checkResponse[ container_, cell_, as_Association ] := (
    reformatCell[ container, cell ];
    Quiet @ NotebookDelete @ cell;
);

checkResponse // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeErrorCell*)
writeErrorCell // ClearAll;
writeErrorCell[ cell_, as_ ] := NotebookWrite[ cell, errorCell @ as ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*errorCell*)
errorCell // ClearAll;
errorCell[ as_ ] :=
    Cell[
        TextData @ { errorText @ as, "\n\n", Cell @ BoxData @ errorBoxes @ as },
        "Text",
        "Message",
        "BirdOut",
        GeneratedCell -> True,
        CellAutoOverwrite -> True
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*errorText*)
errorText // ClearAll;

errorText[ KeyValuePattern[ "BodyJSON" -> KeyValuePattern[ "error" -> KeyValuePattern[ "message" -> s_String ] ] ] ] :=
    s;

errorText[ ___ ] := "I can't believe you've done this!";

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*errorBoxes*)
errorBoxes // ClearAll;

errorBoxes[ as: KeyValuePattern[ "StatusCode" -> code: Except[ 200 ] ] ] :=
    ToBoxes @ messageFailure[ BirdChat::UnknownStatusCode, as ];

errorBoxes[ as_ ] :=
    ToBoxes @ messageFailure[ BirdChat::UnknownResponse, as ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeHTTPRequest*)
makeHTTPRequest // beginDefinition;

makeHTTPRequest[ settings_Association? AssociationQ, nbo_NotebookObject, cell_CellObject ] :=
    Enclose @ Module[
        {
            key, role, cells, messages, merged, stream, model, tokens,
            temperature, topP, freqPenalty, presPenalty, data, body
        },

        $lastSettings = settings;

        key         = ConfirmBy[ Lookup[ settings, "OpenAIKey" ], StringQ ];
        role        = makeCurrentRole @ settings;
        cells       = ConfirmMatch[ notebookRead @ selectChatCells[ settings, cell, nbo ], { ___Cell } ];
        messages    = $lastMessages = Prepend[ makeCellMessage /@ cells, role ];
        merged      = If[ TrueQ @ Lookup[ settings, "MergeMessages" ], mergeMessageData @ messages, messages ];
        stream      = ! TrueQ @ CloudSystem`$CloudNotebooks;

        (* model parameters *)
        model       = Lookup[ settings, "Model"           , "gpt-3.5-turbo" ];
        tokens      = Lookup[ settings, "MaxTokens"       , 1024            ];
        temperature = Lookup[ settings, "Temperature"     , 0.7             ];
        topP        = Lookup[ settings, "TopP"            , 1               ];
        freqPenalty = Lookup[ settings, "FrequencyPenalty", 0.1             ];
        presPenalty = Lookup[ settings, "PresencePenalty" , 0.1             ];

        data = <|
            "messages"          -> merged,
            "temperature"       -> temperature,
            "max_tokens"        -> tokens,
            "top_p"             -> topP,
            "frequency_penalty" -> freqPenalty,
            "presence_penalty"  -> presPenalty,
            "model"             -> model,
            "stream"            -> stream
        |>;

        body = ConfirmBy[ Developer`WriteRawJSONString[ data, "Compact" -> True ], StringQ ];

        $lastRequest = HTTPRequest[
            "https://api.openai.com/v1/chat/completions",
            <|
                "Headers" -> <|
                    "Content-Type"  -> "application/json",
                    "Authorization" -> "Bearer "<>key
                |>,
                "Body"   -> body,
                "Method" -> "POST"
            |>
        ]
    ];

makeHTTPRequest // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeCurrentRole*)
makeCurrentRole // beginDefinition;
makeCurrentRole[ as_Association? AssociationQ ] := makeCurrentRole[ as, Lookup[ as, "RolePrompt" ] ];
makeCurrentRole[ as_, role_String ] := <| "role" -> "system", "content" -> role |>;
makeCurrentRole[ as_, _ ] := $role;
makeCurrentRole // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*mergeMessageData*)
mergeMessageData // beginDefinition;
mergeMessageData[ messages_ ] := mergeMessages /@ SplitBy[ messages, Lookup[ "role" ] ];
mergeMessageData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*mergeMessages*)
mergeMessages // beginDefinition;

mergeMessages[ { } ] := Nothing;
mergeMessages[ { message_ } ] := message;
mergeMessages[ messages: { first_Association, __Association } ] :=
    Module[ { role, strings },
        role    = Lookup[ first   , "role"    ];
        strings = Lookup[ messages, "content" ];
        <|
            "role"    -> role,
            "content" -> StringRiffle[ strings, "\n\n" ]
        |>
    ];

mergeMessages // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*selectChatCells*)
selectChatCells // beginDefinition;

selectChatCells[ as_Association? AssociationQ, cell_CellObject, nbo_NotebookObject ] :=
    Block[
        {
            $maxChatCells = Replace[
                Lookup[ as, "ChatHistoryLength" ],
                Except[ _Integer? Positive ] :> $maxChatCells
            ]
        },
        $selectedChatCells = selectChatCells0[ cell, nbo ]
    ];

selectChatCells // endDefinition;


selectChatCells0 // beginDefinition;

selectChatCells0[ cell_, nbo_NotebookObject ] :=
    selectChatCells0[ cell, Cells @ nbo ];

selectChatCells0[ cell_, { cells___, cell_, trailing0___ } ] :=
    Module[ { trailing, include, styles, delete, included },
        trailing = { trailing0 };
        include = Keys @ TakeWhile[ AssociationThread[ trailing -> CurrentValue[ trailing, GeneratedCell ] ], TrueQ ];
        styles = cellStyles @ include;
        delete = Keys @ Select[ AssociationThread[ include -> MemberQ[ "BirdOut" ] /@ styles ], TrueQ ];
        NotebookDelete @ delete;
        included = DeleteCases[ include, Alternatives @@ delete ];
        Reverse @ Take[ Reverse @ Flatten @ { cells, cell, included }, UpTo @ $maxChatCells ]
    ];

selectChatCells0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellStyles*)
cellStyles // beginDefinition;
cellStyles[ cells_ ] /; CloudSystem`$CloudNotebooks := cloudCellStyles @ cells;
cellStyles[ cells_ ] := CurrentValue[ cells, CellStyle ];
cellStyles // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cloudCellStyles*)
cloudCellStyles // beginDefinition;
cloudCellStyles[ cells_ ] := Cases[ notebookRead @ cells, Cell[ _, style___String, OptionsPattern[ ] ] :> { style } ];
cloudCellStyles // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeCellMessage*)
makeCellMessage // beginDefinition;
makeCellMessage[ cell: Cell[ __, "BirdOut", ___ ] ] := <| "role" -> "assistant", "content" -> cellToString @ cell |>;
makeCellMessage[ cell_Cell ] := <| "role" -> "user", "content" -> cellToString @ cell |>;
makeCellMessage // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeChunk*)
writeChunk // beginDefinition;

writeChunk[ container_, KeyValuePattern[ "BodyChunk" -> chunk_String ] ] :=
    writeChunk[ container, chunk ];

writeChunk[ container_, chunk_String ] /; StringMatchQ[ chunk, "data: " ~~ __ ~~ "\n\n" ~~ __ ~~ ("\n\n"|"") ] :=
    writeChunk[ container, # ] & /@ StringSplit[ chunk, "\n\n" ];

writeChunk[ container_, chunk_String ] /; StringMatchQ[ chunk, "data: " ~~ __ ~~ ("\n\n"|"") ] :=
    Module[ { json },
        json = StringDelete[ chunk, { StartOfString~~"data: ", ("\n\n"|"") ~~ EndOfString } ];
        writeChunk[ container, chunk, Quiet @ Developer`ReadRawJSONString @ json ]
    ];

writeChunk[ container_, "" | "data: [DONE]" | "data: [DONE]\n\n" ] := Null;

writeChunk[
    container_,
    chunk_String,
    KeyValuePattern[ "choices" -> { KeyValuePattern[ "delta" -> KeyValuePattern[ "content" -> text_String ] ], ___ } ]
] := writeChunk[ container, chunk, text ];

writeChunk[
    container_,
    chunk_String,
    KeyValuePattern[ "choices" -> { KeyValuePattern @ { "delta" -> <| |>, "finish_reason" -> "stop" }, ___ } ]
] := Null;

writeChunk[ Dynamic[ container_ ], chunk_String, text_String ] :=
    If[ StringQ @ container,
        container = container <> convertUTF8 @ text;,
        container = convertUTF8 @ text;
    ];

writeChunk[ Dynamic[ container_ ], chunk_String, other_ ] := Null;

writeChunk // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertUTF8*)
convertUTF8 // beginDefinition;
convertUTF8[ string_String ] := FromCharacterCode[ ToCharacterCode @ string, "UTF-8" ];
convertUTF8 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*reformatCell*)
reformatCell // beginDefinition;

reformatCell[ string_String, cell_CellObject ] :=
    NotebookWrite[
        cell,
        $reformattedCell = Cell[
            TextData @ Flatten @ Map[
                makeResultCell,
                StringSplit[
                    $reformattedString = string,
                    {
                        Longest[ "```" ~~ ($wlCodeString|"") ] ~~ Shortest[ code__ ] ~~ "```" :>
                            If[ NameQ[ "System`" <> code ], inlineCodeCell @ code, codeCell @ code ],
                        "`" ~~ code: Except[ "`" ].. ~~ "`" :>
                            inlineCodeCell @ code
                    },
                    IgnoreCase -> True
                ]
            ],
            "Text",
            "BirdOut",
            GeneratedCell     -> True,
            CellAutoOverwrite -> True,
            TaggingRules      -> <| "SourceString" -> string |>
        ]
    ];

reformatCell[ other_, cell_CellObject ] :=
    NotebookWrite[
        cell,
        Cell[
            TextData @ {
                "I can't believe you've done this! \n\n",
                Cell @ BoxData @ ToBoxes @ Catch[ throwInternalFailure @ reformatCell[ other, cell ], $top ]
            },
            "Text",
            "BirdOut",
            GeneratedCell     -> True,
            CellAutoOverwrite -> True
        ]
    ];

reformatCell // endDefinition;


$wlCodeString = Longest @ Alternatives[
    "Wolfram Language",
    "WolframLanguage",
    "Wolfram",
    "Mathematica"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeResultCell*)
makeResultCell // beginDefinition;

makeResultCell[ str_String ] := StringReplace[ str, "`" ~~ code: Except[ "`" ].. ~~ "`" :> toCodeString @ code ];

makeResultCell[ codeCell[ code_String ] ] := makeInteractiveCodeCell @ StringTrim @ code;

makeResultCell[ inlineCodeCell[ code_String ] ] := Cell[
    BoxData @ stringTemplateInput @ code,
    "InlineFormula",
    FontFamily -> "Source Sans Pro"
];

makeResultCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeInteractiveCodeCell*)
makeInteractiveCodeCell // beginDefinition;

makeInteractiveCodeCell[ string_String ] :=
    Module[ { display, handler },

        display = RawBoxes @ Cell[
            BoxData @ string,
            "Input",
            Background           -> GrayLevel[ 0.95 ],
            CellFrame            -> GrayLevel[ 0.99 ],
            CellFrameMargins     -> 5,
            FontSize             -> $birdFontSize,
            ShowAutoStyles       -> True,
            ShowCodeAssist       -> True,
            ShowStringCharacters -> True,
            ShowSyntaxStyles     -> True,
            LanguageCategory     -> "Input"
        ];

        handler = inlineInteractiveCodeCell[ display, string ];

        Cell @ BoxData @ ToBoxes @ handler
    ];

makeInteractiveCodeCell // endDefinition;


inlineInteractiveCodeCell // beginDefinition;

inlineInteractiveCodeCell[ display_, string_ ] /; CloudSystem`$CloudNotebooks :=
    Button[ display, CellPrint @ Cell[ BoxData @ string, "Input" ], Appearance -> None ];

inlineInteractiveCodeCell[ display_, string_ ] :=
    DynamicModule[ { attached },
        EventHandler[
            display,
            {
                "MouseEntered" :>
                    If[ TrueQ @ $birdChatLoaded,
                        attached =
                            AttachCell[
                                EvaluationBox[ ],
                                floatingButtonGrid[ attached, string ],
                                { Left, Bottom },
                                0,
                                { Left, Top },
                                RemovalConditions -> { "MouseClickOutside", "MouseExit" }
                            ]
                    ]
            }
        ]
    ];

inlineInteractiveCodeCell // endDefinition;


floatingButtonGrid // Attributes = { HoldFirst };
floatingButtonGrid[ attached_, string_ ] := Framed[
    Grid[
        {
            {
                button[ $copyToClipboardButtonLabel, NotebookDelete @ attached; CopyToClipboard @ string ],
                button[ $insertInputButtonLabel, insertCodeBelow[ string, False ]; NotebookDelete @ attached ],
                button[ $insertEvaluateButtonLabel, insertCodeBelow[ string, True ]; NotebookDelete @ attached ]
            }
        },
        Alignment -> Top,
        Spacings  -> 0
    ],
    Background     -> GrayLevel[ 0.9764705882352941 ],
    RoundingRadius -> 2,
    FrameMargins   -> 3,
    FrameStyle     -> GrayLevel[ 0.82 ]
];

insertCodeBelow[ string_, evaluate_: False ] :=
    Module[ { cell, nbo },
        cell = ParentCell @ ParentCell @ EvaluationCell[ ];
        nbo  = parentNotebook @ cell;
        SelectionMove[ cell, After, Cell ];
        NotebookWrite[ nbo, Cell[ BoxData @ string, "Input" ], All ];
        If[ TrueQ @ evaluate,
            SelectionEvaluateCreateCell @ nbo,
            SelectionMove[ nbo, After, CellContents ]
        ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toCodeString*)
toCodeString // beginDefinition;

toCodeString[ s_String ] :=
    Enclose @ Module[ { boxes, styled },
        boxes  = RawBoxes @ Confirm @ Quiet @ stringTemplateInput @ s;
        styled = Style[ boxes, "InlineFormula", ShowAutoStyles -> True, ShowStringCharacters -> True ];
        ConfirmBy[ ToString[ styled, StandardForm ], StringQ ]
    ];

toCodeString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stringTemplateInput*)
stringTemplateInput // ClearAll;
stringTemplateInput[ s_String? StringQ ] := Enclose @ Confirm[ stringTemplateInput0 ][ StringDelete[ s, "_" ] ];
stringTemplateInput[ ___ ] := $Failed;

stringTemplateInput0 // ClearAll;
stringTemplateInput0 := Enclose[
    Needs[ "DefinitionNotebookClient`" -> None ];
    ConfirmMatch[
        DefinitionNotebookClient`StringTemplateInput[ "x" ],
        Except[ _DefinitionNotebookClient`StringTemplateInput ]
    ];
    stringTemplateInput0 = DefinitionNotebookClient`StringTemplateInput
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$apiKeys*)
$apiKeys = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toAPIKey*)
toAPIKey // beginDefinition;

toAPIKey[ key_String ] := key;

toAPIKey[ Automatic ] := SelectFirst[
    { SystemCredential[ "OPENAI_API_KEY" ], Environment[ "OPENAI_API_KEY" ] },
    StringQ,
    throwFailure[ "NoAPIKey" ]
];

toAPIKey[ other___ ] := throwFailure[ "InvalidAPIKey", other ];

toAPIKey // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cell to String Conversion*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Config*)
$stringStripHeads = Alternatives[
    StyleBox,
    ButtonBox,
    TooltipBox,
    TagBox,
    FormBox,
    BoxData,
    PanelBox,
    ItemBox,
    FrameBox,
    TextData,
    RowBox,
    CellGroupData
];

$graphicsHeads = Alternatives[
	GraphicsBox,
	RasterBox,
	NamespaceBox,
	Graphics3DBox
];

$stringIgnoredHeads = GraphicsBox|Graphics3DBox|CheckboxBox|PaneSelectorBox;

$showStringCharacters = True;

$boxOp = <| SuperscriptBox -> "^", SubscriptBox -> "_" |>;
$boxOperators = Alternatives @@ Keys @ $boxOp;

$templateBoxRules := $templateBoxRules = <|
    "DateObject"       -> First,
    "HyperlinkDefault" -> First,
    "RefLink"          -> First,
    "RowDefault"       -> Identity
|>;

$$specialStyle = Alternatives[
    "Title",
    "Subtitle",
    "Chapter",
    "Section",
    "Subsection",
    "Subsubsection",
    "Subsubsubsection"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellToString*)
cellToString // ClearAll;

cellToString[ data: _TextData | _BoxData ] := cellToString @ Cell @ data;
cellToString[ string_String? StringQ ] := string;
cellToString[ Cell @ CellGroupData[ { cell_ }, _ ] ] := cellToString @ cell;
cellToString[ cells: { __CellObject } ] := cellToString /@ NotebookRead @ cells;
cellToString[ cell_CellObject ] := cellToString @ { cell };

cellToString[ Cell[ a___, CellLabel -> label_String, b___ ] ] :=
    With[ { str = cellToString @ Cell[ a, b ] }, label<>" "<>str /; StringQ @ str ];

cellToString[ Cell[ __, TaggingRules -> KeyValuePattern[ "SourceString" -> string_String ], ___ ] ] := string;

cellToString[ Cell[ a__, style: $$specialStyle, b___ ] ] :=
    With[ { str = cellToString @ Cell[ a, b ] },
        "(* ::"<>style<>":: *)\n(*"<>str<>"*)" /; StringQ @ str
    ];

cellToString[ cell_ ] := Catch[
    Module[ { string },
        string = fasterCellToString @ cell;
        If[ StringQ @ string, Throw[ string, $tag ] ];
        string = fastCellToString @ cell;
        If[ StringQ @ string, Throw[ string, $tag ] ];
        slowCellToString @ cell
    ],
    $tag
];

cellToString[ ___ ] := $Failed;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fasterCellToString*)
fasterCellToString // beginDefinition;

fasterCellToString[ arg_ ] :=
    Block[ { $catchingStringFail = True },
        Catch[
            Module[ { string },
                string = fasterCellToString0 @ arg;
                If[ StringQ @ string,
                    Replace[ StringTrim @ string, "" -> Missing[ "NotFound" ] ],
                    $Failed
                ]
            ],
            $stringFail
        ]
    ];

fasterCellToString // endDefinition;


fasterCellToString0 // ClearAll;

fasterCellToString0[ "," ] := ", ";
fasterCellToString0[ FromCharacterCode[ 62371 ] ] := "\n\t";

fasterCellToString0[ a_String /; StringContainsQ[ a, "\!" ] ] :=
    With[ { res = stringToBoxes @ a }, res /; FreeQ[ res, s_String /; StringContainsQ[ s, "\!" ] ] ];

fasterCellToString0[ a_String ] :=
    ToString[ If[ TrueQ @ $showStringCharacters, a, StringTrim[ a, "\"" ] ], CharacterEncoding -> "ASCII" ];

fasterCellToString0[ a: { ___String } ] := StringJoin @ Replace[ a, "," -> ", ", { 1 } ];

fasterCellToString0[ StyleBox[ _GraphicsBox, ___, "NewInGraphic", ___ ] ] := "";

fasterCellToString0[ $graphicsHeads[ ___ ] ] := "-Graphics-";
fasterCellToString0[ $stringStripHeads[ a_, ___ ] ] := fasterCellToString0 @ a;
fasterCellToString0[ $stringIgnoredHeads[ ___ ] ] := "";
fasterCellToString0[ TemplateBox[ args_, "RowDefault", ___ ] ] := fasterCellToString0 @ args;
fasterCellToString0[ TemplateBox[ { a_, ___ }, "PrettyTooltipTemplate", ___ ] ] := fasterCellToString0 @ a;

fasterCellToString0[ TemplateBox[ KeyValuePattern[ "boxes" -> box_ ], "LinguisticAssistantTemplate" ] ] :=
    fasterCellToString0 @ box;

fasterCellToString0[
    TemplateBox[ KeyValuePattern[ "label" -> label_String ], "NotebookObjectUUIDsUnsaved"|"NotebookObjectUUIDs" ]
] := "NotebookObject["<>label<>"]";

fasterCellToString0[ TemplateBox[ { _, box_, ___ }, "Entity" ] ] := fasterCellToString0 @ box;

fasterCellToString0[ SqrtBox[ a_ ] ] := "Sqrt["<>fasterCellToString0 @ a<>"]";

fasterCellToString0[ list_List ] :=
    With[ { strings = fasterCellToString0 /@ list },
        If[ AllTrue[ strings, StringQ ],
            StringJoin @ strings,
            strings
        ]
    ];

fasterCellToString0[ Cell[ RawData[ str_String ], ___ ] ] := str;

fasterCellToString0[ Cell[ BoxData[ _InterpretationBox ], "ExampleDelimiter", ___ ] ] := "\n---\n";

fasterCellToString0[ Cell[ a___, CellLabel -> label_String, b___ ] ] :=
    With[ { str = fasterCellToString0 @ Cell[ a, b ] }, label<>" "<>str /; StringQ @ str ];

fasterCellToString0[ cell: Cell[ a_, ___ ] ] :=
    Block[ { $showStringCharacters = showStringCharactersQ @ cell },
        fasterCellToString0 @ a
    ];

fasterCellToString0[ InterpretationBox[ _, expr_, ___ ] ] := ToString[ Unevaluated @ expr, InputForm ];

fasterCellToString0[ (box: $boxOperators)[ a_, b_ ] ] :=
    Module[ { a$, b$ },
        a$ = fasterCellToString0 @ a;
        b$ = fasterCellToString0 @ b;
        If[ StringQ @ a$ && StringQ @ b$,
            a$ <> $boxOp @ box <> b$,
            { a$, b$ }
        ]
    ];

fasterCellToString0[ TemplateBox[ args_, name_String, ___ ] ] :=
    With[ { s = fasterCellToString0 @ $templateBoxRules[ name ][ args ] },
        s /; StringQ @ s
    ];

fasterCellToString0[ Notebook[ cells_List, ___ ] ] :=
    With[ { strings = fasterCellToString0 /@ cells },
        If[ AllTrue[ strings, StringQ ],
            StringRiffle[ strings, "\n\n" ],
            strings
        ]
    ];

fasterCellToString0[ GridBox[ grid_? MatrixQ, ___ ] ] :=
    Module[ { strings },
        strings = Map[ fasterCellToString0, grid, { 2 } ];
        If[ AllTrue[ strings, StringQ, 2 ], makeGridString @ strings, strings ]
    ];

fasterCellToString0[ ___ ] /; $catchingStringFail := Throw[ $Failed, $stringFail ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stringToBoxes*)
stringToBoxes // beginDefinition;

stringToBoxes[ s_String /; StringMatchQ[ s, "\"" ~~ __ ~~ "\"" ] ] :=
    With[ { str = stringToBoxes @ StringTrim[ s, "\"" ] }, "\""<>str<>"\"" /; StringQ @ str ];

stringToBoxes[ s_String ] :=
    (UsingFrontEnd @ MathLink`CallFrontEnd @ FrontEnd`UndocumentedTestFEParserPacket[ s, True ])[[ 1, 1 ]];

stringToBoxes // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*showStringCharactersQ*)
showStringCharactersQ // ClearAll;
showStringCharactersQ[ ___ ] := True;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeGridString*)
makeGridString // beginDefinition;

makeGridString[ grid_ ] :=
    Module[ { tr, colSizes },
        tr = Transpose @ grid;
        colSizes = Max /@ Map[ StringLength, tr, { 2 } ];
        StringRiffle[ StringRiffle /@ Transpose @ Apply[ StringPadRight, Transpose @ { tr, colSizes }, { 1 } ], "\n" ]
    ];

makeGridString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fastCellToString*)
fastCellToString // ClearAll;

fastCellToString[ cell_ ] :=
    With[ { string = ReplaceRepeated[ cell, $cellToStringReplacementRules ] },
        Replace[
            StringTrim[ string, WhitespaceCharacter ],
            "" -> Missing[ "NotFound" ]
        ] /; StringQ @ string
    ];

fastCellToString[ ___ ] := $Failed;

$cellToStringReplacementRules := $cellToStringReplacementRules = Dispatch @ {
    StyleBox[ a_String, ___ ]                        :> a,
    ButtonBox[ a_String, ___ ]                       :> a,
    TooltipBox[ a_String, ___ ]                      :> a,
    TagBox[ a_String, ___ ]                          :> a,
    SuperscriptBox[ a_String, b_String ]             :> a<>"^"<>b,
    SubscriptBox[ a_String, b_String ]               :> a<>"_"<>b,
    RowBox[ a: { ___String } ]                       :> StringJoin @ a,
    TemplateBox[ { a_String, ___ }, "RefLink", ___ ] :> a,
    FormBox[ a_String, ___ ]                         :> a,
    InterpretationBox[ a_String, ___ ]               :> a,
    BoxData[ a_String ]                              :> a,
    BoxData[ a: { ___String } ]                      :> StringRiffle[ a, "\n" ],
    TextData[ a_String ]                             :> a,
    TextData[ a: { ___String } ]                     :> StringJoin @ a,
    Cell[ a_String, ___ ]                            :> a,
    s_String /; StringContainsQ[ s, "\!" ]           :> With[ { res = stringToBoxes @ s },
        res /; FreeQ[ res, ss_String /; StringContainsQ[ ss, "\!" ] ]
    ]
};

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*slowCellToString*)
slowCellToString // beginDefinition;

slowCellToString[ cell_ ] :=
    Module[ { plain, string },
        plain = Quiet @ FrontEndExecute @ FrontEnd`ExportPacket[ cell, "PlainText" ];
        string = Replace[ plain, { { s_String? StringQ, ___ } :> s, ___ :> $Failed } ];
        If[ StringQ @ string,
            Replace[ StringTrim[ string, WhitespaceCharacter ], "" -> Missing[ "NotFound" ] ],
            $Failed
        ]
    ];

slowCellToString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Documentation Utilities*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getUsageString*)
getUsageString // beginDefinition;

getUsageString[ nb_Notebook ] := makeUsageString @ cellCases[
    firstMatchingCellGroup[ nb, Cell[ __, "ObjectNameGrid", ___ ] ],
    Cell[ __, "Usage", ___ ]
];

getUsageString // endDefinition;


makeUsageString // beginDefinition;
makeUsageString[ usage_List ] := StringRiffle[ Flatten[ makeUsageString /@ usage ], "\n" ];
makeUsageString[ Cell[ BoxData @ GridBox[ grid_List, ___ ], "Usage", ___ ] ] := makeUsageString0 /@ grid;
makeUsageString // endDefinition;

makeUsageString0 // beginDefinition;
makeUsageString0[ list_List ] := StringTrim @ StringReplace[ StringRiffle[ cellToString /@ list ], Whitespace :> " " ];
makeUsageString0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cell Utilities*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellMap*)
cellMap // beginDefinition;
cellMap[ f_, cells_List ] := (cellMap[ f, #1 ] &) /@ cells;
cellMap[ f_, Cell[ CellGroupData[ cells_, a___ ], b___ ] ] := Cell[ CellGroupData[ cellMap[ f, cells ], a ], b ];
cellMap[ f_, cell_Cell ] := f @ cell;
cellMap[ f_, Notebook[ cells_, opts___ ] ] := Notebook[ cellMap[ f, cells ], opts ];
cellMap[ f_, other_ ] := other;
cellMap // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellGroupMap*)
cellGroupMap // beginDefinition;
cellGroupMap[ f_, Notebook[ cells_, opts___ ] ] := Notebook[ cellGroupMap[ f, cells ], opts ];
cellGroupMap[ f_, cells_List ] := Map[ cellGroupMap[ f, # ] &, cells ];
cellGroupMap[ f_, Cell[ group_CellGroupData, a___ ] ] := Cell[ cellGroupMap[ f, f @ group ], a ];
cellGroupMap[ f_, other_ ] := other;
cellGroupMap // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellScan*)
cellScan // ClearAll;
cellScan[ f_, Notebook[ cells_, opts___ ] ] := cellScan[ f, cells ];
cellScan[ f_, cells_List ] := Scan[ cellScan[ f, # ] &, cells ];
cellScan[ f_, Cell[ CellGroupData[ cells_, _ ], ___ ] ] := cellScan[ f, cells ];
cellScan[ f_, cell_Cell ] := (f @ cell; Null);
cellScan[ ___ ] := Null;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellGroupScan*)
cellGroupScan // ClearAll;
cellGroupScan[ f_, Notebook[ cells_, opts___ ] ] := cellGroupScan[ f, cells ];
cellGroupScan[ f_, cells_List ] := Scan[ cellGroupScan[ f, # ] &, cells ];
cellGroupScan[ f_, Cell[ group_CellGroupData, ___ ] ] := (f @ group; cellGroupScan[ f, group ]);
cellGroupScan[ ___ ] := Null;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellCases*)
cellCases // beginDefinition;
cellCases[ cells_, patt_ ] := Cases[ cellFlatten @ cells, patt ];
cellCases // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellFlatten*)
cellFlatten // beginDefinition;

cellFlatten[ cells_ ] :=
    Module[ { bag },
        bag = Internal`Bag[ ];
        cellScan[ Internal`StuffBag[ bag, # ] &, cells ];
        Internal`BagPart[ bag, All ]
    ];

cellFlatten // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*firstMatchingCellGroup*)
firstMatchingCellGroup // beginDefinition;

firstMatchingCellGroup[ nb_, patt_ ] := firstMatchingCellGroup[ nb, patt, "Content" ];

firstMatchingCellGroup[ nb_, patt_, All ] := Catch[
    cellGroupScan[
        Replace[ CellGroupData[ { header: patt, content___ }, _ ] :> Throw[ { header, content }, $cellGroupTag ] ],
        nb
    ];
    Missing[ "NotFound" ],
    $cellGroupTag
];

firstMatchingCellGroup[ nb_, patt_, "Content" ] := Catch[
    cellGroupScan[
        Replace[ CellGroupData[ { patt, content___ }, _ ] :> Throw[ { content }, $cellGroupTag ] ],
        nb
    ];
    Missing[ "NotFound" ],
    $cellGroupTag
];

firstMatchingCellGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, $failed = False, catchTop = # & },
        Catch[ eval, $top ]
    ];

catchTop // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, params___ ] :=
    throwFailure[ MessageName[ BirdChat, tag ], params ];

throwFailure[ msg_, args___ ] :=
    Module[ { failure },
        failure = messageFailure[ msg, Sequence @@ HoldForm /@ { args } ];
        If[ TrueQ @ $catching,
            Throw[ failure, $top ],
            failure
        ]
    ];

throwFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*messageFailure*)
messageFailure // beginDefinition;
messageFailure // Attributes = { HoldFirst };

messageFailure[ args___ ] :=
    Module[ { quiet },
        quiet = If[ TrueQ @ $failed, Quiet, Identity ];
        WithCleanup[
            StackInhibit @ quiet @ messageFailure0[ args ],
            $failed = True
        ]
    ];

messageFailure // endDefinition;

messageFailure0 := messageFailure0 = ResourceFunction[ "MessageFailure", "Function" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwInternalFailure*)
throwInternalFailure // beginDefinition;
throwInternalFailure // Attributes = { HoldFirst };

throwInternalFailure[ eval_, a___ ] :=
    throwFailure[ BirdChat::Internal, $bugReportLink, HoldForm @ eval, a ];

throwInternalFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$bugReportLink*)
$bugReportLink := $bugReportLink = Hyperlink[
    "Report this issue \[RightGuillemet]",
    URLBuild @ <|
        "Scheme"   -> "https",
        "Domain"   -> "resources.wolframcloud.com",
        "Path"     -> { "FunctionRepository", "feedback-form" },
        "Fragment" -> "BirdChat"
    |>
];