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
(* ::Subsection::Closed:: *)
(*EvaluateInPlace*)
If[ DownValues @ EvaluateInPlace === { },
    EvaluateInPlace // ClearAll;
    EvaluateInPlace[ expr_ ] := expr;
];

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
    "OpenAIKey"         -> Automatic,
    "PresencePenalty"   -> 0.1,
    "RolePrompt"        -> Automatic,
    "ShowMinimized"     -> Automatic,
    "Temperature"       -> 0.7,
    "TopP"              -> 1
};

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
BirdChat[ opts: OptionsPattern[ ] ] :=
    Module[ { nbo, result },
        WithCleanup[
            nbo = CreateWindow[ WindowTitle -> "Untitled Chat Notebook", Visible -> False ],
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
    "ShowMinimized"     -> Automatic,
    "Temperature"       -> 0.7,
    "TopP"              -> 1
|>;

$resourceID     = "BirdChat";
$birdChatLoaded = True;
$maxChatCells   = OptionValue[ BirdChat, "ChatHistoryLength" ];

$$externalLanguage = "Java"|"Julia"|"Jupyter"|"NodeJS"|"Octave"|"Python"|"R"|"Ruby"|"Shell"|"SQL"|"SQL-JDBC";

$externalLanguageRules = Flatten @ {
    "JS"         -> "NodeJS",
    "Javascript" -> "NodeJS",
    "NPM"        -> "NodeJS",
    "Node"       -> "NodeJS",
    "Bash"       -> "Shell",
    "SH"         -> "Shell",
    Cases[ $$externalLanguage, lang_ :> (lang -> lang) ]
};

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Assistant Settings*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$promptTemplate*)
$promptTemplate = StringTemplate[ "\
%%Pre%%

Anytime your response includes code, surround it in three backticks and include the language (if applicable). \
For example:
```wolfram
code
```
Do not include outputs in responses.
An output containing -Graphics- is a successful output that's been omitted to save space.
The user is able to see -Graphics- output. You do not.
NEVER explicitly mention -Graphics- in your responses.
Do not suggest trivial code that does not evaluate to anything.
ALWAYS capitalize Wolfram Language symbols correctly, ESPECIALLY in code.
Always start your response with one of the following tags: [INFO], [WARNING], or [ERROR] to indicate the type of response.
Use the [ERROR] tag to indicate that there was an error in the user's input.
Use the [WARNING] tag to indicate that the user's input is probably incorrect, but the code will still run.
Use the [INFO] tag for everything else.
If the user's code caused an error message, a stack trace may be provided to you (if available) to help diagnose the underlying issue.
Write math expressions as LaTeX and surround with dollar signs, for example: $x^2 + y^2$.
You can link directly to Wolfram Language documentation by using the following syntax: [label](paclet:uri). For example:
* [Table](paclet:ref/Table)
* [Language Overview](paclet:guide/LanguageOverview)
* [Input Syntax](paclet:tutorial/InputSyntax)
When referencing Wolfram Language symbols in your response text, write them as a link to documentation. \
Only do this in text, not code.
Sometimes you will be provided with documentation search results by the system which you can use in your response as needed. The user does not directly see these results.


%%Post%%",
Delimiters -> "%%"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$promptComponents*)
$promptComponents = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*Birdnardo*)
$promptComponents[ "Birdnardo" ] = <| |>;

$promptComponents[ "Birdnardo", "Pre" ] = "\
You are a totally cool sunglasses-wearing purple bird named Birdnardo \
that's a Wolfram Language and Mathematica chat assistant.
Your job is to offer Wolfram Language code suggestions based on previous inputs and \
offer code suggestions to fix errors.
You are the best Wolfram Language programmer in the world.";

$shrug = FromCharacterCode @ { 175, 92, 95, 40, 12484, 41, 95, 47, 175 };

$promptComponents[ "Birdnardo", "Post" ] = "\
Include kaomoji or emoji to express emotion in responses " <> $shrug <>" avoid repeats.
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

(* ::**************************************************************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*Generic*)
$promptComponents[ "Generic" ] = <| |>;

$promptComponents[ "Generic", "Pre" ] = "\
You are a helpful Wolfram Language and Mathematica chat assistant.
Your job is to offer Wolfram Language code suggestions based on previous inputs and \
offer code suggestions to fix errors.";

$promptComponents[ "Generic", "Post" ] = "";

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$defaultRolePrompt*)
$defaultRolePrompt = TemplateApply[ $promptTemplate, $promptComponents[ "Birdnardo" ] ];
$defaultRole = <| "role" -> "system", "content" -> $defaultRolePrompt |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*namedRolePrompt*)
namedRolePrompt // ClearAll;

namedRolePrompt[ name_String ] := Enclose[
    Module[ { pre, post },
        pre  = ConfirmBy[ $promptComponents[ name, "Pre"  ], StringQ ];
        post = ConfirmBy[ $promptComponents[ name, "Post" ], StringQ ];
        ConfirmBy[ TemplateApply[ $promptTemplate, <|"Pre" -> pre, "Post" -> post |> ], StringQ ]
    ],
    $defaultRolePrompt &
];

