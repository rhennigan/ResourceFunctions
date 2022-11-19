#!/usr/bin/env wolframscript

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
If[ ! PacletObjectQ @ PacletObject[ "Wolfram/PacletCICD" ],
    PacletInstall[ "https://github.com/WolframResearch/PacletCICD/releases/download/v0.34.0/Wolfram__PacletCICD-0.34.0.paclet" ]
];
Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];
Needs[ "CCompilerDriver`"    -> "ccd`"  ];

cFile = cicd`ScriptConfirmBy[ #, FileExistsQ ] &;
cDir  = cicd`ScriptConfirmBy[ #, DirectoryQ  ] &;
cStr  = cicd`ScriptConfirmBy[ #, StringQ     ] &;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Paths*)
$inputFileName = cFile @ Replace[ $InputFileName, "" :> NotebookFileName[ ] ];
$pacletDir     = cDir @ DirectoryName[ $inputFileName, 2 ];
$sourceDir     = cStr @ FileNameJoin @ { $pacletDir, "Source" };
$targetDir     = cStr @ FileNameJoin @ { $pacletDir, "LibraryResources", $SystemID };

cicd`ConsoleLog[ "Build source directory: " <> $sourceDir ];
cicd`ConsoleLog[ "Build target directory: " <> $targetDir ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Compile*)
$sourceFiles = cicd`ScriptConfirmMatch[
    FileNames[
        {
            "fit_import.c",
            "fit.c",
            "fit_crc.c",
            "fit_example.c",
            "fit_convert.c"
        },
        $sourceDir
    ],
    { _, _, _, _, _ }
];

$built = ccd`CreateLibrary[
    $sourceFiles,
    "FitnessData",
    "TargetDirectory"     -> $targetDir,
    "CleanIntermediate"   -> True,
    "ShellOutputFunction" -> Print,
    "Defines"             -> { (* "FIT_USE_STDINT_H" *) }
];

If[ FileExistsQ @ $built
    ,
    $built = cStr @ ExpandFileName @ $built;
    cicd`ConsoleLog[ "Built library: " <> $built ];
    $built
    ,
    cicd`ConsoleError[ "Failed to build the library.", "Fatal" -> True ]
]

(* :!CodeAnalysis::EndBlock:: *)