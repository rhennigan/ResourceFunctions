(* !Excluded
This notebook was automatically generated from [Definitions/FITImport](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/FITImport).
*)

FITImport // ClearAll;
(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$inDef = False;
$debug = True;

$ContextAliases[ "gu`" ] = "GeneralUtilities`";

(* ::**********************************************************************:: *)
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
(*Config*)
$invalidSINT8  = 127;
$invalidUINT8  = 255;
$invalidSINT16 = 32767;
$invalidUINT16 = 65535;
$invalidSINT32 = 2147483647;
$invalidUINT32 = 4294967295;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Paths*)
$libFileLocation := FileNameJoin @ { $libDirectory, $libFileName };
$libFileName     := "FITImport." <> Internal`DynamicLibraryExtension[ ];
$libDirectory    := gu`EnsureDirectory @ {
                        $UserBaseDirectory,
                        "ApplicationData",
                        "ResourceFunctions",
                        "FITImport",
                        "LibraryResources",
                        $SystemID
                    };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Messages*)
FITImport::Internal =
"An unexpected error occurred. `1`";

FITImport::InvalidFile =
"First argument `1` is not a valid file, directory, or URL specification.";

FITImport::InvalidFitFile =
"Cannot import data as FIT format.";

FITImport::InvalidElement =
"The import element \"`1`\" is not present when importing as FIT.";

FITImport::BadElementSpecification =
"The import element specification \"`1`\" is not valid.";

FITImport::FileNotFound =
"File `1` not found."

FITImport::IncompatibleSystemID =
"FITImport is not compatible with the system ID \"`1`\".";

FITImport::CopyTemporaryFailed =
"Failed to copy source to a temporary file.";

FITImport::ArgumentCount =
"FITImport called with `1` arguments; between 1 and 2 arguments are expected.";

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Attributes*)
FITImport // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Options*)
FITImport // Options = { UnitSystem :> $UnitSystem };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$$string = _String? StringQ;
$$bytes  = _ByteArray? ByteArrayQ;
$$assoc  = _Association? AssociationQ;
$$file   = File[ $$string ];
$$url    = URL[ $$string ];
$$co     = HoldPattern[ CloudObject ][ $$string, OptionsPattern[ ] ];
$$lo     = HoldPattern[ LocalObject ][ $$string, OptionsPattern[ ] ];
$$resp   = HoldPattern[ HTTPResponse ][ $$bytes, $$assoc, OptionsPattern[ ] ];
$$source = $$string | $$file | $$url | $$co | $$lo | $$resp;

$$fitKeys  = _? fitKeyQ  | { ___? fitKeyQ  };
$$elements = _? elementQ | { ___? elementQ };
$$prop     = _? fitKeyQ | _? elementQ;
$$propList = { $$prop... };
$$props    = $$prop | $$propList;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
FITImport[ file_, opts: OptionsPattern[ ] ] :=
    catchTop @ FITImport[ file, "Dataset", opts ];

FITImport[ file_? FileExistsQ, "RawData", opts: OptionsPattern[ ] ] :=
    catchTop @ Block[ { $UnitSystem = OptionValue @ UnitSystem },
        fitImport @ ExpandFileName @ file
    ];

FITImport[ file_? FileExistsQ, "Data", opts: OptionsPattern[ ] ] :=
    catchTop @ Block[ { $UnitSystem = OptionValue @ UnitSystem },
        Module[ { data, formatted, tr, filtered },
            Needs[ "GeneralUtilities`" -> None ];
            data = FITImport[ file, "RawData", opts ];
            formatted = formatFitData @ data;
            tr = gu`AssociationTranspose @ formatted;
            filtered = Select[ tr, Composition[ Not, AllTrue @ MissingQ ] ];
            gu`AssociationTranspose @ filtered
        ]
    ];

FITImport[ file_? FileExistsQ, "Dataset", opts: OptionsPattern[ ] ] :=
    catchTop @ Dataset @ FITImport[ file, "Data", opts ];

FITImport[ file: $$file|$$string, prop_, opts: OptionsPattern[ ] ] /;
    ! FileExistsQ @ file :=
        With[ { found = FindFile @ file },
            FITImport[ found, prop, opts ] /; FileExistsQ @ found
        ];