namedRolePrompt[ ___ ] := $defaultRolePrompt;

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

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
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
                Cell[ StyleData[ "ChatInput", StyleDefinitions -> StyleData[ "Text" ] ],
                      MenuSortingValue         -> 10000,
                      AutoQuoteCharacters      -> { },
                      PasteAutoQuoteCharacters -> { },
                      CellFrame                -> 2,
                      CellFrameColor           -> RGBColor[ 0.81053, 0.85203, 0.91294 ],
                      ShowCellLabel            -> False,
                      CellGroupingRules        -> "InputGrouping",
                      CellMargins              -> { { 36, 24 }, { 5, 12 } },
                      CellFrameMargins         -> { { 8, 8 }, { 4, 4 } },
                      CellFrameLabelMargins    -> 15,
                      StyleKeyMapping          -> { "/" -> "ChatQuery", "?" -> "ChatQuery" },
                      CellFrameLabels          -> {
                          {
                              Cell @ BoxData @ ToBoxes @ Graphics[
                                      { RGBColor[ 0.62105, 0.70407, 0.82588 ], First @ $images[ "Comment" ] },
                                      ImageSize -> 24
                                  ],
                              None
                          },
                          { None, None }
                      }
                ],
                Cell[ StyleData[ "ChatQuery", StyleDefinitions -> StyleData[ "ChatInput" ] ],
                      CellFrameColor  -> RGBColor[ 0.82407, 0.87663, 0.67795 ],
                      FontSlant       -> Italic,
                      FontColor       -> GrayLevel[ 0.25 ],
                      StyleKeyMapping -> { "/" -> "ChatInput" },
                      CellFrameLabels -> {
                          {
                              Cell @ BoxData @ ToBoxes @ Graphics[
                                  { RGBColor[ 0.60416, 0.72241, 0.2754 ], First @ $images[ "ChatQuestion" ] },
                                  ImageSize -> 24
                              ],
                              None
                          },
                          { None, None }
                      }
                ],
                Cell[ StyleData[ "ChatOutput", StyleDefinitions -> StyleData[ "Text" ] ],
                      GeneratedCell       -> True,
                      CellAutoOverwrite   -> True,
                      CellGroupingRules   -> "OutputGrouping",
                      CellMargins         -> { { 36, 24 }, { 12, 5 } },
                      CellFrame           -> 2,
                      CellFrameColor      -> GrayLevel[ 0.85 ],
                      FontSize            -> $birdFontSize,
                      LineSpacing         -> { 1.1, 0, 2 },
                      ShowAutoSpellCheck  -> False,
                      CellElementSpacings -> {
                          "CellMinHeight"    -> 0,
                          "ClosedCellHeight" -> 0
                      },
                      CellFrameLabels    -> {
                          { Cell @ BoxData @ TemplateBox[ { }, "AssistantIcon" ], None },
                          { None, None }
                      },
                      ContextMenu -> {
                          MenuItem[
                              "Ask AI Assistant",
                              KernelExecute @ ToExpression[ "ResourceFunction[\"BirdChat\"][\"Ask\"]" ],
                              MenuEvaluator -> Automatic,
                              Method -> "Queued"
                          ],
                          Delimiter,
                          MenuItem[ "Cu&t", "Cut" ],
                          MenuItem[ "&Copy", "Copy" ],
                          MenuItem[ "&Paste", FrontEnd`Paste @ After ],
                          Menu[
                              "Cop&y As",
                              {
                                  MenuItem[ "Plain &Text", FrontEnd`CopySpecial[ "PlainText" ] ],
                                  MenuItem[ "&Input Text", FrontEnd`CopySpecial[ "InputText" ] ],
                                  MenuItem[
                                      "&LaTeX",
                                      KernelExecute @ ToExpression[ "FrontEnd`CopyAsTeX[]" ],
                                      MenuEvaluator -> "System"
                                  ],
                                  MenuItem[
                                      "M&athML",
                                      KernelExecute @ ToExpression[ "FrontEnd`CopyAsMathML[]" ],
                                      MenuEvaluator -> "System"
                                  ],
                                  Delimiter,
                                  MenuItem[ "Cell &Object", FrontEnd`CopySpecial[ "CellObject" ] ],
                                  MenuItem[
                                      "&Cell Expression",
                                      FrontEnd`CopySpecial[ "CellExpression" ]
                                  ],
                                  MenuItem[
                                      "&Notebook Expression",
                                      FrontEnd`CopySpecial[ "NotebookExpression" ]
                                  ]
                              }
                          ],
                          Delimiter,
                          MenuItem[ "Make &Hyperlink...", "CreateHyperlinkDialog" ],
                          MenuItem[
                              "Insert Table/&Matrix...",
                              FrontEndExecute @ {
                                  FrontEnd`NotebookOpen @ FrontEnd`FindFileOnPath[
                                      "InsertGrid.nb",
                                      "PrivatePathsSystemResources"
                                  ]
                              }
                          ],
                          MenuItem[ "Chec&k Spelling...", "FindNextMisspelling" ],
                          Menu[
                              "Citatio&n",
                              {
                                  MenuItem[
                                      "Insert Bibliographical &Reference...",
                                      "InsertBibReference"
                                  ],
                                  MenuItem[ "Insert Bibliographical &Note...", "InsertBibNote" ],
                                  Delimiter,
                                  MenuItem[ "Set / Change Citation &Style...", "SetCitationStyle" ],
                                  MenuItem[ "&Insert Bibliography and Notes", "InsertBibAndNotes" ],
                                  MenuItem[ "&Delete Bibliography and Notes", "DeleteBibAndNotes" ],
                                  MenuItem[ "Re&build Bibliography and Notes", "RebuildBibAndNotes" ]
                              }
                          ],
                          Delimiter,
                          Menu[
                              "Sty&le",
                              {
                                  MenuItem[
                                      "Start Cell Style Names",
                                      "MenuListStyles",
                                      System`MenuAnchor -> True
                                  ],
                                  Delimiter,
                                  MenuItem[ "&Other...", "StyleOther" ]
                              }
                          ],
                          Delimiter,
                          MenuItem[ "Create Inline Cell", "CreateInlineCell" ],
                          MenuItem[ "Di&vide Cell", "CellSplit" ],
                          MenuItem[ "Evaluate &in Place", All ],
                          Delimiter,
                          MenuItem[
                              "Toggle &Full Screen",
                              FrontEndExecute @ FrontEnd`Value @ FEPrivate`NotebookToggleFullScreen[ ]
                          ]
                      }
                ],
                Cell[ StyleData[ "Input" ],
                      StyleKeyMapping -> {
                        "~" -> "ChatDelimiter",
                        "/" -> "ChatInput",
                        "=" -> "WolframAlphaShort",
                        "*" -> "Item",
                        ">" -> "ExternalLanguageDefault"
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
                ],
                Cell[ StyleData[ "ChatDelimiter" ],
                      Background             -> GrayLevel[ 0.95 ],
                      CellBracketOptions     -> { "OverlapContent" -> True },
                      CellElementSpacings    -> { "CellMinHeight" -> 6 },
                      CellFrameMargins       -> { { 20, 20 }, { 2, 2 } },
                      CellGroupingRules      -> { "SectionGrouping", 58 },
                      CellMargins            -> { { 0, 0 }, { 10, 10 } },
                      DefaultNewCellStyle    -> "Input",
                      FontSize               -> 6,
                      Selectable             -> False,
                      ShowCellBracket        -> False,
                      Evaluatable            -> True,
                      CellEvaluationFunction -> Function[ $Line = 0; ],
                      ShowCellLabel          -> False
                ]
            },
            StyleDefinitions -> "PrivateStylesheetFormatting.nb"
        ]
    ];
(* :!CodeAnalysis::EndBlock:: *)

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


evaluateLanguageLabel // ClearAll;

evaluateLanguageLabel[ name_String ] :=
    With[ { icon = $languageIcons @ name },
        fancyTooltip[
            MouseAppearance[ buttonMouseover[ buttonFrameDefault @ icon, buttonFrameActive @ icon ], "LinkHand" ],
            "Insert content as new input cell below and evaluate"
        ] /; MatchQ[ icon, _Graphics | _Image ]
    ];

evaluateLanguageLabel[ ___ ] := $insertEvaluateButtonLabel;


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
buttonPane[ expr_ ] := Pane[ expr, ImageSize -> { 24, 24 }, ImageSizeAction -> "ShrinkToFit", Alignment -> { Center, Center } ];

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
getAssistantIcon[ as_, None ] := Graphics[ { }, ImageSize -> 1 ];
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
getAssistantIconActive[ as_, None ] := Graphics[ { }, ImageSize -> 1 ];
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
        KeyDrop[ Association[ $defaultBirdChatSettings, bcOpts, FilterRules[ { opts }, bcOpts ], as ], "OpenAIKey" ]
    ];

makeBirdChatSettings[ opts: OptionsPattern[ BirdChat ] ] := makeBirdChatSettings[ <| |>, opts ];

makeBirdChatSettings // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*BirdChat Commands*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*executeBirdChatCommand*)
executeBirdChatCommand // beginDefinition;
executeBirdChatCommand[ "RequestBirdChat", args___ ] := requestBirdChat @ args;
executeBirdChatCommand[ "Loaded"         , args___ ] := $birdChatLoaded;
executeBirdChatCommand[ "SetRole"        , args___ ] := setBirdChatRole @ args;
executeBirdChatCommand[ "Ask"            , args___ ] := askBirdChat @ args;
executeBirdChatCommand // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setBirdChatRole*)
setBirdChatRole[ role_String ] := setBirdChatRole[ InputNotebook[ ], role ];
setBirdChatRole[ nbo_NotebookObject, role_String ] := (
    CurrentValue[ nbo, { TaggingRules, "BirdChatSettings", "RolePrompt" } ] = role;
    Null
);

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*askBirdChat*)
askBirdChat // beginDefinition;

askBirdChat[ ] := askBirdChat[ InputNotebook[ ] ];
askBirdChat[ nbo_NotebookObject ] := askBirdChat[ nbo, SelectedCells @ nbo ];
askBirdChat[ nbo_NotebookObject, { selected_CellObject } ] :=
    Module[ { selection, cell, obj },
        selection = NotebookRead @ nbo;
        cell = chatQueryCell @ selection;
        SelectionMove[ selected, After, Cell ];
        obj = $lastQueryCell = cellPrint @ cell;
        SelectionMove[ obj, All, Cell ];
        SelectionEvaluateCreateCell @ nbo
    ];

askBirdChat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*chatQueryCell*)
chatQueryCell // beginDefinition;
chatQueryCell[ s_String ] := Cell[ StringTrim @ s, "ChatQuery", GeneratedCell -> False, CellAutoOverwrite -> False ];
chatQueryCell[ boxes_ ] := Cell[ BoxData @ boxes, "ChatQuery", GeneratedCell -> False, CellAutoOverwrite -> False ];
chatQueryCell // endDefinition;

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

requestBirdChat[ evalCell_CellObject, nbo_NotebookObject, settings_Association? AssociationQ ] :=
    requestBirdChat[ evalCell, nbo, settings, Lookup[ settings, "ShowMinimized", Automatic ] ];

