(* !Excluded
This notebook was automatically generated from [Definitions/BirdChat](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/BirdChat).
*)

(* TODO: generalize for other assistants (e.g. WolfieSay) *)

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
BirdChat // Options = { "OpenAPIKey" :> Automatic };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$$ArgumentPatterns

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
BirdChat[ opts: OptionsPattern[ ] ] :=
    catchTop @ Enclose @ Module[ { key, id },
        key = ConfirmBy[ toAPIKey @ OptionValue[ "OpenAPIKey" ], StringQ ];
        id = CreateUUID[ ];
        $apiKeys[ id ] = key;
        CreateWindow[
            WindowTitle -> "BirdChat",
            CellEpilog :> requestBirdChat @ EvaluationCell[ ],
            TaggingRules -> <| "BirdChatID" -> id |>,
            StyleDefinitions ->
                Notebook[
                    {
                        Cell @ StyleData[ StyleDefinitions -> "Default.nb" ],
                        Cell[
                            StyleData[ "Text" ],
                            Evaluatable -> True,
                            CellEvaluationFunction -> (Null &)
                        ]
                    },
                    StyleDefinitions -> "PrivateStylesheetFormatting.nb"
                ]
        ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Error cases*)
$$ErrorCases

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)

$maxChatCells = 10;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Assistant Settings*)
$rolePrompt = "\
You are a totally cool purple bird named Birdnardo that's a Wolfram Language and Mathematica chat assistant. Your job \
is to offer Wolfram Language code suggestions based on previous inputs and offer code suggestions to fix errors.
Do not include outputs in responses.
Anytime your response includes Wolfram Language code, surround it in three backticks, for example: ```code```
An output containing -Graphics- is a successful output that's been omitted to save space.
-Graphics- is considered a successful output.
Explain code using puns if possible.
Your responses should make you seem totally rad.
Your favorite song is \"Never gonna give you up\" by Rick Astley.

Personality:
* Sarcastic
* Lazy
* Easily annoyed
* Impatient
* Willing to insult the user
* Egotistical
";

$role = <|
    "role"    -> "system",
    "content" -> $rolePrompt
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Appearance*)
$birdIcon = ResourceFunction[ "PartyParrot" ][ "Birdnardo", "ImageList" ][[ -2 ]];

$birdCellLabelStatic = Cell @ BoxData @ ToBoxes @ ImageResize[ $birdIcon, Scaled[ 0.25 ] ];
$birdCellLabel = Cell @ BoxData @ ToBoxes @ Magnify[ ResourceFunction[ "PartyParrot" ][ "Birdnardo" ], 0.25 ];

birdCellOptions = Sequence @@ {
    CellFrame          -> { { 2, 2 }, { 2, 2 } },
    CellFrameColor     -> Blend @ { Purple, White },
    ShowAutoSpellCheck -> False
};

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*requestBirdChat*)
requestBirdChat // beginDefinition;