FITImport[ _, "Elements", OptionsPattern[ ] ] :=
    $fitElements;

FITImport[ file_, key: $$fitKeys, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { data },
        data  = FITImport[ file, "RawData", opts ];
        makeTimeSeriesData[ data, key ]
    ];

FITImport[ file_, All, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { data },
        data  = FITImport[ file, "RawData", opts ];
        DeleteMissing @ makeTimeSeriesData[ data, $fitKeys ]
    ];

FITImport[ file_, props: $$propList, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { data, fitKeys, elements, ts, as, joined },
        data     = FITImport[ file, "RawData", opts ];
        fitKeys  = Select[ props, fitKeyQ  ];
        elements = Select[ props, elementQ ];
        ts       = makeTimeSeriesData[ data, fitKeys ];
        as       = makeElementData[ file, data, elements, opts ];
        joined   = Association[ ts, as ];

        If[ AssociationQ @ joined,
            KeyTake[ joined, props ],
            throwInternalFailure @ FITImport[ file, props, opts ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Error cases*)
FITImport[ $$source, { ___, e: Except[ $$props ], ___ }, OptionsPattern[ ] ] :=
    catchTop[
        If[ StringQ @ e,
            throwFailure[ "InvalidElement"         , e ],
            throwFailure[ "BadElementSpecification", e ]
        ]
    ];


FITImport[ $$source, e: Except[ $$props ], OptionsPattern[ ] ] :=
    catchTop[
        If[ StringQ @ e,
            throwFailure[ "InvalidElement"         , e ],
            throwFailure[ "BadElementSpecification", e ]
        ]
    ];

FITImport[ source: $$source, _, opts: OptionsPattern[ ] ] :=
    catchTop @ throwFailure[ "FileNotFound", source ];

FITImport[ source: Except @ $$source, _, opts: OptionsPattern[ ] ] :=
    catchTop @ throwFailure[ "InvalidFile", source ];

FITImport[ source: $$source, elem_String, opts: OptionsPattern[ ] ] /;
    ! elementQ @ elem :=
        catchTop @ throwFailure[ "InvalidElement", elem ];

FITImport[ args___ ] :=
    catchTop @ With[ { len = Length @ HoldComplete @ args },
        throwFailure[ "ArgumentCount", len ]
    ];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)
$fitElements = {
    "Data",
    "Dataset",
    "Elements",
    "RawData"
};

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*elementQ*)
elementQ[ elem_String ] := MemberQ[ $fitElements, elem ];
elementQ[ ___         ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fitImport*)
fitImport // beginDefinition;

fitImport[ source: $$source ] :=
    Block[ { $tempFiles = Internal`Bag[ ] },
        WithCleanup[
            fitImport[ source, toFileString @ source ],
            DeleteFile /@ Internal`BagPart[ $tempFiles, All ]
        ]
    ];

fitImport[ source_, file_String ] :=
    fitImport[ source, file, fitImportLibFunction @ file ];

fitImport[ source_, file_, data_List? rawDataQ ] := (
    $start = data[[ 1, 1 ]];
    data
);

fitImport[ source_, _, LibraryFunctionError[ "LIBRARY_FUNCTION_ERROR", 6 ] ] :=
    throwFailure[ "InvalidFitFile", source ];

fitImport // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*rawDataQ*)
rawDataQ[ { { } }  ] := False;
rawDataQ[ raw_List ] := MatrixQ[ raw, IntegerQ ];
rawDataQ[ ___      ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeTimeSeriesData*)
makeTimeSeriesData // beginDefinition;

