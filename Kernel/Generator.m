(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Package header*)

Package[ "RH`ResourceFunctions`" ]

PackageExport[ "BuildDefinitionNotebook"    ]
PackageExport[ "GenerateDefinitionNotebook" ]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*BuildDefinitionNotebook*)
BuildDefinitionNotebook[ name_String? buildableNameQ ] :=
    Enclose @ Module[ { nb, tgt, nbo },
        nb  = ConfirmMatch[ GenerateDefinitionNotebook @ name, _Notebook ];
        tgt = FileNameJoin @ { $ResourceFunctionDirectory, name, name<>".nb" };
        WithCleanup[
            nbo = ConfirmMatch[
                DefinitionNotebookClient`UpdateDefinitionNotebook[
                    NotebookPut @ nb,
                    "CreateNewNotebook" -> False,
                    "DisplayStripe"     -> False
                ],
                _NotebookObject
            ],
            Export[ tgt, nbo, "NB" ],
            NotebookClose @ nbo
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*GenerateDefinitionNotebook*)
GenerateDefinitionNotebook[ name_String? buildableNameQ ] :=
    GenerateDefinitionNotebook @ FileNameJoin @ {
        $ResourceFunctionDirectory,
        name
    };

GenerateDefinitionNotebook[ dir_? DirectoryQ ] :=
    With[ { nb = generateDefinitionNotebook @ dir },
        If[ MatchQ[ nb, Notebook[ { ___Cell }, ___ ] ],
            reassignCellIDs @ nb,
            Failure[ GenerateDefinitionNotebook, <| |> ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*buildableNameQ*)
buildableNameQ[ name_ ] := MemberQ[ $BuildableNames, name ];
buildableNameQ[ ___   ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateDefinitionNotebook*)
generateDefinitionNotebook // ClearAll;

generateDefinitionNotebook[ dir_? DirectoryQ ] :=
    TemplateApply[ $template, deleteMissing @ generateTemplateData @ dir ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*deleteMissing*)
deleteMissing // ClearAll;
deleteMissing[ info_ ] := DeleteCases[ info, _Missing | { } | _? FailureQ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateTemplateData*)
generateTemplateData // ClearAll;

generateTemplateData[ dir_? DirectoryQ ] :=
    generateTemplateData[ dir, getMetadata @ dir ];

generateTemplateData[ dir_? DirectoryQ, info_ ] := <|
    "Name"                      -> generateName[              dir, info ],
    "Description"               -> generateDescription[       dir, info ],
    "Function"                  -> generateFunction[          dir, info ],
    "Usage"                     -> generateUsage[             dir, info ],
    "Notes"                     -> generateNotes[             dir, info ],
    "Examples"                  -> generateExamples[          dir, info ],
    "Contributed By"            -> generateContributedBy[     dir, info ],
    "Keywords"                  -> generateKeywords[          dir, info ],
    "Categories"                -> generateCategories[        dir, info ],
    "Related Symbols"           -> generateRelatedSymbols[    dir, info ],
    "Related Resource Objects"  -> generateRelatedResources[  dir, info ],
    "Source/Reference Citation" -> generateCitation[          dir, info ],
    "Links"                     -> generateLinks[             dir, info ],
    "VerificationTests"         -> generateVerificationTests[ dir, info ],
    "Author Notes"              -> generateAuthorNotes[       dir, info ]
|>;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name*)
generateName // ClearAll;

generateName[ dir_, info_Association ] :=
    generateName[ dir, info, Lookup[ info, "Name", FileBaseName @ dir ] ];

generateName[ dir_, info_, name_String ] :=
    Cell[ name, "Title", CellTags -> { "Name", "TemplateCell", "Title" } ];

generateName[ ___ ] :=
    Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Description*)
generateDescription // ClearAll;

generateDescription[ dir_, info_Association ] :=
    generateDescription[ dir, info, Lookup[ info, "Description" ] ];

generateDescription[ dir_, info_, desc_String ] :=
    Cell[ desc, "Text", CellTags -> { "Description", "TemplateCell" } ];

generateDescription[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Function*)
generateFunction // ClearAll;
generateFunction[ dir_, info_ ] := generateDefinitionCells[ info, dir ];
generateFunction[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Usage*)
generateUsage // ClearAll;

generateUsage[ dir_, KeyValuePattern[ "Documentation" -> doc_ ] ] :=
    generateUsage[ dir, doc ];

generateUsage[ dir_, KeyValuePattern[ "Usage" -> usage_ ] ] :=
    generateUsage[ dir, usage ];

generateUsage[ dir_, usage_List ] :=
    With[ { cells = Cases[ Flatten[ makeUsageGroup /@ usage ], _Cell ] },
        cells /; MatchQ[ cells, { __Cell } ]
    ];

generateUsage[ dir_, info_ ] :=
    generateUsage[ dir, info, findUsageFile @ dir ];

generateUsage[ dir_, info_, file_? FileExistsQ ] :=
    Block[ { findUsageFile = Missing[ ] & }, generateUsage[ dir, Get @ file ] ];

generateUsage[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeUsageGroup*)
makeUsageGroup // ClearAll;

makeUsageGroup[ { usage_, desc_ } ] :=
    {
        makeUsageInput @ usage,
        makeUsageDesc @ desc
    };

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeUsageInput*)
makeUsageInput // ClearAll;

makeUsageInput[ usage_String ] :=
    Module[ { str, templated },
        str = eliminateNewLineWhitespace @ usage;
        templated = ResourceFunction[ "StringTemplateInput" ][ str ];
        usageInputCell @ templated
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*usageInputCell*)
usageInputCell // ClearAll;

usageInputCell[ BoxData[ boxes_ ] ] := usageInputCell @ boxes;

usageInputCell[ boxes_ ] :=
    Cell[ BoxData @ boxes, "UsageInputs", FontFamily -> "Source Sans Pro" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeUsageDesc*)
makeUsageDesc // ClearAll;

makeUsageDesc[ desc_String ] :=
    AutoTemplateStrings @ Cell[
        eliminateNewLineWhitespace @ desc,
        "UsageDescription"
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*findUsageFile*)
findUsageFile // ClearAll;

findUsageFile[ dir_ ] :=
    Module[ { patt, files },
        patt  = ("Documentation"|"Usage")~~(".wl"|".m");
        files = FileNames[ patt, dir, IgnoreCase -> True ];
        SelectFirst[ files, FileExistsQ ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Notes*)
generateNotes // ClearAll;

generateNotes[ dir_, KeyValuePattern[ "Documentation" -> doc_ ] ] :=
    generateNotes[ dir, doc ];

generateNotes[ dir_, KeyValuePattern[ "Notes"|"Details" -> notes_ ] ] :=
    generateNotes[ dir, notes ];

generateNotes[ dir_, notes_List ] :=
    With[ { cells = Cases[ Flatten[ makeNotesCell /@ notes ], _Cell ] },
        cells /; MatchQ[ cells, { __Cell } ]
    ];

generateNotes[ dir_, info_ ] :=
    generateNotes[ dir, info, findNotesFile @ dir ];

generateNotes[ dir_, info_, file_? FileExistsQ ] :=
    Block[ { findNotesFile = Missing[ ] & }, generateNotes[ dir, Get @ file ] ];

generateNotes[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*findNotesFile*)
findNotesFile // ClearAll;

findNotesFile[ dir_ ] :=
    Module[ { patt, files },
        patt  = ("Documentation"|"Notes"|"Details")~~(".wl"|".m");
        files = FileNames[ patt, dir, IgnoreCase -> True ];
        SelectFirst[ files, FileExistsQ ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeNotesCell*)
makeNotesCell // ClearAll;

makeNotesCell[ str_String ] :=
    AutoTemplateStrings @ Cell[ eliminateNewLineWhitespace @ str, "Notes" ];

makeNotesCell[ table_ /; MatrixQ[ table, StringQ ] ] :=
    With[ { grid = Map[ notesTableItem, table, { 2 } ] },
        Cell[ BoxData @ GridBox @ grid, "TableNotes" ] /;
            MatchQ[ grid, { { __Cell }.. } ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*eliminateNewLineWhitespace*)
eliminateNewLineWhitespace[ str_String ] :=
    StringReplace[ str, Longest[ $newLineWhitespace.. ] :> " " ];

$newLine           = "\r\n" | "\n";
$newLineWhitespace = WhitespaceCharacter...~~$newLine~~WhitespaceCharacter...;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*notesTableItem*)
notesTableItem // ClearAll;
notesTableItem[ str_String ] :=
    Module[ { cell, templated },
        cell      = Cell[ eliminateNewLineWhitespace @ str, "TableText" ];
        templated = Flatten @ { AutoTemplateStrings @ cell };
        Sequence @@ templated
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Examples*)
generateExamples // ClearAll;

generateExamples[ dir_, info_ ] :=
    generateExamples[ dir, info, findExamplesFile[ info, dir ] ];

generateExamples[ dir_, info_, exFile_ ] :=
    generateExamples[ dir, info, exFile, findDefinitionFile[ info, dir ] ];

generateExamples[ dir_, info_, exFile_, defFile_ ] :=
    generateExampleCells[ dir, info, defFile, exFile ];

generateExamples[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*findExamplesFile*)
findExamplesFile // ClearAll;

findExamplesFile[ info: KeyValuePattern @ { }, dir_ ] :=
    Module[ { name, base, patt1, patt2, patt3, files1, files2, files3 },
        name   = Lookup[ info, "Name", FileBaseName @ dir ];
        base   = ("examples"|"examplenotebook");
        patt1  = base~~(".wl"|".m");
        patt2  = base~~(".nb");
        patt3  = (name|"definitionnotebook"|"definition")~~(".nb");
        files1 = FileNames[ patt1, dir, IgnoreCase -> True ];
        files2 = FileNames[ patt2, dir, IgnoreCase -> True ];
        files3 = FileNames[ patt3, dir, IgnoreCase -> True ];
        SelectFirst[ Join[ files1, files2, files3 ], FileExistsQ ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*generateExampleCells*)
generateExampleCells // ClearAll;

generateExampleCells[ dir_, info_, def_, ex_? FileExistsQ ] :=
    If[ fileFormat @ ex === "NB",
        examplesFromNotebook[ dir, info, def, ex ],
        examplesFromPackage[ dir, info, def, ex ]
    ];

generateExampleCells[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*fileFormat*)
fileFormat[ file_ ] := fileFormat[ file, ToUpperCase @ FileExtension @ file ];
fileFormat[ file_, "NB" ] := "NB";
fileFormat[ file_, _ ] := FileFormat @ file;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*examplesFromNotebook*)
examplesFromNotebook // ClearAll;

examplesFromNotebook[ dir_, info_, def_, ex_ ] :=
    Module[ { notebook, rtype },

        notebook = Import @ ex;
        rtype    = DefinitionNotebookClient`NotebookResourceType @ notebook;

        If[ rtype === "Function",
            DefinitionNotebookClient`ScrapeSection[
                "Function",
                notebook,
                "Examples"
            ],
            First @ notebook
        ] /; MatchQ[ notebook, Notebook[ _List, ___ ] ]
    ];

examplesFromNotebook[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*examplesFromPackage*)
examplesFromPackage // ClearAll;

examplesFromPackage[ dir_, info_, defFile_? FileExistsQ, file_? FileExistsQ ] :=
    contextBlock @ Block[ { $inputFileName = file },
        Get @ defFile;
        ReplaceRepeated[
            generateDefinitionCells[ info, file ],
            Cell[ BoxData[ a_ ], "Code", ___ ] :>
                Cell[ StripBoxes @ a, "Input" ]
        ]
    ];

examplesFromPackage[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*contextBlock*)
contextBlock // Attributes = { HoldAll };

contextBlock[ eval_ ] :=
    contextBlock[ "DefinitionNotebookGenerator`", eval ];

contextBlock[ context_, eval_ ] :=
    contextBlock[ context, { "System`", context }, eval ];

contextBlock[ context_, contextPath_, eval_ ] :=
    Module[ { $context, $contextPath },
        WithCleanup[
            $context     = $Context;
            $contextPath = $ContextPath;
            $Context     = context;
            $ContextPath = contextPath;
            ,
            eval
            ,
            $Context     = $context;
            $ContextPath = $contextPath;
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Contributed By*)
generateContributedBy // ClearAll;

generateContributedBy[ dir_, info: KeyValuePattern @ { } ] :=
    generateContributedBy[ dir, info, Lookup[ info, "Author" ] ];

generateContributedBy[ dir_, info_, author_String ] :=
    Cell[ author, "Text" ];

generateContributedBy[ ___ ] :=
    Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Keywords*)
generateKeywords // ClearAll;

generateKeywords[ dir_, info: KeyValuePattern @ { } ] :=
    generateKeywords[ dir, info, Lookup[ info, "Keywords" ] ];

generateKeywords[ dir_, info_, keywords: { __String } ] :=
    Cell[ #, "Item" ] & /@ keywords;

generateKeywords[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Categories*)
generateCategories // ClearAll;

generateCategories[ dir_, info: KeyValuePattern @ { } ] :=
    generateCategories[ dir, info, Lookup[ info, "Categories" ] ];

generateCategories[ dir_, info_, cats: { __String } ] :=
    DefinitionNotebookClient`CheckboxesCell[
        "Function",
        "Categories",
        "Checked" -> cats
    ];

generateCategories[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Related Symbols*)
generateRelatedSymbols // ClearAll;

generateRelatedSymbols[ dir_, info: KeyValuePattern @ { } ] :=
    generateRelatedSymbols[ dir, info, Lookup[ info, "RelatedSymbols" ] ];

generateRelatedSymbols[ dir_, info_, syms: { __String } ] :=
    Cell[ #, "Item" ] & /@ syms;

generateRelatedSymbols[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Related Resource Objects*)
generateRelatedResources // ClearAll;

generateRelatedResources[ dir_, info: KeyValuePattern @ { } ] :=
    generateRelatedResources[
        dir,
        info,
        Lookup[ info, "RelatedResourceObjects" ]
    ];

generateRelatedResources[ dir_, info_, res: { __String } ] :=
    Cell[ #, "Item" ] & /@ res;

generateRelatedResources[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Source/Reference Citation*)
generateCitation // ClearAll;

generateCitation[ dir_, info: KeyValuePattern @ { } ] :=
    generateCitation[
        dir,
        info,
        Flatten @ List @ Lookup[ info, "Citation" ]
    ];

generateCitation[ dir_, info_, citation: { __String } ] :=
    Cell[ #, "Text" ] & /@ citation;

generateCitation[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Links*)
generateLinks // ClearAll;

generateLinks[ dir_, info: KeyValuePattern @ { } ] :=
    generateLinks[
        dir,
        info,
        Flatten @ List @ Lookup[ info, "Links" ]
    ];

generateLinks[ dir_, info_, links: { (_String|_Hyperlink).. } ] :=
    makeLinkCell /@ links;

generateLinks[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeLinkCell*)
makeLinkCell // ClearAll;

makeLinkCell[ url_String ] := Cell[ url, "Item" ];

makeLinkCell[ Hyperlink[ label_String, url_String, ___ ] ] :=
    Cell[ TextData @ ButtonBox[
              label,
              BaseStyle  -> "Hyperlink",
              ButtonData -> { URL @ url, None },
              ButtonNote -> url
          ],
          "Item"
    ];

makeLinkCell[ ___ ] := Nothing;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*VerificationTests*)
generateVerificationTests // ClearAll;

generateVerificationTests[ dir_, info_ ] :=
    generateVerificationTests[
        dir,
        info,
        findVerificationTestsFile[ info, dir ]
    ];

generateVerificationTests[ dir_, info_, vtFile_ ] :=
    generateVerificationTestCells[ dir, info, vtFile ];

generateVerificationTests[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*generateVerificationTestCells*)
generateVerificationTestCells // ClearAll;

generateVerificationTestCells[ dir_, info_, vtFile_? FileExistsQ ] :=
    If[ ToUpperCase @ FileExtension @ vtFile === "NB",
        vtCellsFromNotebook[ dir, info, vtFile ],
        Block[ { $currentHeaderLevel = 2 },
            vtCellsFromPackage[ dir, info, vtFile ]
        ]
    ];

generateVerificationTestCells[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*vtCellsFromNotebook*)
vtCellsFromNotebook // ClearAll;

vtCellsFromNotebook[ dir_, info_, file_ ] :=
    Module[ { notebook, rtype },

        notebook = Import @ file;
        rtype    = DefinitionNotebookClient`NotebookResourceType @ notebook;

        If[ rtype === "Function",
            DefinitionNotebookClient`ScrapeSection[
                "Function",
                notebook,
                "VerificationTests"
            ],
            First @ notebook
        ] /; MatchQ[ notebook, Notebook[ _List, ___ ] ]
    ];

vtCellsFromNotebook[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*vtCellsFromPackage*)
vtCellsFromPackage // ClearAll;

vtCellsFromPackage[ dir_, info_, file_ ] :=
    Module[ { tmp, cells },
        tmp   =  FileNameJoin @ { $TemporaryDirectory, CreateUUID[ ]<>".wl" };
        cells = WithCleanup[
            CopyFile[ file, tmp ]
            ,
            ReplaceAll[
                generateDefinitionCells[ info, tmp ],
                Cell[ a_, "Code", b___ ] :>
                    Cell[ a, "Input", "Code", InitializationCell -> False, b ]
            ]
            ,
            DeleteFile @ tmp
        ];

        If[ MatchQ[ cells, { __Cell } ], cells, Missing[ ] ]
    ];

vtCellsFromPackage[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*findVerificationTestsFile*)
findVerificationTestsFile // ClearAll;

findVerificationTestsFile[ info: KeyValuePattern @ { }, dir_ ] :=
    Module[ { name, ext, p1, p2, patt },

        name = Lookup[ info, "Name", FileBaseName @ dir ];
        ext  = { ".wlt", ".nb", ".wl", ".m" };
        p1   = Outer[ StringJoin, { "VerificationTests", "Tests" }, ext ];
        p2   = Outer[ StringJoin, { name, "DefinitionNotebook" }, ext ];
        patt = Flatten @ { p1, p2 };

        firstMatchingFile[ patt, dir, IgnoreCase -> True ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Author Notes*)
generateAuthorNotes // ClearAll;
(* TODO *)
generateAuthorNotes[ ___ ] := Missing[ ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Metadata*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getMetadata*)
getMetadata // ClearAll;

getMetadata[ dir_? DirectoryQ ] :=
    With[ { file = findMetadataFile @ dir },
        If[ FileExistsQ @ file,
            getMetadata @ file,
            <| "Name" -> FileBaseName @ dir |>
        ]
    ];

getMetadata[ file_? FileExistsQ ] := getMetadata @ Get @ file;

getMetadata[ info_Association ] := info;

getMetadata[ ___ ] := <| |>;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*findMetadataFile*)
findMetadataFile // ClearAll;

findMetadataFile[ dir_ ] :=
    Module[ { patt, files },
        patt  = ("ResourceInfo"|"Metadata")~~(".wl"|".m");
        files = FileNames[ patt, dir, IgnoreCase -> True ];
        SelectFirst[ files, FileExistsQ ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Definition Utilities*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateDefinitionCells*)
generateDefinitionCells // ClearAll;

generateDefinitionCells[ info_, dir_? DirectoryQ ] :=
    generateDefinitionCells[ info, findDefinitionFile[ info, dir ] ];

generateDefinitionCells[ info_, file_? FileExistsQ ] :=
    Block[ { $inputFileName = If[ FileExistsQ @ $inputFileName, $inputFileName, file ] },
        Module[ { nb, cells },
            nb      = createPackageNotebook @ file;
            cells   = First @ nb;
            cells //= deleteHeaderStripes;
            cells //= fixDelimiters;
            cells //= demoteHeaders;
            cells //= evaluateInputs;
            cells //= AutoTemplateStrings;
            cells //= Flatten;
            before = cells;
            Flatten[ cells //. $defCellRules ]
        ]
    ];

generateDefinitionCells[ ___ ] :=
    Missing[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*findDefinitionFile*)
findDefinitionFile // ClearAll;

findDefinitionFile[ info_, dir_ ] :=
    Module[ { base, patt, files },
        base  = Lookup[ info, "Name", FileBaseName @ dir ];
        patt  = ("definition"|base)~~(".wl"|".m");
        files = FileNames[ patt, dir, IgnoreCase -> True ];
        SelectFirst[ files, FileExistsQ ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toSimpleString*)
toSimpleString // ClearAll;

toSimpleString[ args_ ] /; ! TrueQ @ $stringy :=
    Module[ { string },
        string = Block[ { $stringy = True }, toSimpleString @ args ];
        StringReplace[
            StringTrim @ string,
            {
                Longest @ StringExpression[ " ".., " " ] :> " ",
                Longest @ StringExpression[
                    WhitespaceCharacter...,
                    "\n",
                    WhitespaceCharacter...
                ] :> " "
            }
        ]
    ];

toSimpleString[ RowBox[ list_ ] ] := toSimpleString @ list;

toSimpleString[ str_String ] := str;

toSimpleString[ list_List ] :=
    With[ { strings = toSimpleString /@ list },
        StringJoin @ strings /; AllTrue[ strings, StringQ ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateStringTemplates*)


(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stringTemplateEvaluate*)


(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*deleteHeaderStripes*)
deleteHeaderStripes // ClearAll;

deleteHeaderStripes[ cells_ ] :=
    DeleteCases[
        cells,
        Cell[ _, s_String /; StringMatchQ[ s, Verbatim[ "*" ].. ], ___ ],
        Infinity
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$defCellRules*)
$defCellRules // ClearAll;

$defCellRules := $defCellRules = Dispatch @ {
    RowBox @ { a_ } :> a
    ,
    Cell[ BoxData @ RowBox @ { a___, "\n" }, b___ ] :>
        Cell[ BoxData @ RowBox @ { a }, b ]
    ,
    Cell[ BoxData @ RowBox @ { "\n", a___ }, b___ ] :>
        Cell[ BoxData @ RowBox @ { a }, b ]
    ,
    Cell[ BoxData @ { boxes__, "\n" }, a___ ] :>
        Cell[ BoxData @ { boxes }, a ]
    ,
    Cell[
        BoxData @ {
            a___,
            b: RowBox @ { RowBox @ { ___, ";" }, "\n" },
            "\n",
            c___
        },
        d___
    ] :>
        Sequence[
            Cell[ BoxData @ { a, b }, d ],
            Cell[ BoxData @ { c }, d ]
        ]
    ,
    Cell[ BoxData @ { a_ }, b___ ] :>
        Cell[ BoxData @ a, b ]
    ,
    Cell[ BoxData @ RowBox @ { a_, "\n" }, b___ ] :>
        Cell[ BoxData @ a, b ]
    ,
    Cell[ BoxData @ { a___, "\n", b___ }, c___ ] /;
        ! FreeQ[ Hold[ a, b ], "\n", { 2, Infinity } ] :>
            Sequence[
                Cell[ BoxData @ { a }, c ],
                Cell[ BoxData @ { b }, c ]
            ]
    ,
    RowBox @ {
        a_String /; StringStartsQ[ a, "(*" ],
        row___,
        b_String /; StringEndsQ[ b, "*)" ]
    } :>
        With[
            {
                str =
                    toSimpleString @ {
                        StringDelete[
                            a,
                            StringExpression[ StartOfString, "(*" ]
                        ],
                        row,
                        StringDelete[
                            b,
                            StringExpression[ "*)", EndOfString ]
                        ]
                    }
            },
            commentWrapper @ StringTrim @ str /; StringQ @ str
        ]
    ,
    Cell[
        BoxData @ RowBox @ {
            a___,
            "\n",
            commentWrapper[ comment_String ]
        },
        b___
    ] :>
        Sequence @@ Flatten[ {
            Cell[ BoxData @ RowBox @ { a }, b ],
            AutoTemplateStrings @ Cell[ comment, "Text" ]
        } ]
    ,
    Cell[
        BoxData @ RowBox @ {
            commentWrapper[ comment_String ],
            "\n",
            a___
        },
        b___
    ] :>
        Sequence @@ Flatten[ {
            AutoTemplateStrings @ Cell[ comment, "Text" ],
            Cell[ BoxData @ RowBox @ { a }, b ]
        } ]
    ,
    Cell[
        BoxData @ RowBox @ {
            a___,
            "\n",
            commentWrapper[ comment_String ],
            "\n",
            b___
        },
        c___
    ] :>
        Sequence @@ Flatten[ {
            Cell[ BoxData @ RowBox @ { a }, c ],
            AutoTemplateStrings @ Cell[ comment, "Text" ],
            Cell[ BoxData @ RowBox @ { b }, c ]
        } ]
    ,
    commentWrapper[ comment_String ] :>
        "(* "<>comment<>" *)"
    ,
    Cell[ str_String, "Text", ___ ] /;
        StringMatchQ[ str, Verbatim[ "*" ].. ] :>
            $exampleDelimiter
    ,
    Cell[ BoxData[ "" ], __ ] :> Sequence[ ]
    ,
    RowBox @ { RowBox @ { "Excluded", "[", a___, "]" }, ";" } :>
        RowBox @ { "Excluded", "[", a, "]" }
    ,
    row: RowBox @ { "Excluded", "[", ___, "]" } :> (evaluateInPlace @ row; "")
    ,
    RowBox @ { "EvaluateInPlace", "[", evaluate__, "]" } :>
        evaluateInPlace @ evaluate
    ,
    RowBox @ { "EvaluateInPlace", "@", evaluate__ } :>
        evaluateInPlace @ evaluate
    ,
    RowBox @ { evaluate__, "//", "EvaluateInPlace" } :>
        evaluateInPlace @ evaluate
    ,
    CellGroupData[ a: { ___, _List, ___ }, b_ ] :>
        CellGroupData[ Flatten @ a, b ]
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateInPlace*)
evaluateInPlace[ boxes_ ] :=
    ToBoxes @ ReleaseHold @ ReplaceAll[
        ToExpression[ boxes, StandardForm, HoldComplete ],
        HoldPattern @ $InputFileName -> $inputFileName
    ];

evaluateInPlace[ boxes__ ] :=
    evaluateInPlace @ RowBox @ { boxes };

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*commentWrapper*)
commentWrapper[ str_String ] /;
    StringMatchQ[
        str,
        Alternatives[
            WhitespaceCharacter~~___,
            ___~~WhitespaceCharacter
        ]
    ] :=
        commentWrapper @ StringTrim @ str;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Examples*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*createPackageNotebook*)
createPackageNotebook // ClearAll;

createPackageNotebook[ file_ ] :=
    createPackageNotebook[ file, $notebookGroupingMethod ];

createPackageNotebook[ file_, None ] :=
    createPackageNotebook0[ file, False ];

createPackageNotebook[ file_, Automatic ] :=
    createPackageNotebook0[ file, True ];

createPackageNotebook[ file_, HoldPattern @ RemoteEvaluate ] :=
    RemoteEvaluate[
        "localhost",
        UsingFrontEnd @ createPackageNotebook0[ file, True ]
    ];

createPackageNotebook[ file_, CloudEvaluate ] :=
    With[ { bytes = ReadByteArray @ file },
        CloudEvaluate @ Module[ { tmp },
            WithCleanup[
                tmp =
                    Export[
                        FileNameJoin @ {
                            $TemporaryDirectory,
                            FileNameTake @ file
                        },
                        bytes,
                        "Binary"
                    ],
                UsingFrontEnd @ createPackageNotebook0[ file, True ],
                DeleteFile @ tmp
            ]
        ]
    ];


createPackageNotebook0[ file_, visible_ ] :=
    Module[ { exNB },
        WithCleanup[
            exNB = NotebookOpen[ file, Visible -> visible ],
            DeleteCases[ NotebookGet @ exNB, Visible -> False ],
            NotebookClose @ exNB
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$notebookGroupingMethod*)
$notebookGroupingMethod = Automatic;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*packageNotebookToCells*)
packageNotebookToCells // ClearAll;

packageNotebookToCells[ Notebook[ cells_, ___ ] ] :=
    Flatten @ AutoTemplateStrings @ evaluateInputs @
        demoteHeaders @ fixDelimiters @ DeleteCases[
            cells,
            Cell[ _, s_String /; StringMatchQ[ s, Verbatim[ "*" ].. ], ___ ],
            Infinity
        ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fixDelimiters*)
fixDelimiters // ClearAll;

fixDelimiters[ cells_ ] :=
    cells /. Cell[ "", "ExampleDelimiter" ] -> $exampleDelimiter;

(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*$exampleDelimiter*)
$exampleDelimiter =
    ReplaceAll[
        Cell[
            BoxData @ InterpretationBox[
                Cell[ "\t", "ExampleDelimiter" ],
                $line = 0;
            ],
            "ExampleDelimiter"
        ],
        ToExpression[
            "$Line",
            InputForm,
            Function[ s, $line :> s, HoldAllComplete ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*demoteHeaders*)
demoteHeaders // ClearAll;
demoteHeaders[ cells_ ] :=
    demoteHeaders0[ cells, $currentHeaderLevel ];

(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*demoteHeaders0*)
demoteHeaders0 // ClearAll;

demoteHeaders0[ cells_, n_Integer? Positive ] :=
    demoteHeaders0[
        cells /. {
            Cell[ a_, "Section"      , b___ ] :>
                Cell[ a, "Subsection"      , b ],
            Cell[ a_, "Subsection"   , b___ ] :>
                Cell[ a, "Subsubsection"   , b ],
            Cell[ a_, "Subsubsection", b___ ] :>
                Cell[ a, "Subsubsubsection", b ],
            Cell[ a_, "Subsubsubsection", b___ ] :>
                Cell[ a, "Text", b ]
        },
        n - 1
    ];

demoteHeaders0[ cells_, _ ] := cells;

(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*$currentHeaderLevel*)
$currentHeaderLevel = 1;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateInputs*)
evaluateInputs // ClearAll;

evaluateInputs[ cells_ ] /; TrueQ @ $evaluateInputs :=
    Quiet @ Block[ { $line = 0 },
        cells /.
            Cell[ BoxData[ boxes_ ], "Code"|"Input" ] :>
                evaluateInputBoxes @ boxes
    ];

evaluateInputs[ cells_ ] := cells;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateInputBoxes*)
evaluateInputBoxes // ClearAll;

evaluateInputBoxes[ boxes_ ] :=
    Module[ { flat, held },
        flat = Flatten @ List @ boxes;
        held = ToExpression[ flat, StandardForm, HoldComplete ];
        held = DeleteCases[ held, HoldComplete @ Null ];
        Cases[ held, HoldComplete[ expr_ ] :> createInOutGroup[ $line, expr ] ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*createInOutGroup*)
createInOutGroup // ClearAll;

createInOutGroup // Attributes = { HoldAllComplete };

createInOutGroup[ $line_, expr_ ] :=
    Module[ { bag, line, catchMessage, input, result, messages, output },
        line = ToString @ ++$line;
        bag = Internal`Bag[ ];

        catchMessage[
            Hold[ Message[ msg: MessageName[ sym_, tag_ ], args___ ], _ ]
        ] /; ! MessageQuietedQ @ msg :=
            Internal`StuffBag[
                bag,
                Cell[
                    BoxData @ Internal`MessageTemplate[
                        sym,
                        tag,
                        StringForm[
                            messageTemplate[ sym, tag, HoldComplete @ args ],
                            Apply[
                                Sequence,
                                Cases[
                                    HoldComplete @ args,
                                    e_ :>
                                        Short[
                                            Shallow[ HoldForm @ e, { 10, 50 } ],
                                            5
                                        ]
                                ]
                            ]
                        ],
                        StandardForm
                    ],
                    "Message",
                    "MSG",
                    CellLabel ->
                        StringJoin[ "During evaluation of In[", line, "]:=" ]
                ]
            ];


        input = makeInputCell[ line, expr ];

        result =
            Internal`HandlerBlock[ { "Message", catchMessage },
                Quiet[ expr, dummy::dummy ]
            ];

        messages = Internal`BagPart[ bag, All ];

        output =
            Cell[
                BoxData @ ToBoxes[ result, StandardForm ],
                "Output",
                CellLabel -> StringJoin[ "Out[", line, "]=" ]
            ];

        Cell @ CellGroupData[ Flatten @ { input, messages, output }, Open ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeInputCell*)
makeInputCell // ClearAll;

makeInputCell // Attributes = { HoldAllComplete };

makeInputCell[ line_, expr_ ] :=
    Cell[
        BoxData @ ResourceFunction[ "StringToBoxes" ][
            ToString[ Unevaluated @ expr, InputForm ]
        ],
        "Input",
        CellLabel -> StringJoin[ "In[", line, "]:=" ]
    ];


(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*messageTemplate*)
messageTemplate // ClearAll;

messageTemplate[ symbol_Symbol, tag__String, args_HoldComplete ] :=
    Replace[
        MessageName[ symbol, tag ],
        Except[ _String? StringQ ] :> Replace[
            MessageName[ General, tag ],
            Except[ _String? StringQ ] :> StringJoin[
                "-- Message text not found --",
                StringJoin @ Table[
                    { " (`", ToString @ i, "`)" },
                    { i, Length @ args }
                ]
            ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Utilities*)

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
    Module[ { stack, msgOrGeneral, msgPatt, split },

        stack        = Lookup[ $status = Internal`QuietStatus[ ], Stack ];
        msgOrGeneral = generalMessagePattern @ msg;
        msgPatt      = All | { ___, msgOrGeneral, ___ };
        split        = stack /. { ___, { _, { dummy::dummy }, _ }, a___ } :> a;

        TrueQ @ And[
            (* check if msg is unquieted via third arg of Quiet: *)
            FreeQ[ split, { _, _, msgPatt }, 2 ],
            (* check if msg is not quieted via second arg of Quiet: *)
            ! FreeQ[ split, { _, msgPatt, _ }, 2 ]
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

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*$template*)
$template := $template =
    Get @ DefinitionNotebookClient`DefinitionTemplateLocation[ "Function" ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*General Utilities*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*firstMatchingFile*)
firstMatchingFile // ClearAll;

firstMatchingFile[ { patt_, rest___ }, args___ ] :=
    First[ FileNames[ patt, args ], firstMatchingFile[ { rest }, args ] ];

firstMatchingFile[ { }, ___ ] := Missing[ "NotFound" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*reassignCellIDs*)
reassignCellIDs[ expr_ ] :=
    Block[ { $UsedCellIDs = <| |>, $hashed },
        ReplaceAll[
            ReplaceAll[
                expr,
                cell: Cell[
                    Except[ _CellGroupData ],
                    Except[ CellID -> _$hashed ]...
                ] :>
                    With[ { new = cellHash @ cell },
                        Append[
                            DeleteCases[ cell, CellID -> _ ],
                            CellID -> $hashed @ new
                        ] /; True
                    ]
            ],
            $hashed[ id_ ] :> id
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellHash*)
cellHash[ Cell[ content_, ___ ] ] :=
    Module[ { hash },
        hash = Mod[ Hash @ content, 10^9, 1 ];
        While[ TrueQ @ $UsedCellIDs @ hash, hash = Mod[ hash + 1, 10^9, 1 ] ];
        $UsedCellIDs[ hash ] = True;
        hash
    ];