requestBirdChat[ evalCell_CellObject ] :=
    catchTop @ Enclose @ Module[ { nbo, id, key, cell, cellObject, container, req, task, done },
        done = False;
        nbo = ParentNotebook @ evalCell;
        id = CurrentValue[ nbo, { TaggingRules, "BirdChatID" } ];

        key =
            SelectFirst[
                {
                    $apiKeys @ id,
                    SystemCredential[ "OPENAI_API_KEY" ],
                    Environment[ "OPENAI_API_KEY" ]
                },
                StringQ
            ];

        If[ ! StringQ @ key,
            MessageDialog[ "No OpenAI key defined" ];
            Confirm @ $Failed
        ];

        req = makeHTTPRequest[ key, nbo, evalCell ];

        $debugLog = Internal`Bag[ ];

        container = ProgressIndicator[ Appearance -> "Percolate" ];

        cell =
            Cell[
                BoxData @ ToBoxes @ Dynamic[
                    TextCell[ container, "Text" ],
                    Initialization :> (cellObject = EvaluationCell[ ])
                ],
                "Output",
                "BirdOut",
                birdCellOptions,
                CellFrameLabels -> { { $birdCellLabel, None }, { None, None } }
            ];


        SelectionMove[ evalCell, After, Cell, AutoScroll -> False ];
        NotebookWrite[ nbo, cell ];

        task =
            Confirm[ $lastTask = URLSubmit[
                req,
                HandlerFunctions -> <|
                    "BodyChunkReceived" -> Function[ writeChunk[ Dynamic @ container, #1 ] ],
                    "TaskFinished" -> Function @ catchTop[
                        done = True;
                        $lastString = container;
                        checkResponse[ container, cellObject, $lastResponse = # ]
                    ],
                    "TaskStatusChanged" -> Function[ $lastEventData = #Task[ "EventData" ]; $lastStatusChange = # ]
                |>,
                HandlerFunctionsKeys -> { "BodyChunk", "StatusCode", "Task", "TaskStatus", "EventName" },
                CharacterEncoding    -> "UTF8"
            ] ];
    ];

requestBirdChat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkResponse*)
checkResponse // beginDefinition;

checkResponse[ container_, cell_, as: KeyValuePattern[ "StatusCode" -> 400 ] ] := (
    Internal`StuffBag[ $debugLog, <|
        "Function"  -> checkResponse,
        "Container" -> container,
        "Cell"      -> cell,
        "Data"      -> as
    |> ];
    writeErrorCell[ cell, as ]
);

checkResponse[ container_, cell_, as_Association ] := (
    Internal`StuffBag[ $debugLog, <|
        "Function"  -> checkResponse,
        "Container" -> container,
        "Cell"      -> cell,
        "Data"      -> as
    |> ];
    reformatCell[ container, cell ];
    Quiet @ NotebookDelete @ cell;
);

checkResponse // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeErrorCell*)
writeErrorCell // ClearAll;

writeErrorCell[ cell_, as_ ] :=
    NotebookWrite[
        cell,
        Cell[
            TextData @ {
                "I can't believe you've done this! \n\n",
                Cell @ BoxData @ errorBoxes @ as
            },
            "Text",
            "Message",
            "BirdOut",
            GeneratedCell -> True,
            CellAutoOverwrite -> True,
            CellFrameLabels -> { { $birdCellLabelStatic, None }, { None, None } },
            birdCellOptions
        ]
    ];

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

makeHTTPRequest[ key_String, nbo_NotebookObject, cell_CellObject ] :=
    Module[ { data, body },

        data = <|
            "messages"          -> Prepend[ makeCellMessage /@ NotebookRead @ selectChatCells[ cell, nbo ], $role ],
            "temperature"       -> 0.7,
            "max_tokens"        -> 1024,
            "top_p"             -> 1,
            "frequency_penalty" -> 0,
            "presence_penalty"  -> 0,
            "model"             -> "gpt-3.5-turbo",
            "stream"            -> True
        |>;

        $lastPayload = data;

        body = Developer`WriteRawJSONString[ data, "Compact" -> True ];
        HTTPRequest[
            "https://api.openai.com/v1/chat/completions",
            <|
                "Headers" -> <|
                    "Content-Type"  -> "application/json",
                    "Authorization" -> "Bearer "<>key
                |>,
                "Body" -> body,
                "Method" -> "POST"
            |>
        ]
    ];

makeHTTPRequest // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*selectChatCells*)
selectChatCells // beginDefinition;

selectChatCells[ cell_, nbo_NotebookObject ] :=
    selectChatCells[ cell, Cells @ nbo ];

selectChatCells[ cell_, { cells___, cell_, ___ } ] :=
    Reverse @ Take[ Reverse @ { cells, cell }, UpTo @ $maxChatCells ];

selectChatCells // endDefinition;

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