makeTimeSeriesData[ data_, key_ ] :=
    makeTimeSeriesData[ data, key, fitValue[ "Timestamp", # ] & /@ data ];

makeTimeSeriesData[ data_, key_String, time_ ] :=
    Module[ { value },
        value = fitValue[ key, # ] & /@ data;
        If[ AllTrue[ value, MissingQ ],
            Missing[ "NotAvailable" ],
            TimeSeries @ Transpose @ { time, value }
        ]
    ];

makeTimeSeriesData[ data_, keys_List, time_ ] :=
    AssociationMap[ makeTimeSeriesData[ data, #, time ] &, keys ];

makeTimeSeriesData // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeElementData*)
makeElementData // beginDefinition;

makeElementData[ file_, data_, elements_List, opts: OptionsPattern[ ] ] :=
    AssociationMap[ FITImport[ file, #, opts ] &, elements ];

makeElementData[ file_, data_, element_, opts: OptionsPattern[ ] ] :=
    FITImport[ file, element, opts ];

makeElementData // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toFileString*)
toFileString // beginDefinition;

toFileString[ file_ ] :=
    With[ { str = toFileString0 @ file },
        If[ StringQ @ str,
            str,
            throwFailure[ "InvalidFile", file ]
        ]
    ];

toFileString // endDefinition;

toFileString0 // beginDefinition;
toFileString0[ source: $$string ] := ExpandFileName @ source;
toFileString0[ source: $$file   ] := ExpandFileName @ source;
toFileString0[ source: $$url    ] := createTemporary @ source;
toFileString0[ source: $$co     ] := createTemporary @ source;
toFileString0[ source: $$lo     ] := createTemporary @ source;
toFileString0[ source: $$resp   ] := createTemporary @ source;
toFileString0 // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*createTemporary*)
createTemporary // beginDefinition;

createTemporary[ source: $$url ] :=
    addTempFile @ URLDownload[ source, $tempFile ];

createTemporary[ source: $$co ] :=
    addTempFile @ CopyFile[ source, $tempFile ];

createTemporary[ source: $$lo ] :=
    addTempFile @ CopyFile[ source, $tempFile ];

createTemporary[ source: $$resp ] :=
    addTempFile @ With[ { file = $tempFile },
        WithCleanup[
            BinaryWrite[ file, First @ source ],
            Close @ file
        ]
    ];

createTemporary // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*addTempFile*)
addTempFile // beginDefinition;

addTempFile[ file_? FileExistsQ ] :=
    addTempFile[ ExpandFileName @ file, $tempFiles ];

addTempFile[ file: $$string, files_Internal`Bag ] := (
    Internal`StuffBag[ files, file ];
    file
);

addTempFile[ other_ ] := throwFailure[ "CopyTemporaryFailed", other ];

addTempFile // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$tempFile*)
$tempFile // ClearAll;
$tempFile := FileNameJoin @ {
    gu`EnsureDirectory @ { $TemporaryDirectory, "FITImport" },
    CreateUUID[ ] <> ".fit"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitImportLibFunction*)
If[ MatchQ[ fitImportLibFunction, _LibraryFunction ],
    Quiet[ LibraryFunctionUnload @ fitImportLibFunction,
           LibraryFunction::nofun
    ]
];

fitImportLibFunction // ClearAll;
fitImportLibFunction := fitImportLibFunction = LibraryFunctionLoad[
    $libraryFile,
    "FITImport",
    { String },
    { Integer, 2 }
];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$libraryFile*)
$libraryFile // ClearAll;
$libraryFile := libraryFile @ $SystemID;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*libraryFile*)
libraryFile // beginDefinition;

libraryFile[ id_ ] := libraryFile[ id, $libFileLocation ];
libraryFile[ id_, file_? FileExistsQ ] := file;
libraryFile[ id_, location_ ] := libraryFile[ id, location, $libData @ id ];

libraryFile[ id_, location_, bytes_ByteArray ] :=
    WithCleanup[
        BinaryWrite[ location, bytes ],
        Close @ location
    ];

libraryFile[ id_, location_, _Missing ] :=
    throwFailure[ "IncompatibleSystemID", id ];

libraryFile // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fitKeyQ*)
fitKeyQ // ClearAll;
fitKeyQ[ key_ ] := MemberQ[ $fitKeys, key ];
fitKeyQ[ ___  ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$fitKeys*)
$fitKeys // ClearAll;
$fitKeys = {
    "Timestamp",
    "GeoPosition",
    "Distance",
    "TimeFromCourse",
    "TotalCycles",
    "AccumulatedPower",
    "EnhancedSpeed",
    "EnhancedAltitude",
    "Altitude",
    "Speed",
    "Power",
    "Grade",
    "CompressedAccumulatedPower",
    "VerticalSpeed",
    "Calories",
    "VerticalOscillation",
    "StanceTimePercent",
    "StanceTime",
    "BallSpeed",
    "Cadence256",
    "TotalHemoglobinConcentration",
    "TotalHemoglobinConcentrationMin",
    "TotalHemoglobinConcentrationMax",
    "SaturatedHemoglobinPercent",
    "SaturatedHemoglobinPercentMin",
    "SaturatedHemoglobinPercentMax",
    "HeartRate",
    "Cadence",
    "Resistance",
    "CycleLength",
    "Temperature",
    "Cycles",
    "LeftRightBalance",
    "GPSAccuracy",
    "ActivityType",
    "LeftTorqueEffectiveness",
    "RightTorqueEffectiveness",
    "LeftPedalSmoothness",
    "RightPedalSmoothness",
    "CombinedPedalSmoothness",
    "Time128",
    "StrokeType",
    "Zone",
    "FractionalCadence",
    "DeviceIndex"
};

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatFitData*)
formatFitData // beginDefinition;

formatFitData[ data_ ] :=
    Block[ { $start = data[[ 1, 1 ]] },
        makeFitAssociation /@ data
    ];

formatFitData // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*computeGradeQ*)
computeGradeQ // ClearAll;
computeGradeQ[ data_ ] := MatchQ[ data[[ All, 13 ]], { $invalidSINT16 .. } ];
computeGradeQ[ ___   ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeFitAssociation*)
makeFitAssociation // beginDefinition;

makeFitAssociation[ values_ ] :=
    AssociationMap[ fitValue[ #1, values ] &, $fitKeys ];

makeFitAssociation // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fitValue*)
fitValue // beginDefinition;

fitValue[ "Timestamp"                      , v_ ] := fitTimestamp @ v[[ 1 ]];
fitValue[ "GeoPosition"                    , v_ ] := fitGeoPosition @ v[[ 2;;3 ]];
fitValue[ "Distance"                       , v_ ] := fitDistance @ v[[ 4 ]];
fitValue[ "TimeFromCourse"                 , v_ ] := fitTimeFromCourse @ v[[ 5 ]];
fitValue[ "TotalCycles"                    , v_ ] := fitTotalCycles @ v[[ 6 ]];
fitValue[ "AccumulatedPower"               , v_ ] := fitAccumulatedPower @ v[[ { 1, 7 } ]];
fitValue[ "EnhancedSpeed"                  , v_ ] := fitEnhancedSpeed @ v[[ 8 ]];
fitValue[ "EnhancedAltitude"               , v_ ] := fitEnhancedAltitude @ v[[ 9 ]];
fitValue[ "Altitude"                       , v_ ] := fitAltitude @ v[[ 10 ]];
fitValue[ "Speed"                          , v_ ] := fitSpeed @ v[[ 11 ]];
fitValue[ "Power"                          , v_ ] := fitPower @ v[[ 12 ]];
fitValue[ "Grade"                          , v_ ] := fitGrade @ v[[ 13 ]];
fitValue[ "CompressedAccumulatedPower"     , v_ ] := fitCompressedAccumulatedPower @ v[[ 14 ]];
fitValue[ "VerticalSpeed"                  , v_ ] := fitVerticalSpeed @ v[[ 15 ]];
fitValue[ "Calories"                       , v_ ] := fitCalories @ v[[ 16 ]];
fitValue[ "VerticalOscillation"            , v_ ] := fitVerticalOscillation @ v[[ 17 ]];
fitValue[ "StanceTimePercent"              , v_ ] := fitStanceTimePercent @ v[[ 18 ]];
fitValue[ "StanceTime"                     , v_ ] := fitStanceTime @ v[[ 19 ]];
fitValue[ "BallSpeed"                      , v_ ] := fitBallSpeed @ v[[ 20 ]];
fitValue[ "Cadence256"                     , v_ ] := fitCadence256 @ v[[ 21 ]];
fitValue[ "TotalHemoglobinConcentration"   , v_ ] := fitTotalHemoglobinConcentration @ v[[ 22 ]];
fitValue[ "TotalHemoglobinConcentrationMin", v_ ] := fitTotalHemoglobinConcentrationMin @ v[[ 23 ]];
fitValue[ "TotalHemoglobinConcentrationMax", v_ ] := fitTotalHemoglobinConcentrationMax @ v[[ 24 ]];
fitValue[ "SaturatedHemoglobinPercent"     , v_ ] := fitSaturatedHemoglobinPercent @ v[[ 25 ]];
fitValue[ "SaturatedHemoglobinPercentMin"  , v_ ] := fitSaturatedHemoglobinPercentMin @ v[[ 26 ]];
fitValue[ "SaturatedHemoglobinPercentMax"  , v_ ] := fitSaturatedHemoglobinPercentMax @ v[[ 27 ]];
fitValue[ "HeartRate"                      , v_ ] := fitHeartRate @ v[[ 28 ]];
fitValue[ "Cadence"                        , v_ ] := fitCadence @ v[[ 29 ]];
fitValue[ "Resistance"                     , v_ ] := fitResistance @ v[[ 30 ]];
fitValue[ "CycleLength"                    , v_ ] := fitCycleLength @ v[[ 31 ]];
fitValue[ "Temperature"                    , v_ ] := fitTemperature @ v[[ 32 ]];
fitValue[ "Cycles"                         , v_ ] := fitCycles @ v[[ 33 ]];
fitValue[ "LeftRightBalance"               , v_ ] := fitLeftRightBalance @ v[[ 34 ]];
fitValue[ "GPSAccuracy"                    , v_ ] := fitGPSAccuracy @ v[[ 35 ]];
fitValue[ "ActivityType"                   , v_ ] := fitActivityType @ v[[ 36 ]];
fitValue[ "LeftTorqueEffectiveness"        , v_ ] := fitLeftTorqueEffectiveness @ v[[ 37 ]];
fitValue[ "RightTorqueEffectiveness"       , v_ ] := fitRightTorqueEffectiveness @ v[[ 38 ]];
fitValue[ "LeftPedalSmoothness"            , v_ ] := fitLeftPedalSmoothness @ v[[ 39 ]];
fitValue[ "RightPedalSmoothness"           , v_ ] := fitRightPedalSmoothness @ v[[ 40 ]];
fitValue[ "CombinedPedalSmoothness"        , v_ ] := fitCombinedPedalSmoothness @ v[[ 41 ]];
fitValue[ "Time128"                        , v_ ] := fitTime128 @ v[[ 42 ]];
fitValue[ "StrokeType"                     , v_ ] := fitStrokeType @ v[[ 43 ]];
fitValue[ "Zone"                           , v_ ] := fitZone @ v[[ 44 ]];
fitValue[ "FractionalCadence"              , v_ ] := fitFractionalCadence @ v[[ 45 ]];
fitValue[ "DeviceIndex"                    , v_ ] := fitDeviceIndex @ v[[ 46 ]];

fitValue[ _, _ ] := Missing[ "NotAvailable" ];

fitValue // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTimestamp*)
fitTimestamp // ClearAll;
fitTimestamp[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitTimestamp[ n_Integer ] := TimeZoneConvert @ DateObject[ n, TimeZone -> 0 ];
fitTimestamp[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitGeoPosition*)
fitGeoPosition // ClearAll;
fitGeoPosition[ { $invalidSINT32|0, _ } ] := Missing[ "NotAvailable" ];
fitGeoPosition[ { _, $invalidSINT32|0 } ] := Missing[ "NotAvailable" ];
fitGeoPosition[ { a_, b_ } ] := GeoPosition[ 8.381903175442434*^-8*{ a, b } ];
fitGeoPosition[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDistance*)
fitDistance // ClearAll;
fitDistance[ n_Integer ] := fitDistance[ n, $UnitSystem ];
fitDistance[ $invalidUINT32, "Imperial" ] := Quantity[ 0.0, "Miles" ];
fitDistance[ $invalidUINT32, _ ] := Quantity[ 0.0, "Meters" ];
fitDistance[ n_, "Imperial" ] := Quantity[ 6.213711922373339*^-6*n, "Miles" ];
fitDistance[ n_, _ ] := Quantity[ n/100.0, "Meters" ];
fitDistance[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTimeFromCourse*)
(* TODO *)
fitTimeFromCourse // ClearAll;
fitTimeFromCourse[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTotalCycles*)
fitTotalCycles // ClearAll;
fitTotalCycles[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitTotalCycles[ n_Integer ] := Quantity[ n, IndependentUnit[ "Cycles" ] ];
fitTotalCycles[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitAccumulatedPower*)
fitAccumulatedPower // ClearAll;
fitAccumulatedPower[ { $invalidUINT32, _ } ] := Missing[ "NotAvailable" ];
fitAccumulatedPower[ { _, $invalidUINT32 } ] := Quantity[ 0.0, "Kilojoules" ];
fitAccumulatedPower[ a_ ] := fitAccumulatedPower[ $start, a ];
fitAccumulatedPower[ t0_Integer, { t_Integer, n_Integer } ] := Quantity[ 0.001 * n * (t - t0), "Kilojoules" ];
fitAccumulatedPower[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitEnhancedSpeed*)
fitEnhancedSpeed // ClearAll;
(* TODO *)
fitEnhancedSpeed[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitEnhancedAltitude*)
fitEnhancedAltitude // ClearAll;
fitEnhancedAltitude[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitEnhancedAltitude[ n_Integer ] := fitEnhancedAltitude[ n, $UnitSystem ];
fitEnhancedAltitude[ n_, "Imperial" ] := Quantity[ 0.6561679790026247*n - 328.0839895013123, "Feet" ];
fitEnhancedAltitude[ n_, _ ] := Quantity[ 0.2 n - 100.0, "Meters" ];
fitEnhancedAltitude[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitAltitude*)
fitAltitude // ClearAll;
fitAltitude[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitAltitude[ n_Integer ] := fitAltitude[ n, $UnitSystem ];
fitAltitude[ n_, "Imperial" ] := Quantity[ 0.656168 n - 1640.42, "Feet" ];
fitAltitude[ n_, _ ] := Quantity[ 0.2 n - 500.0, "Meters" ];
fitAltitude[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSpeed*)
fitSpeed // ClearAll;
fitSpeed[ n_Integer ] := fitSpeed[ n, $UnitSystem ];
fitSpeed[ $invalidUINT16, "Imperial" ] := Quantity[ 0.0, "Miles"/"Hours" ];
fitSpeed[ $invalidUINT16, _ ] := Quantity[ 0.0, "Meters"/"Seconds" ];
fitSpeed[ n_, "Imperial" ] := Quantity[ 0.0022369362920544025*n, "Miles"/"Hours" ];
fitSpeed[ n_, _ ] := Quantity[ n/1000.0, "Meters"/"Seconds" ];
fitSpeed[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitPower*)
fitPower // ClearAll;
fitPower[ $invalidUINT16 ] := Quantity[ 0, "Watts" ];
fitPower[ n_Integer ] := Quantity[ n, "Watts" ];
fitPower[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitGrade*)
fitGrade // ClearAll;
(* TODO *)
fitGrade[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCompressedAccumulatedPower*)
fitCompressedAccumulatedPower // ClearAll;
(* TODO *)
fitCompressedAccumulatedPower[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitVerticalSpeed*)
fitVerticalSpeed // ClearAll;
(* TODO *)
fitVerticalSpeed[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCalories*)
fitCalories // ClearAll;
(* TODO *)
fitCalories[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitVerticalOscillation*)
fitVerticalOscillation // ClearAll;
(* TODO *)
fitVerticalOscillation[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitStanceTimePercent*)
fitStanceTimePercent // ClearAll;
(* TODO *)
fitStanceTimePercent[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitStanceTime*)
fitStanceTime // ClearAll;
(* TODO *)
fitStanceTime[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitBallSpeed*)
fitBallSpeed // ClearAll;
(* TODO *)
fitBallSpeed[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCadence256*)
fitCadence256 // ClearAll;
(* TODO *)
fitCadence256[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTotalHemoglobinConcentration*)
fitTotalHemoglobinConcentration // ClearAll;
(* TODO *)
fitTotalHemoglobinConcentration[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTotalHemoglobinConcentrationMin*)
fitTotalHemoglobinConcentrationMin // ClearAll;
(* TODO *)
fitTotalHemoglobinConcentrationMin[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTotalHemoglobinConcentrationMax*)
fitTotalHemoglobinConcentrationMax // ClearAll;
(* TODO *)
fitTotalHemoglobinConcentrationMax[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSaturatedHemoglobinPercent*)
fitSaturatedHemoglobinPercent // ClearAll;
(* TODO *)
fitSaturatedHemoglobinPercent[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSaturatedHemoglobinPercentMin*)
fitSaturatedHemoglobinPercentMin // ClearAll;
(* TODO *)
fitSaturatedHemoglobinPercentMin[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSaturatedHemoglobinPercentMax*)
fitSaturatedHemoglobinPercentMax // ClearAll;
(* TODO *)
fitSaturatedHemoglobinPercentMax[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitHeartRate*)
fitHeartRate // ClearAll;
fitHeartRate[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitHeartRate[ n_Integer ] := Quantity[ n, "Beats"/"Minute" ];
fitHeartRate[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCadence*)
fitCadence // ClearAll;
fitCadence[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitCadence[ n_Integer ] := Quantity[ n, "Revolutions"/"Minute" ];
fitCadence[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitResistance*)
fitResistance // ClearAll;
(* TODO *)
fitResistance[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCycleLength*)
fitCycleLength // ClearAll;
(* TODO *)
fitCycleLength[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTemperature*)
fitTemperature // ClearAll;
fitTemperature[ $invalidSINT8 ] := Missing[ "NotAvailable" ];
fitTemperature[ n_Integer ] := fitTemperature[ n, $UnitSystem ];
fitTemperature[ n_Integer, "Imperial" ] := Quantity[ 32.0 + 1.8 n, "DegreesFahrenheit" ];
fitTemperature[ n_Integer, _ ] := Quantity[ 1.0 * n, "DegreesCelsius" ];
fitTemperature[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCycles*)
fitCycles // ClearAll;
(* TODO *)
fitCycles[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitLeftRightBalance*)
fitLeftRightBalance // ClearAll;
(* TODO *)
fitLeftRightBalance[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitGPSAccuracy*)
fitGPSAccuracy // ClearAll;
(* TODO *)
fitGPSAccuracy[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitActivityType*)
fitActivityType // ClearAll;
(* TODO *)
fitActivityType[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitLeftTorqueEffectiveness*)
fitLeftTorqueEffectiveness // ClearAll;
(* TODO *)
fitLeftTorqueEffectiveness[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitRightTorqueEffectiveness*)
fitRightTorqueEffectiveness // ClearAll;
(* TODO *)
fitRightTorqueEffectiveness[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitLeftPedalSmoothness*)
fitLeftPedalSmoothness // ClearAll;
(* TODO *)
fitLeftPedalSmoothness[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitRightPedalSmoothness*)
fitRightPedalSmoothness // ClearAll;
(* TODO *)
fitRightPedalSmoothness[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCombinedPedalSmoothness*)
fitCombinedPedalSmoothness // ClearAll;
(* TODO *)
fitCombinedPedalSmoothness[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTime128*)
fitTime128 // ClearAll;
(* TODO *)
fitTime128[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitStrokeType*)
fitStrokeType // ClearAll;
(* TODO *)
fitStrokeType[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitZone*)
fitZone // ClearAll;
(* TODO *)
fitZone[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitFractionalCadence*)
fitFractionalCadence // ClearAll;
(* TODO *)
fitFractionalCadence[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDeviceIndex*)
fitDeviceIndex // ClearAll;
(* TODO *)
fitDeviceIndex[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

$$Utilities

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error handling*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, $failed = False, catchTop = # &, $start },
        Catch[ eval, $top ]
    ];

catchTop // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, params___ ] :=
    throwFailure[ MessageName[ FITImport, tag ], params ];

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
    throwFailure[ FITImport::Internal, $bugReportLink, HoldForm @ eval, a ];

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
        "Fragment" -> "FITImport"
    |>
];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Resources*)
$resourcesDir = FileNameJoin @ { DirectoryName @ $InputFileName, "LibraryResources" };

$libData := Replace[ $libData0, e_EvaluateInPlace :> First @ e ];


(* Built from https://github.com/rhennigan/FitnessData/actions/runs/3496171296 *)
$libData0 = EvaluateInPlace @ <|
    "Linux-x86-64"   -> ReadByteArray @ FileNameJoin @ { $resourcesDir, "Linux-x86-64"  , "FitnessData.so"    },
    "MacOSX-x86-64"  -> ReadByteArray @ FileNameJoin @ { $resourcesDir, "MacOSX-x86-64" , "FitnessData.dylib" },
    "Windows-x86-64" -> ReadByteArray @ FileNameJoin @ { $resourcesDir, "Windows-x86-64", "FitnessData.dll"   }
|>;