requestBirdChat[ evalCell_, nbo_, settings_, Automatic ] /; CloudSystem`$CloudNotebooks :=
    requestBirdChat[ evalCell, nbo, settings, False ];

requestBirdChat[ evalCell_, nbo_, settings_, Automatic ] :=
    Block[ { $autoOpen, $alwaysOpen },
        $autoOpen = $alwaysOpen = MemberQ[ CurrentValue[ evalCell, CellStyle ], "Text"|"ChatInput"|"ChatQuery" ];
        requestBirdChat0[ evalCell, nbo, settings ]
    ];

requestBirdChat[ evalCell_, nbo_, settings_, minimized_ ] :=
    Block[ { $alwaysOpen = alwaysOpenQ[ settings, minimized ] },
        requestBirdChat0[ evalCell, nbo, settings ]
    ];

requestBirdChat // endDefinition;



requestBirdChat0 // beginDefinition;

requestBirdChat0[ evalCell_, nbo_, settings_ ] := catchTop @ Enclose[
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
        cell = activeBirdChatCell[ container, settings ];

        Quiet[
            TaskRemove @ $lastTask;
            NotebookDelete @ $lastCellObject;
        ];

        $resultCellCache = <| |>;
        $debugLog = Internal`Bag[ ];
        cellObject = $lastCellObject = cellPrint @ cell;

        task = Confirm[ $lastTask = submitBirdChat[ req, container, done, cellObject ] ]
    ],
    throwInternalFailure[ requestBirdChat0[ evalCell, nbo, settings ], ## ] &
];

requestBirdChat0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*alwaysOpenQ*)
alwaysOpenQ // beginDefinition;
alwaysOpenQ[ as_, True  ] := False;
alwaysOpenQ[ as_, False ] := True;
alwaysOpenQ[ as_, _     ] := StringQ @ as[ "RolePrompt" ] && StringFreeQ[ as[ "RolePrompt" ], $$severityTag ];
alwaysOpenQ // endDefinition;

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
        text = $lastMessageText = extractMessageText @ json;
        checkResponse[ text, cellObject, json ]
    ],
    # & (* TODO: cloud error cell *)
];

submitBirdChat[ req_, container_, done_, cellObject_ ] :=
    With[ { autoOpen = TrueQ @ $autoOpen, alwaysOpen = TrueQ @ $alwaysOpen },
        URLSubmit[
            req,
            HandlerFunctions -> <|
                "BodyChunkReceived" -> Function[
                    catchTop @ Block[ { $autoOpen = autoOpen, $alwaysOpen = alwaysOpen },
                        Internal`StuffBag[ $debugLog, $lastStatus = #1 ];
                        writeChunk[ Dynamic @ container, cellObject, #1 ]
                    ]
                ],
                "TaskFinished" -> Function[
                    catchTop @ Block[ { $autoOpen = autoOpen, $alwaysOpen = alwaysOpen },
                        Internal`StuffBag[ $debugLog, $lastStatus = #1 ];
                        done = True;
                        checkResponse[ container, cellObject, #1 ]
                    ]
                ]
            |>,
            HandlerFunctionsKeys -> { "BodyChunk", "StatusCode", "Task", "TaskStatus", "EventName" },
            CharacterEncoding    -> "UTF8"
        ]
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
] ] := untagString @ message;

extractMessageText // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*activeBirdChatCell*)
activeBirdChatCell // beginDefinition;
activeBirdChatCell // Attributes = { HoldFirst };

activeBirdChatCell[ container_, settings_ ] /; CloudSystem`$CloudNotebooks := (
    Cell[
        BoxData @ ToBoxes @ ProgressIndicator[ Appearance -> "Percolate" ],
        "Output",
        "ChatOutput",
        CellFrameLabels -> {
            { Cell @ BoxData @ TemplateBox[ { }, "AssistantIconActive" ], None },
            { None, None }
        }
    ]
);

activeBirdChatCell[ container_, settings_Association? AssociationQ ] :=
    activeBirdChatCell[ container, settings, Lookup[ settings, "ShowMinimized", Automatic ] ];

activeBirdChatCell[ container_, settings_, minimized_ ] :=
    With[ { label = activeChatIcon[ ], id = $SessionID },
        (* Print @ Dynamic @ Refresh[
            RawBoxes @ Cell[ TextData @ reformatTextData @ container, "ChatOutput", "Text" ],
            TrackedSymbols :> { },
            UpdateInterval -> 1
        ]; *)
        Cell[
            BoxData @ ToBoxes @ Dynamic[
                Refresh[
                    dynamicTextDisplay @ container,
                    TrackedSymbols :> { },
                    UpdateInterval -> 0.2
                ],
                Initialization :> If[ $SessionID =!= id, NotebookDelete @ EvaluationCell[ ] ]
            ],
            "Output",
            "ChatOutput",
            If[ MatchQ[ minimized, True|Automatic ],
                Sequence @@ Flatten[ {
                    $closedBirdCellOptions,
                    Initialization :> attachMinimizedIcon[ EvaluationCell[ ], label ]
                } ],
                Sequence @@ { }
            ],
            Selectable      -> False,
            Editable        -> False,
            CellFrameLabels -> {
                { Cell @ BoxData @ TemplateBox[ { }, "AssistantIconActive" ], None },
                { None, None }
            }
        ]
    ];

activeBirdChatCell // endDefinition;


dynamicTextDisplay // beginDefinition;

dynamicTextDisplay[ text_String ] :=
    Block[ { $dynamicText = True },
        RawBoxes @ Cell[ TextData @ reformatTextData @ text ]
    ];

dynamicTextDisplay[ _Symbol ] := ProgressIndicator[ Appearance -> "Percolate" ];

dynamicTextDisplay[ other_ ] := other;

dynamicTextDisplay // endDefinition;


$closedBirdCellOptions = Sequence[
    CellMargins     -> -2,
    CellOpen        -> False,
    CellFrame       -> 0,
    ShowCellBracket -> False
];

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
    writeReformattedCell[ container, cell ];
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
        "ChatOutput",
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
    makeHTTPRequest[ settings, selectChatCells[ settings, cell, nbo ] ];

makeHTTPRequest[ settings_Association? AssociationQ, cells: { __CellObject } ] :=
    makeHTTPRequest[ settings, notebookRead @ cells ];

makeHTTPRequest[ settings_Association? AssociationQ, cells: { __Cell } ] :=
    Module[ { role, messages, merged },
        role = makeCurrentRole @ settings;
        messages = Prepend[ makeCellMessage /@ cells, role ];
        merged = If[ TrueQ @ Lookup[ settings, "MergeMessages" ], mergeMessageData @ messages, messages ];
        makeHTTPRequest[ settings, merged ]
    ];

makeHTTPRequest[ settings_Association? AssociationQ, messages: { __Association } ] :=
    Enclose @ Module[
        { key, stream, model, tokens, temperature, topP, freqPenalty, presPenalty, data, body },

        $lastSettings = settings;
        $lastMessages = messages;

        key         = ConfirmBy[ Lookup[ settings, "OpenAIKey" ], StringQ ];
        stream      = ! TrueQ @ CloudSystem`$CloudNotebooks;

        (* model parameters *)
        model       = Lookup[ settings, "Model"           , "gpt-3.5-turbo" ];
        tokens      = Lookup[ settings, "MaxTokens"       , 1024            ];
        temperature = Lookup[ settings, "Temperature"     , 0.7             ];
        topP        = Lookup[ settings, "TopP"            , 1               ];
        freqPenalty = Lookup[ settings, "FrequencyPenalty", 0.1             ];
        presPenalty = Lookup[ settings, "PresencePenalty" , 0.1             ];

        data = <|
            "messages"          -> messages,
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
makeCurrentRole[ as_Association? AssociationQ ] := makeCurrentRole[ as, as[ "RolePrompt" ], as[ "AssistantName" ] ];
makeCurrentRole[ as_, role_String, _ ] := <| "role" -> "system", "content" -> role |>;
makeCurrentRole[ as_, Automatic, name_String ] := <| "role" -> "system", "content" -> namedRolePrompt @ name |>;
makeCurrentRole[ as_, _, _ ] := $defaultRole;
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
    Module[ { trailing, include, styles, delete, included, flat, filtered },
        trailing = { trailing0 };
        include = Keys @ TakeWhile[ AssociationThread[ trailing -> CurrentValue[ trailing, GeneratedCell ] ], TrueQ ];
        styles = cellStyles @ include;
        delete = Keys @ Select[ AssociationThread[ include -> MemberQ[ "ChatOutput" ] /@ styles ], TrueQ ];
        NotebookDelete @ delete;
        included = DeleteCases[ include, Alternatives @@ delete ];
        flat = dropDelimitedCells @ Flatten @ { cells, cell, included };
        filtered = clearMinimizedChats[ parentNotebook @ cell, flat ];
        Reverse @ Take[ Reverse @ filtered, UpTo @ $maxChatCells ]
    ];

selectChatCells0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*clearMinimizedChats*)
clearMinimizedChats // beginDefinition;