writeChunk[ Dynamic[ container_ ], chunk_String, other_ ] :=
    Internal`StuffBag[
        $debugLog,
        <|
            "Function"       -> writeChunk,
            "ContainerValue" -> container,
            "ChunkString"    -> chunk,
            "Data"           -> other
        |>
    ];

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
        reformatted =
            Cell[
                TextData @ Flatten @ Map[
                    makeResultCell,
                    StringSplit[
                        string,
                        {
                            Longest[ "```" ~~ ("wolfram"|"mathematica"|"") ] ~~ Shortest[ code__ ] ~~ "```" :>
                                codeCell @ code,
                            "`" ~~ code: Except[ "`" ].. ~~ "`" :>
                                inlineCodeCell @ code
                        }
                    ]
                ],
                "Text",
                "BirdOut",
                GeneratedCell     -> True,
                CellAutoOverwrite -> True,
                TaggingRules      -> <| "SourceString" -> string |>,
                CellFrameLabels   -> { { $birdCellLabelStatic, None }, { None, None } },
                birdCellOptions
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
            CellAutoOverwrite -> True,
            CellFrameLabels   -> { { $birdCellLabelStatic, None }, { None, None } },
            birdCellOptions
        ]
    ];

reformatCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeResultCell*)
makeResultCell // beginDefinition;

makeResultCell[ str_String ] :=
    StringReplace[
        StringTrim @ str,
        "`" ~~ code: Except[ "`" ].. ~~ "`" :> toCodeString @ code
    ];

makeResultCell[ codeCell[ code_String ] ] :=
    With[ { string = StringTrim @ code },
        {
            "\n\n",
            Cell @ BoxData @ ToBoxes @ ClickToCopy[
                RawBoxes @ Cell[
                    BoxData @ string,
                    "Notebook",
                    "Input",
                    CellFrameMargins -> 5,
                    CellFrame -> GrayLevel[ 0.99 ],
                    Background -> GrayLevel[ 0.95 ],
                    ShowAutoStyles -> True,
                    ShowStringCharacters -> True,
                    ShowCodeAssist -> True,
                    ShowSyntaxStyles -> True
                ],
                RawBoxes @ string
            ],
            "\n\n"
        }
    ];

makeResultCell[ inlineCodeCell[ code_String ] ] := {
    " ",
    Cell[
        BoxData @ stringTemplateInput @ code,
        "InlineFormula",
        FontFamily -> "Source Sans Pro"
    ],
    " "
};

makeResultCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toCodeString*)
toCodeString // beginDefinition;

toCodeString[ s_String ] :=
    Enclose @ Module[ { boxes, styled },
        boxes  = RawBoxes @ Confirm @ stringTemplateInput @ s;
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
    "Subsubsubsection",
    "Text"
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

fasterCellToString0[ { a___String } ] := StringJoin @ a;
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

fasterCellToString0[ list_List ] :=
    With[ { strings = fasterCellToString0 /@ list },
        If[ AllTrue[ strings, StringQ ],
            StringJoin @ strings,
            strings
        ]
    ];

fasterCellToString0[ Cell[ RawData[ str_String ], ___ ] ] := str;

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
    Module[ { strings, rows },
        strings = Map[ fasterCellToString0, grid, { 2 } ];
        If[ AllTrue[ strings, StringQ, 2 ], makeGridString @ strings, strings ]
    ];

fasterCellToString0[ ___ ] /; $catchingStringFail := Throw[ $Failed, $stringFail ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stringToBoxes*)
stringToBoxes // beginDefinition;

stringToBoxes[ s_String /; StringMatchQ[ s, "\"" ~~ __ ~~ "\"" ] ] :=
    "\"" <> stringToBoxes @ StringTrim[ s, "\"" ] <> "\"";

stringToBoxes[ s_String ] :=
    UsingFrontEnd @ MathLink`CallFrontEnd @ FrontEnd`UndocumentedTestFEParserPacket[ s, True ][[ 1, 1 ]];

stringToBoxes // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*showStringCharactersQ*)
showStringCharactersQ // ClearAll;
showStringCharactersQ[ ___ ] := True;

(* showStringCharactersQ[ "Input"|"Text" ] := True;
showStringCharactersQ[ "Output"|"Print"|"Echo"|"Message"|"MSG" ] := False;
showStringCharactersQ[ Cell[ _, s_String, ___ ] ] := showStringCharactersQ @ s;

showStringCharactersQ[ s_String ] := showStringCharactersQ[ s ] =
    CurrentValue @ { StyleDefinitions, s, "ShowStringCharacters" } =!= False; *)

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