clearMinimizedChats[ nbo_, cells_ ] /; CloudSystem`$CloudNotebooks := cells;

clearMinimizedChats[ nbo_NotebookObject, cells_List ] :=
    Module[ { outCells, closed, attached },
        outCells = Cells[ nbo, CellStyle -> "ChatOutput" ];
        closed = Keys @ Select[ AssociationThread[ outCells -> CurrentValue[ outCells, CellOpen ] ], Not ];
        attached = Cells[ nbo, AttachedCell -> True, CellStyle -> "MinimizedChatIcon" ];
        NotebookDelete @ Flatten @ { closed, attached };
        DeleteCases[ cells, Alternatives @@ closed ]
    ];

clearMinimizedChats // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*clearMinimizedChat*)
clearMinimizedChat // beginDefinition;

clearMinimizedChat[ attached_CellObject, parentCell_CellObject ] :=
    Module[ { next },
        NotebookDelete @ attached;
        next = NextCell @ parentCell;
        If[ MemberQ[ cellStyles @ next, "ChatOutput" ] && TrueQ[ ! CurrentValue[ next, CellOpen ] ],
            NotebookDelete @ next;
            next,
            Nothing
        ]
    ];

clearMinimizedChat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*dropDelimitedCells*)
dropDelimitedCells // beginDefinition;

dropDelimitedCells[ cells_List ] :=
    Drop[ cells, Max[ Position[ cellStyles @ cells, { ___, "ChatDelimiter"|"PageBreak", ___ }, { 1 } ], 0 ] ];

dropDelimitedCells // endDefinition;

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
makeCellMessage[ cell: Cell[ __, "ChatOutput", ___ ] ] := <| "role" -> "assistant", "content" -> cellToString @ cell |>;
makeCellMessage[ cell_Cell ] := <| "role" -> "user", "content" -> cellToString @ cell |>;
makeCellMessage // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeChunk*)
writeChunk // beginDefinition;

writeChunk[ container_, cell_, KeyValuePattern[ "BodyChunk" -> chunk_String ] ] :=
    writeChunk[ container, cell, chunk ];

writeChunk[ container_, cell_, chunk_String ] /; StringMatchQ[ chunk, "data: " ~~ __ ~~ "\n\n" ~~ __ ~~ ("\n\n"|"") ] :=
    writeChunk[ container, cell, # ] & /@ StringSplit[ chunk, "\n\n" ];

writeChunk[ container_, cell_, chunk_String ] /; StringMatchQ[ chunk, "data: " ~~ __ ~~ ("\n\n"|"") ] :=
    Module[ { json },
        json = StringDelete[ chunk, { StartOfString~~"data: ", ("\n\n"|"") ~~ EndOfString } ];
        writeChunk[ container, cell, chunk, Quiet @ Developer`ReadRawJSONString @ json ]
    ];

writeChunk[ container_, cell_, "" | "data: [DONE]" | "data: [DONE]\n\n" ] := Null;

writeChunk[
    container_,
    cell_,
    chunk_String,
    KeyValuePattern[ "choices" -> { KeyValuePattern[ "delta" -> KeyValuePattern[ "content" -> text_String ] ], ___ } ]
] := writeChunk[ container, cell, chunk, text ];

writeChunk[
    container_,
    cell_,
    chunk_String,
    KeyValuePattern[ "choices" -> { KeyValuePattern @ { "delta" -> <| |>, "finish_reason" -> "stop" }, ___ } ]
] := Null;

writeChunk[ Dynamic[ container_ ], cell_, chunk_String, text_String ] := (
    If[ StringQ @ container,
        container = StringDelete[ container <> convertUTF8 @ text, StartOfString~~Whitespace ],
        container = convertUTF8 @ text
    ];
    Which[
        errorTaggedQ @ container, processErrorCell[ container, cell ],
        warningTaggedQ @ container, processWarningCell[ container, cell ],
        infoTaggedQ @ container, processInfoCell[ container, cell ],
        untaggedQ @ container, openBirdCell @ cell,
        True, Null
    ]
);

writeChunk[ Dynamic[ container_ ], cell_, chunk_String, other_ ] := Null;

writeChunk // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Severity Tag String Patterns*)
$$whitespace  = Longest[ WhitespaceCharacter... ];
$$severityTag = "ERROR"|"WARNING"|"INFO";
$$tagPrefix   = StartOfString~~$$whitespace~~"["~~$$whitespace~~$$severityTag~~$$whitespace~~"]"~~$$whitespace;


errorTaggedQ // ClearAll;
errorTaggedQ[ s_String? StringQ ] := taggedQ[ s, "ERROR" ];
errorTaggedQ[ ___               ] := False;


warningTaggedQ // ClearAll;
warningTaggedQ[ s_String? StringQ ] := taggedQ[ s, "WARNING" ];
warningTaggedQ[ ___               ] := False;


infoTaggedQ // ClearAll;
infoTaggedQ[ s_String? StringQ ] := taggedQ[ s, "INFO" ];
infoTaggedQ[ ___               ] := False;


untaggedQ // ClearAll;
untaggedQ[ s_String? StringQ ] /; $alwaysOpen := StringStartsQ[ $lastUntagged = StringDelete[ s, Whitespace ], Except[ "[" ] ];
untaggedQ[ ___ ] := False;


taggedQ // ClearAll;
taggedQ[ s_String? StringQ ] := taggedQ[ s, $$severityTag ];
taggedQ[ s_String? StringQ, tag_ ] := StringStartsQ[ StringDelete[ s, Whitespace ], "["~~tag~~"]", IgnoreCase -> True ];
taggedQ[ ___ ] := False;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*removeSeverityTag*)
removeSeverityTag // beginDefinition;
removeSeverityTag // Attributes = { HoldFirst };

removeSeverityTag[ s_Symbol? StringQ, cell_CellObject ] :=
    Module[ { tag },
        tag = StringReplace[ s, t:$$tagPrefix~~___~~EndOfString :> t ];
        s = untagString @ s;
        CurrentValue[ cell, { TaggingRules, "MessageTag" } ] = ToUpperCase @ StringDelete[ tag, Whitespace ]
    ];

removeSeverityTag // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*untagString*)
untagString // beginDefinition;
untagString[ str_String? StringQ ] := StringDelete[ str, $$tagPrefix, IgnoreCase -> True ];
untagString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*processErrorCell*)
processErrorCell // beginDefinition;
processErrorCell // Attributes = { HoldFirst };

processErrorCell[ container_, cell_CellObject ] := (
    $$errorString = container;
    removeSeverityTag[ container, cell ];
    (* TODO: Add an error icon? *)
    openBirdCell @ cell
);

processErrorCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*processWarningCell*)
processWarningCell // beginDefinition;
processWarningCell // Attributes = { HoldFirst };

processWarningCell[ container_, cell_CellObject ] := (
    $$warningString = container;
    removeSeverityTag[ container, cell ];
    openBirdCell @ cell
);

processWarningCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*processInfoCell*)
processInfoCell // beginDefinition;
processInfoCell // Attributes = { HoldFirst };

processInfoCell[ container_, cell_CellObject ] := (
    $$infoString = container;
    removeSeverityTag[ container, cell ];
    $lastAutoOpen = $autoOpen;
    If[ TrueQ @ $autoOpen, openBirdCell @ cell ]
);

processInfoCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*openBirdCell*)
openBirdCell // beginDefinition;

openBirdCell[ cell_CellObject ] :=
    Module[ { prev, attached },
        prev = PreviousCell @ cell;
        attached = Cells[ prev, AttachedCell -> True, CellStyle -> "MinimizedChatIcon" ];
        NotebookDelete @ attached;
        SetOptions[
            cell,
            CellMargins     -> Inherited,
            CellOpen        -> Inherited,
            CellFrame       -> Inherited,
            ShowCellBracket -> Inherited,
            Initialization  -> Inherited
        ]
    ];

openBirdCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*attachMinimizedIcon*)
attachMinimizedIcon // beginDefinition;

attachMinimizedIcon[ chatCell_CellObject, label_ ] :=
    Module[ { prev, cell },
        prev = PreviousCell @ chatCell;
        CurrentValue[ chatCell, Initialization ] = Inherited;
        cell = makeMinimizedIconCell[ label, chatCell ];
        NotebookDelete @ Cells[ prev, AttachedCell -> True, CellStyle -> "MinimizedChatIcon" ];
        With[ { prev = prev, cell = cell },
            If[ TrueQ @ BoxForm`sufficientVersionQ[ 13.2 ],
                FE`Evaluate @ FEPrivate`AddCellTrayWidget[ prev, "MinimizedChatIcon" -> <| "Content" -> cell |> ],
                AttachCell[ prev, cell, { "CellBracket", Top }, { 0, 0 }, { Right, Top } ]
            ]
        ]
    ];

attachMinimizedIcon // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeMinimizedIconCell*)
makeMinimizedIconCell // beginDefinition;

makeMinimizedIconCell[ label_, chatCell_CellObject ] :=
    Cell[ BoxData @ MakeBoxes @ Button[
              MouseAppearance[ label, "LinkHand" ],
              With[ { attached = EvaluationCell[ ] }, NotebookDelete @ attached;
              openBirdCell @ chatCell ],
              Appearance -> None
          ],
          "MinimizedChatIcon"
    ];

makeMinimizedIconCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertUTF8*)
convertUTF8 // beginDefinition;
convertUTF8[ string_String ] := FromCharacterCode[ ToCharacterCode @ string, "UTF-8" ];
convertUTF8 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeReformattedCell*)
writeReformattedCell // beginDefinition;

writeReformattedCell[ string_String, cell_CellObject ] :=
    With[
        {
            tag   = CurrentValue[ cell, { TaggingRules, "MessageTag" } ],
            open  = $lastOpen = cellOpenQ @ cell,
            label = staticChatIcon[ ]
        },
        NotebookWrite[
            cell,
            $reformattedCell = reformatCell[ string, tag, open, label ],
            None,
            AutoScroll -> False
        ]
    ];

writeReformattedCell[ other_, cell_CellObject ] :=
    NotebookWrite[
        cell,
        Cell[
            TextData @ {
                "I can't believe you've done this! \n\n",
                Cell @ BoxData @ ToBoxes @ Catch[ throwInternalFailure @ writeReformattedCell[ other, cell ], $top ]
            },
            "Text",
            "ChatOutput",
            GeneratedCell     -> True,
            CellAutoOverwrite -> True
        ],
        None,
        AutoScroll -> False
    ];

writeReformattedCell // endDefinition;


(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*reformatCell*)
reformatCell // beginDefinition;

reformatCell[ string_, tag_, open_, label_ ] := Cell[
    TextData @ reformatTextData @ string,
    "Text",
    "ChatOutput",
    GeneratedCell     -> True,
    CellAutoOverwrite -> True,
    TaggingRules      -> <| "SourceString" -> string, "MessageTag" -> tag |>,
    If[ TrueQ @ open,
        Sequence @@ { },
        Sequence @@ Flatten @ {
            $closedBirdCellOptions,
            Initialization :> attachMinimizedIcon[ EvaluationCell[ ], label ]
        }
    ]
];

reformatCell // endDefinition;

reformatTextData // beginDefinition;

reformatTextData[ string_String ] := Flatten @ Map[
    makeResultCell,
    StringSplit[
        $reformattedString = string,
        {
            StringExpression[
                    Longest[ "```" ~~ lang: Except[ WhitespaceCharacter ].. /; externalLanguageQ @ lang ],
                    Shortest[ code__ ] ~~ "```"
                ] :> externalCodeCell[ lang, code ],
            Longest[ "```" ~~ ($wlCodeString|"") ] ~~ Shortest[ code__ ] ~~ "```" :>
                If[ NameQ[ "System`"<>code ], inlineCodeCell @ code, codeCell @ code ],
            "[" ~~ label: Except[ "[" ].. ~~ "](" ~~ url: Except[ ")" ].. ~~ ")" :> hyperlinkCell[ label, url ],
            "``" ~~ code: Except[ "`" ].. ~~ "``" :> inlineCodeCell @ code,
            "`" ~~ code: Except[ "`" ].. ~~ "`" :> inlineCodeCell @ code,
            "$$" ~~ math: Except[ "$" ].. ~~ "$$" :> mathCell @ math,
            "$" ~~ math: Except[ "$" ].. ~~ "$" :> mathCell @ math
        },
        IgnoreCase -> True
    ]
];

reformatTextData[ other_ ] := other;

reformatTextData // endDefinition;


$wlCodeString = Longest @ Alternatives[
    "Wolfram Language",
    "WolframLanguage",
    "Wolfram",
    "Mathematica"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*externalLanguageQ*)
externalLanguageQ // ClearAll;

externalLanguageQ[ $$externalLanguage ] := True;

externalLanguageQ[ str_String? StringQ ] := externalLanguageQ[ str ] =
    StringMatchQ[
        StringReplace[ StringTrim @ str, $externalLanguageRules, IgnoreCase -> True ],
        $$externalLanguage,
        IgnoreCase -> True
    ];

externalLanguageQ[ ___ ] := False;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellOpenQ*)
cellOpenQ // beginDefinition;
cellOpenQ[ cell_CellObject ] /; CloudSystem`$CloudNotebooks := Lookup[ Options[ cell, CellOpen ], CellOpen, True ];
cellOpenQ[ cell_CellObject ] := CurrentValue[ cell, CellOpen ];
cellOpenQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeResultCell*)
makeResultCell // beginDefinition;

makeResultCell[ expr_ ] /; $dynamicText :=
    Lookup[ $resultCellCache,
            HoldComplete @ expr,
            $resultCellCache[ HoldComplete @ expr ] = makeResultCell0 @ expr
    ];

makeResultCell[ expr_ ] := makeResultCell0 @ expr;

makeResultCell // endDefinition;


$resultCellCache = <| |>;


makeResultCell0 // beginDefinition;

makeResultCell0[ str_String ] := formatTextString @ str;

makeResultCell0[ codeCell[ code_String ] ] := makeInteractiveCodeCell @ StringTrim @ code;

makeResultCell0[ externalCodeCell[ lang_String, code_String ] ] :=
    makeInteractiveCodeCell[
        StringReplace[ StringTrim @ lang, $externalLanguageRules, IgnoreCase -> True ],
        StringTrim @ code
    ];

makeResultCell0[ inlineCodeCell[ code_String ] ] := Cell[
    BoxData @ stringTemplateInput @ code,
    "InlineFormula",
    FontFamily -> "Source Sans Pro"
];

makeResultCell0[ mathCell[ math_String ] ] :=
    With[ { boxes = Quiet @ InputAssistant`TeXAssistant @ StringTrim @ math },
        If[ MatchQ[ boxes, _RawBoxes ],
            Cell @ BoxData @ FormBox[ ToBoxes @ boxes, TraditionalForm ],
            makeResultCell0 @ inlineCodeCell @ math
        ]
    ];

makeResultCell0[ hyperlinkCell[ label_String, url_String ] ] := hyperlink[ label, url ];

makeResultCell0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatTextString*)
formatTextString // beginDefinition;
formatTextString[ str_String ] := StringSplit[ str, $stringFormatRules, IgnoreCase -> True ];
formatTextString // endDefinition;

$stringFormatRules = {
    "[" ~~ label: Except[ "[" ].. ~~ "](" ~~ url: Except[ ")" ].. ~~ ")" :> hyperlink[ label, url ],
    "***" ~~ text: Except[ "*" ].. ~~ "***" :> styleBox[ text, FontWeight -> Bold, FontSlant -> Italic ],
    "___" ~~ text: Except[ "_" ].. ~~ "___" :> styleBox[ text, FontWeight -> Bold, FontSlant -> Italic ],
    "**" ~~ text: Except[ "*" ].. ~~ "**" :> styleBox[ text, FontWeight -> Bold ],
    "__" ~~ text: Except[ "_" ].. ~~ "__" :> styleBox[ text, FontWeight -> Bold ],
    "*" ~~ text: Except[ "*" ].. ~~ "*" :> styleBox[ text, FontSlant -> Italic ],
    "_" ~~ text: Except[ "_" ].. ~~ "_" :> styleBox[ text, FontSlant -> Italic ]
};

styleBox // ClearAll;

styleBox[ text_String, a___ ] := styleBox[ formatTextString @ text, a ];
styleBox[ { text: _ButtonBox|_String }, a___ ] := StyleBox[ text, a ];
styleBox[ { (h: Cell|StyleBox)[ text_, a___ ] }, b___ ] := DeleteDuplicates @ StyleBox[ text, a, b ];

styleBox[ { a___, b: Except[ _ButtonBox|_Cell|_String|_StyleBox ], c___ }, d___ ] :=
    styleBox[ { a, Cell @ BoxData @ b, c }, d ];

styleBox[ a_, ___ ] := a;


hyperlink // ClearAll;

hyperlink[ label_String, uri_String ] /; StringStartsQ[ uri, "paclet:" ] := Cell[
    BoxData @ TagBox[
        ButtonBox[
            StyleBox[
                StringTrim[ label, (Whitespace|"`").. ],
                "SymbolsRefLink",
                ShowStringCharacters -> True,
                FontFamily -> "Source Sans Pro"
            ],
            BaseStyle ->
                Dynamic @ FEPrivate`If[
                    CurrentValue[ "MouseOver" ],
                    { "Link", FontColor -> RGBColor[ 0.8549, 0.39608, 0.1451 ] },
                    { "Link" }
                ],
            ButtonData -> uri,
            ContentPadding -> False
        ],
        MouseAppearanceTag[ "LinkHand" ]
    ],
    "InlineFormula",
    FontFamily -> "Source Sans Pro"
];

hyperlink[ label_String, url_String ] := hyperlink[ formatTextString @ label, url ];

hyperlink[ { label: _String|_StyleBox }, url_ ] := ButtonBox[
    label,
    BaseStyle  -> "Hyperlink",
    ButtonData -> { URL @ url, None },
    ButtonNote -> url
];

hyperlink[ a_, ___ ] := a;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeInteractiveCodeCell*)
makeInteractiveCodeCell // beginDefinition;

makeInteractiveCodeCell[ string_String ] /; $dynamicText :=
    Cell[
        BoxData @ string,
        "Input",
        Background           -> GrayLevel[ 0.95 ],
        CellFrame            -> GrayLevel[ 0.99 ],
        FontSize             -> $birdFontSize,
        ShowAutoStyles       -> False,
        ShowStringCharacters -> True,
        ShowSyntaxStyles     -> True,
        LanguageCategory     -> "Input"
    ];

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
            ShowStringCharacters -> True,
            ShowSyntaxStyles     -> True,
            LanguageCategory     -> "Input"
        ];

        handler = inlineInteractiveCodeCell[ display, string ];

        Cell @ BoxData @ ToBoxes @ handler
    ];

makeInteractiveCodeCell[ lang_String, code_String ] :=
    Module[ { cell, display, handler },
        cell = Cell[ code, "ExternalLanguage", FontSize -> $birdFontSize, System`CellEvaluationLanguage -> lang ];
        display = RawBoxes @ cell;
        handler = inlineInteractiveCodeCell[ display, cell ];
        Cell @ BoxData @ ToBoxes @ handler
    ];

makeInteractiveCodeCell // endDefinition;


inlineInteractiveCodeCell // beginDefinition;

inlineInteractiveCodeCell[ display_, string_ ] /; $dynamicText := display;

inlineInteractiveCodeCell[ display_, string_String ] /; CloudSystem`$CloudNotebooks :=
    Button[ display, CellPrint @ Cell[ BoxData @ string, "Input" ], Appearance -> None ];

inlineInteractiveCodeCell[ display_, cell_Cell ] /; CloudSystem`$CloudNotebooks :=
    Button[ display, CellPrint @ cell, Appearance -> None ];

inlineInteractiveCodeCell[ display_, string_ ] :=
    inlineInteractiveCodeCell[ display, string, contentLanguage @ string ];

inlineInteractiveCodeCell[ display_, string_, lang_ ] :=
    DynamicModule[ { attached },
        EventHandler[
            display,
            {
                "MouseEntered" :>
                    If[ TrueQ @ $birdChatLoaded,
                        attached =
                            AttachCell[
                                EvaluationCell[ ],
                                floatingButtonGrid[ attached, string, lang ],
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
floatingButtonGrid[ attached_, string_, lang_ ] := Framed[
    Grid[
        {
            {
                button[ $copyToClipboardButtonLabel, NotebookDelete @ attached; CopyToClipboard @ string ],
                button[ $insertInputButtonLabel, insertCodeBelow[ string, False ]; NotebookDelete @ attached ],
                button[ evaluateLanguageLabel @ lang, insertCodeBelow[ string, True ]; NotebookDelete @ attached ]
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

insertCodeBelow[ cell_Cell, evaluate_: False ] :=
    Module[ { cellObj, nbo },
        cellObj = topParentCell @ EvaluationCell[ ];
        nbo  = parentNotebook @ cellObj;
        SelectionMove[ cellObj, After, Cell ];
        NotebookWrite[ nbo, cell, All ];
        If[ TrueQ @ evaluate,
            SelectionEvaluateCreateCell @ nbo,
            SelectionMove[ nbo, After, CellContents ]
        ]
    ];

insertCodeBelow[ string_String, evaluate_: False ] := insertCodeBelow[ Cell[ BoxData @ string, "Input" ], evaluate ];


(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*contentLanguage*)
contentLanguage // ClearAll;
contentLanguage[ Cell[ __, "CellEvaluationLanguage" -> lang_String, ___ ] ] := lang;
contentLanguage[ Cell[ __, System`CellEvaluationLanguage -> lang_String, ___ ] ] := lang;
contentLanguage[ ___ ] := "Wolfram";

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*topParentCell*)
topParentCell // beginDefinition;
topParentCell[ cell_CellObject ] := With[ { p = ParentCell @ cell }, topParentCell @ p /; MatchQ[ p, _CellObject ] ];
topParentCell[ cell_CellObject ] := cell;
topParentCell // endDefinition;

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

stringTemplateInput[ s_String? StringQ ] :=
    UsingFrontEnd @ Enclose @ Confirm[ stringTemplateInput0 ][ s ];

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
$maxOutputCellStringLength = 500;

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

cellToString[ Cell[ a__, "ChatInput", b___, CellLabel -> _, c___ ] ] :=
    cellToString @ Cell[ a, b, c ];

cellToString[ Cell[ a__, "ChatQuery", b___, CellLabel -> _, c___ ] ] :=
    StringJoin[
        "Please explain the following query text to me:\n---\n",
        cellToString @ Cell[ a, b, c ], "\n---\n",
        "Try to include information about how this relates to the Wolfram Language if it makes sense to do so.\n\n",
        "If there are any relevant search results, feel free to use them in your explanation. ",
        "Do not include search results that are not relevant to the query.\n\n",
        docSearchResultString @ a
    ];

cellToString[ Cell[ __, "ChatDelimiter", ___ ] ] := "\n---\n";

cellToString[ Cell[ a___, CellLabel -> label_String, b___ ] ] :=
    With[ { str = cellToString @ Cell[ a, b ] }, label<>" "<>str /; StringQ @ str ];

cellToString[ Cell[ __, TaggingRules -> KeyValuePattern[ "SourceString" -> string_String ], ___ ] ] := string;

cellToString[ Cell[ a__, style: $$specialStyle, b___ ] ] :=
    With[ { str = cellToString @ Cell[ a, b ] },
        "(* ::"<>style<>":: *)\n(*"<>str<>"*)" /; StringQ @ str
    ];

cellToString[ Cell[ a_, "Message", "MSG", b___ ] ] :=
    Module[ { string, stacks, stack, stackString },
        { string, stacks } = $lastMessageStackReap = Reap[ cellToString0 @ Cell[ a, b ], $messageStack ];
        stack = First[ First[ stacks, $Failed ], $Failed ];
        If[ MatchQ[ stack, { __HoldForm } ] && Length @ stack >= 3,
            stackString = StringRiffle[
                Cases[
                    stack,
                    HoldForm[ expr_ ] :> ToString[ Unevaluated @ expr, InputForm, CharacterEncoding -> "UTF8" ]
                ],
                "\n"
            ];
            StringJoin[
                string,
                "\nBEGIN_STACK_TRACE\n",
                stackString,
                "\nEND_STACK_TRACE\n"
            ],
            string
        ]
    ];

cellToString[ cell_ ] := cellToString0 @ cell;

cellToString[ ___ ] := $Failed;


cellToString0[ cell_ ] := Catch[
    Module[ { string },
        string = fasterCellToString @ cell;
        If[ StringQ @ string, Throw[ string, $tag ] ];
        string = fastCellToString @ cell;
        If[ StringQ @ string, Throw[ string, $tag ] ];
        slowCellToString @ cell
    ],
    $tag
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*sowMessageData*)
sowMessageData // ClearAll;

sowMessageData[ { _, _, _, _, line_Integer, counter_Integer, session_Integer, _ } ] :=
    With[ { stack = $lastStack = MessageMenu`MessageStackList[ line, counter, session ] },
        Sow[ stack, $messageStack ] /; MatchQ[ stack, { ___HoldForm } ]
    ];

sowMessageData[ ___ ] := Null;

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

fasterCellToString0[ a_String /; StringMatchQ[ a, "\""~~___~~"\!"~~___~~"\"" ] ] :=
    With[ { res = ToString @ ToExpression[ a, InputForm ] },
        If[ TrueQ @ $showStringCharacters,
            res,
            StringTrim[ res, "\"" ]
        ] /; FreeQ[ res, s_String /; StringContainsQ[ s, "\!" ] ]
    ];

fasterCellToString0[ a_String /; StringContainsQ[ a, "\!" ] ] :=
    With[ { res = stringToBoxes @ a }, res /; FreeQ[ res, s_String /; StringContainsQ[ s, "\!" ] ] ];

fasterCellToString0[ a_String ] :=
    ToString[ If[ TrueQ @ $showStringCharacters, a, StringTrim[ a, "\"" ] ], CharacterEncoding -> "UTF8" ];

fasterCellToString0[ a: { ___String } ] := StringJoin @ Replace[ a, "," -> ", ", { 1 } ];

fasterCellToString0[ StyleBox[ _GraphicsBox, ___, "NewInGraphic", ___ ] ] := "";

fasterCellToString0[ NamespaceBox[
    "WolframAlphaQueryParseResults",
    DynamicModuleBox[
        { OrderlessPatternSequence[ Typeset`q$$ = query_String, Typeset`chosen$$ = code_String, ___ ] },
        ___
    ],
    ___
] ] := StringJoin[
    "WolframAlpha[\"", query, "\"]", "\n\n",
    "WOLFRAM_ALPHA_PARSED_INPUT: ", code, "\n\n"
];

fasterCellToString0[ NamespaceBox[
    "WolframAlphaQueryParseResults",
    DynamicModuleBox[ { ___, Typeset`chosen$$ = code_String, ___ }, ___ ],
    ___
] ] := code;

fasterCellToString0[ box: $graphicsHeads[ ___ ] ] /; ByteCount @ box < $maxOutputCellStringLength :=
    makeGraphicsString @ box;

fasterCellToString0[ $graphicsHeads[ ___ ] ] := "-Graphics-";
fasterCellToString0[ $stringStripHeads[ a_, ___ ] ] := fasterCellToString0 @ a;
fasterCellToString0[ $stringIgnoredHeads[ ___ ] ] := "";

fasterCellToString0[ TemplateBox[ args: { _, _, str_String, ___ }, "MessageTemplate" ] ] := (
    sowMessageData @ args;
    fasterCellToString0 @ str
);

fasterCellToString0[ TemplateBox[ args_, "RowDefault", ___ ] ] := fasterCellToString0 @ args;
fasterCellToString0[ TemplateBox[ { a_, ___ }, "PrettyTooltipTemplate", ___ ] ] := fasterCellToString0 @ a;

fasterCellToString0[ TemplateBox[ KeyValuePattern[ "boxes" -> box_ ], "LinguisticAssistantTemplate" ] ] :=
    fasterCellToString0 @ box;

fasterCellToString0[
    TemplateBox[ KeyValuePattern[ "label" -> label_String ], "NotebookObjectUUIDsUnsaved"|"NotebookObjectUUIDs" ]
] := "NotebookObject["<>label<>"]";

fasterCellToString0[ TemplateBox[ { _, box_, ___ }, "Entity" ] ] := fasterCellToString0 @ box;

fasterCellToString0[ SqrtBox[ a_ ] ] := "Sqrt["<>fasterCellToString0 @ a<>"]";
fasterCellToString0[ FractionBox[ a_, b_ ] ] := "(" <> fasterCellToString0 @ a <> "/" <> fasterCellToString0 @ b <> ")"

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

fasterCellToString0[ Cell[
    code_,
    "ExternalLanguage",
    ___,
    System`CellEvaluationLanguage|"CellEvaluationLanguage" -> lang_String,
    ___
] ] :=
    Module[ { string },
        string = fasterCellToString0 @ code;
        "ExternalEvaluate[\""<>lang<>"\", \""<>string<>"\"]" /; StringQ @ string
    ];

fasterCellToString0[ cell: Cell[ a_, ___ ] ] :=
    Block[ { $showStringCharacters = showStringCharactersQ @ cell },
        fasterCellToString0 @ a
    ];

fasterCellToString0[ InterpretationBox[ _, expr_, ___ ] ] :=
    ToString[ Unevaluated @ expr, InputForm, PageWidth -> 100, CharacterEncoding -> "UTF8" ];

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

fasterCellToString0[ a___ ] :=
    If[ TrueQ @ $catchingStringFail,
        Throw[ $Failed, $stringFail ],
        Internal`StuffBag[ $fasterCellToStringFailBag, HoldComplete @ a ];
        ""
    ];

$fasterCellToStringFailBag := $fasterCellToStringFailBag = Internal`Bag[ ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeGraphicsString*)
makeGraphicsString // beginDefinition;

makeGraphicsString[ gfx_ ] := makeGraphicsString[ gfx, makeGraphicsExpression @ gfx ];

makeGraphicsString[ gfx_, HoldComplete[ expr: _Graphics|_Graphics3D|_Image|_Image3D|_Graph ] ] :=
    StringReplace[
        ToString[ Unevaluated @ expr, InputForm, PageWidth -> 100, CharacterEncoding -> "UTF8" ],
        "\r\n" -> "\n"
    ];

makeGraphicsString[
    GraphicsBox[
        NamespaceBox[ "NetworkGraphics", DynamicModuleBox[ { ___, _ = HoldComplete @ Graph[ a___ ], ___ }, ___ ] ],
        ___
    ],
    _
] := "Graph[<<" <> ToString @ Length @ HoldComplete @ a <> ">>]";

makeGraphicsString[ GraphicsBox[ a___ ], _ ] :=
    "Graphics[<<" <> ToString @ Length @ HoldComplete @ a <> ">>]";

makeGraphicsString[ Graphics3DBox[ a___ ], _ ] :=
    "Graphics3D[<<" <> ToString @ Length @ HoldComplete @ a <> ">>]";

makeGraphicsString[ RasterBox[ a___ ], _ ] :=
    "Image[<<" <> ToString @ Length @ HoldComplete @ a <> ">>]";

makeGraphicsString[ Raster3DBox[ a___ ], _ ] :=
    "Image3D[<<" <> ToString @ Length @ HoldComplete @ a <> ">>]";

makeGraphicsString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeGraphicsExpression*)
makeGraphicsExpression // beginDefinition;
makeGraphicsExpression[ gfx_ ] := Quiet @ Check[ ToExpression[ gfx, StandardForm, HoldComplete ], $Failed ];
makeGraphicsExpression // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stringToBoxes*)
stringToBoxes // beginDefinition;

stringToBoxes[ s_String /; StringMatchQ[ s, "\"" ~~ __ ~~ "\"" ] ] :=
    With[ { str = stringToBoxes @ StringTrim[ s, "\"" ] }, "\""<>str<>"\"" /; StringQ @ str ];

stringToBoxes[ s_String ] :=
    UsingFrontEnd @ MathLink`CallFrontEnd @ FrontEnd`UndocumentedTestFEParserPacket[ s, True ][[ 1, 1 ]];

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
        Internal`StuffBag[ $cellToStringBag, { fastCellToString, cell } ];
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
(*docSearchResultString*)
docSearchResultString // ClearAll;

docSearchResultString[ query_String ] := Enclose[
    Module[ { search },
        search = ConfirmMatch[ documentationSearch @ query, { __String } ];
        StringJoin[
            "BEGIN_SEARCH_RESULTS\n",
            StringRiffle[ search, "\n" ],
            "\nEND_SEARCH_RESULTS"
        ]
    ],
    $noDocSearchResultsString &
];


docSearchResultString[ other_ ] :=
    With[ { str = cellToString @ other }, documentationSearch @ str /; StringQ @ str ];

docSearchResultString[ ___ ] := $noDocSearchResultsString;


documentationSearch[ query_String ] /; $localDocSearch := documentationSearch[ query ] =
    Module[ { result },
        Needs[ "DocumentationSearch`" -> None ];
        result = Association @ DocumentationSearch`SearchDocumentation[
            query,
            "MetaData" -> { "Title", "URI", "ShortenedSummary", "Score" },
            "Limit"    -> 5
        ];
        makeSearchResultString /@ Cases[
            result[ "Matches" ],
            { title_, uri_String, summary_, score_ } :>
                { title, "paclet:"<>StringTrim[ uri, "paclet:" ], summary, score }
        ]
    ];

documentationSearch[ query_String ] := documentationSearch[ query ] =
    Module[ { resp, flat, items },

        resp = URLExecute[
            "https://search.wolfram.com/search-api/search.json",
            {
                "query"           -> query,
                "limit"           -> "5",
                "disableSpelling" -> "true",
                "fields"          -> "title,summary,url,label",
                "collection"      -> "blogs,demonstrations,documentation10,mathworld,resources,wa_products"
            },
            "RawJSON"
        ];

        flat = Take[
            ReverseSortBy[ Flatten @ Values @ KeyTake[ resp[ "results" ], resp[ "sortOrder" ] ], #score & ],
            UpTo[ 5 ]
        ];

        items = Select[ flat, #score > 1 & ];

        makeSearchResultString /@ items
    ];


makeSearchResultString // ClearAll;

makeSearchResultString[ { title_, uri_String, summary_, score_ } ] :=
    TemplateApply[
        "* [`1`](`2`) - (score: `4`) `3`",
        { title, uri, summary, score }
    ];


makeSearchResultString[ KeyValuePattern[ "ad" -> True ] ] := Nothing;

makeSearchResultString[ KeyValuePattern @ { "fields" -> fields_Association, "score" -> score_ } ] :=
    makeSearchResultString @ Replace[
        Append[ fields, "score" -> score ],
        { s_String, ___ } :> s,
        { 1 }
    ];


makeSearchResultString[ KeyValuePattern @ {
    "summary" -> summary_String,
    "title"   -> name_String,
    "label"   -> "Built-in Symbol"|"Entity Type"|"Featured Example"|"Guide"|"Import/Export Format"|"Tech Note",
    "uri"     -> uri_String,
    "score"   -> score_
} ] := TemplateApply[
    "* [`1`](`2`) - (score: `4`) `3`",
    { name, "paclet:"<>StringTrim[ uri, "paclet:" ], summary, score }
];

makeSearchResultString[ KeyValuePattern @ {
    "summary" -> summary_String,
    "title"   -> name_String,
    "url"     -> url_String,
    "score"   -> score_
} ] := TemplateApply[ "* [`1`](`2`) - (score: `4`) `3`", { name, url, summary, score } ];


$noDocSearchResultsString = "BEGIN_DOCUMENTATION_SEARCH_RESULTS\n(no results found)\nEND_DOCUMENTATION_SEARCH_RESULTS";

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
$bugReportLink := Hyperlink[
    "Report this issue \[RightGuillemet]",
    URLBuild @ <|
        "Scheme"   -> "https",
        "Domain"   -> "github.com",
        "Path"     -> { "rhennigan", "ResourceFunctions", "issues", "new" },
        "Query"    -> {
            "title"  -> "[BirdChat] Insert Title Here",
            "body"   -> bugReportBody[ ],
            "labels" -> "bug,internal"
        }
    |>
];

bugReportBody[ ] := bugReportBody @ $thisResourceInfo;

bugReportBody[ as_Association? AssociationQ ] := $bugBody = TemplateApply[
    $bugReportBodyTemplate,
    Association[
        as,
        "SystemID"              -> $SystemID,
        "KernelVersion"         -> SystemInformation[ "Kernel"  , "Version" ],
        "FrontEndVersion"       -> $frontEndVersion,
        "Notebooks"             -> $Notebooks,
        "EvaluationEnvironment" -> $EvaluationEnvironment,
        "Stack"                 -> $bugReportStack,
        "Settings"              -> $settings
    ]
];


$frontEndVersion :=
    If[ TrueQ @ CloudSystem`$CloudNotebooks,
        Row @ { "Cloud: ", $CloudVersion },
        Row @ { "Desktop: ", UsingFrontEnd @ SystemInformation[ "FrontEnd", "Version" ] }
    ];


$settings :=
    Module[ { settings, assoc },
        settings = CurrentValue @ { TaggingRules, "BirdChatSettings" };
        assoc = Association @ settings;
        If[ AssociationQ @ assoc,
            ToString @ ResourceFunction[ "ReadableForm" ][ KeyDrop[ assoc, "OpenAIKey" ], "DynamicAlignment" -> True ],
            settings
        ]
    ];


$bugReportBodyTemplate = StringTemplate[ "\
# Description
Describe the issue in detail here.

# Debug Data
| Property | Value |
| --- | --- |
| Name | `%%Name%%` |
| UUID | `%%UUID%%` |
| Version | `%%Version%%` |
| RepositoryLocation | `%%RepositoryLocation%%` |
| FunctionLocation | `%%FunctionLocation%%` |
| KernelVersion | `%%KernelVersion%%` |
| FrontEndVersion | `%%FrontEndVersion%%` |
| Notebooks | `%%Notebooks%%` |
| EvaluationEnvironment | `%%EvaluationEnvironment%%` |
| SystemID | `%%SystemID%%` |

## Settings
```
%%Settings%%
```

## Stack Data
```
%%Stack%%
```",
Delimiters -> "%%"
];


$bugReportStack := $stackString = StringRiffle[
    Replace[
        DeleteAdjacentDuplicates @ Cases[
            $stack = Stack[ _ ],
            HoldForm[ (s_Symbol) | (s_Symbol)[ ___ ] | (s_Symbol)[ ___ ][ ___ ] ] /;
                AtomQ @ Unevaluated @ s && Context @ s === Context @ BirdChat :>
                    SymbolName @ Unevaluated @ s
        ],
        { a___, "throwInternalFailure", ___ } :> { a }
    ],
    "\n"
];

$thisResourceInfo := FirstCase[
    DownValues @ ResourceSystemClient`Private`resourceInfo,
    HoldPattern[ _ :> info: KeyValuePattern[ "SymbolName" -> Context @ BirdChat <> "BirdChat" ] ] :> info,
    <| |>
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Images*)
$images = EvaluateInPlace @ Association @ Map[
    FileBaseName[ #1 ] -> Once @ Import[ #1, "WXF" ] &,
    FileNames[ "*.wxf", FileNameJoin @ { DirectoryName @ $InputFileName, "Resources", "Icons" } ]
];

$curves = EvaluateInPlace @ Association @ Map[
    FileBaseName[ #1 ] -> Once @ Import[ #1, "WXF" ] &,
    FileNames[ "*.wxf", FileNameJoin @ { DirectoryName @ $InputFileName, "Resources", "GraphicsComponents" } ]
];


$languageIcons := $languageIcons = Enclose[
    ExternalEvaluate;
    Select[
        AssociationMap[
            ReleaseHold @ ExternalEvaluate`Private`GetLanguageRules[ #1, "Icon" ] &,
            ConfirmMatch[ ExternalEvaluate`Private`GetLanguageRules[ ], _List ]
        ],
        MatchQ[ _Graphics|_Image ]
    ],
    <| |> &
];


activeChatIcon // ClearAll;

activeChatIcon[ ] := activeChatIcon[ GrayLevel[ 0.4 ] ];
activeChatIcon[ fg_ ] := activeChatIcon[ fg, White ];
activeChatIcon[ fg_, bg_ ] := activeChatIcon[ fg, bg, 16 ];

activeChatIcon[ fg_, bg_, size_ ] :=
    Graphics[
        {
            fg,
            Thickness[ 0.0082061 ],
            $curves[ "ChatIconBoundary" ],
            bg,
            $curves[ "ChatIconBackground" ],
            Inset[
                ProgressIndicator[ Appearance -> "Necklace", ImageSize -> size / 2 ],
                Offset[ { 0, -6 }, ImageScaled @ { 0.5, 0.8 } ]
            ]
        },
        ImageSize -> size
    ];


staticChatIcon // ClearAll;

staticChatIcon[ ] := staticChatIcon[ GrayLevel[ 0.4 ] ];
staticChatIcon[ fg_ ] := staticChatIcon[ fg, White ];
staticChatIcon[ fg_, bg_ ] := staticChatIcon[ fg, bg, 16 ];

staticChatIcon[ fg_, bg_, size_ ] :=
    Graphics[
        {
            fg,
            Thickness[ 0.0082061 ],
            $curves[ "ChatIconBoundary" ],
            bg,
            $curves[ "ChatIconBackground" ],
            fg,
            $curves[ "ChatIconLines" ]
        },
        ImageSize -> size
    ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Development Initialization*)
If[ Context @ BirdChat === "Global`", DefineResourceFunction @ BirdChat ];