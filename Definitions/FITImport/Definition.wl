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
$invalidSINT8   = 127;
$invalidUINT8   = 255;
$invalidUINT8Z  = 0;
$invalidSINT16  = 32767;
$invalidUINT16  = 65535;
$invalidUINT16Z = 0;
$invalidSINT32  = 2147483647;
$invalidUINT32  = 4294967295;
$invalidUINT32Z = 0;

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

FITImport::InvalidFTP =
"The value `1` is not a valid value for functional threshold power.";

FITImport::InvalidMaxHR =
"The value `1` is not a valid value for maximum heart rate.";

FITImport::LibraryError =
"Encountered an internal library error: `1`";

FITImport::LibraryErrorConversion =
"Invalid FIT format: `1`";

FITImport::LibraryErrorUnexpectedEOF =
"Encountered an unexpected end of file in `1`.";

FITImport::LibraryErrorUnsupportedProtocol =
"Library error: FIT_IMPORT_ERROR_UNSUPPORTED_PROTOCOL (`1`).";

FITImport::LibraryErrorInternal =
"Library error: FIT_IMPORT_ERROR_INTERNAL (`1`). `4`";

FITImport::LibraryErrorOpenFile =
"Cannot read from file `2`. Check permissions and try again.";

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Attributes*)
FITImport // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Options*)
FITImport // Options = {
    "FunctionalThresholdPower" :> PersistentSymbol[ "FITImport/FunctionalThresholdPower" ],
    "MaxHeartRate"             :> PersistentSymbol[ "FITImport/MaxHeartRate" ],
    UnitSystem                 :> $UnitSystem
};

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)

$$string          = _String? StringQ;
$$bytes           = _ByteArray? ByteArrayQ;
$$assoc           = _Association? AssociationQ;
$$file            = File[ $$string ];
$$url             = URL[ $$string ];
$$co              = HoldPattern[ CloudObject ][ $$string, OptionsPattern[ ] ];
$$lo              = HoldPattern[ LocalObject ][ $$string, OptionsPattern[ ] ];
$$resp            = HoldPattern[ HTTPResponse ][ $$bytes, $$assoc, OptionsPattern[ ] ];
$$source          = $$string | $$file | $$url | $$co | $$lo | $$resp;
$$fitRecordKeys   = _? fitRecordKeyQ  | { ___? fitRecordKeyQ  };
$$fitEventKeys    = _? fitEventKeyQ | { ___? fitEventKeyQ };
$$elements        = _? elementQ | { ___? elementQ };
$$prop            = _? fitEventKeyQ | _? fitRecordKeyQ | _? elementQ;
$$propList        = { $$prop... };
$$props           = $$prop | $$propList;
$$messageType     = _? messageTypeQ;
$$messageTypes    = $$messageType | { $$messageType... };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
FITImport[ file_, opts: OptionsPattern[ ] ] :=
    catchTop @ FITImport[ file, "Dataset", opts ];

FITImport[ file_? FileExistsQ, "RawData", opts: OptionsPattern[ ] ] :=
    optionsBlock[ fitImport @ ExpandFileName @ file, opts ];

FITImport[ file_? FileExistsQ, "Data", opts: OptionsPattern[ ] ] :=
    optionsBlock[
        Module[ { data, messages },
            data     = FITImport[ file, "RawData", opts ];
            messages = selectMessageType[ data, "Record" ];
            formatFitData @ messages
        ],
        opts
    ];

FITImport[ file_? FileExistsQ, type: $$messageTypes, opts: OptionsPattern[ ] ] :=
    optionsBlock[
        Module[ { data },
            data = FITImport[ file, "RawData", opts ];
            makeMessageTypeData[ data, type ]
        ],
        opts
    ];

FITImport[ file_? FileExistsQ, "Dataset", opts: OptionsPattern[ ] ] :=
    catchTop @ Dataset @ KeyDrop[
        FITImport[ file, "Data", opts ],
        "MessageType"
    ];

FITImport[ file_, "MessageCounts", opts: OptionsPattern[ ] ] :=
    optionsBlock[
        Counts[ fitMessageType /@ fitMessageTypes @ file ],
        opts
    ];

FITImport[ file_, "Messages", opts: OptionsPattern[ ] ] :=
    optionsBlock[
        DeleteMissing /@ formatFitData @ FITImport[ file, "RawData", opts ],
        opts
    ];

FITImport[ file_, "MessageData", opts: OptionsPattern[ ] ] :=
    optionsBlock[
        Dataset @ GroupBy[
            FITImport[ file, "Messages", opts ],
            #MessageType &
        ],
        opts
    ];

FITImport[ file: $$file|$$string, prop_, opts: OptionsPattern[ ] ] /;
    ! FileExistsQ @ file :=
        With[ { found = FindFile @ file },
            FITImport[ found, prop, opts ] /; FileExistsQ @ found
        ];

FITImport[ _, "Elements", OptionsPattern[ ] ] :=
    Union[ $fitElements, $messageTypes ];

FITImport[ file_, key: $$fitRecordKeys, opts: OptionsPattern[ ] ] :=
    optionsBlock[
        Module[ { data, records },
            data = FITImport[ file, "RawData", opts ];
            records = selectMessageType[ data, "Record" ];
            makeTimeSeriesData[ "Record", records, key ]
        ],
        opts
    ];

FITImport[ file_, All, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { data },
        data  = FITImport[ file, "RawData", opts ];
        DeleteMissing @ makeTimeSeriesData[ "Record", data, $fitRecordKeys ]
    ];

FITImport[ file_, props: $$propList, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { data, fitKeys, elements, ts, as, joined },
        data     = FITImport[ file, "RawData", opts ];
        fitKeys  = Select[ props, fitRecordKeyQ ];
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
(* ::Section::Closed:: *)
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
    "Events",
    "RawData",
    "Records",
    "MessageCounts",
    "MessageData",
    "Messages"
};

$messageTypes = {
    "FileID",
    "Events",
    "Records",
    "DeviceInformation",
    "Session",
    "UserProfile"
};

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*optionsBlock*)
optionsBlock // beginDefinition;
optionsBlock // Attributes = { HoldFirst };

optionsBlock[ eval_, opts: OptionsPattern[ FITImport ] ] :=
    catchTop @ Block[
        {
            $FunctionalThresholdPower = OptionValue @ FunctionalThresholdPower,
            $MaxHeartRate             = OptionValue @ MaxHeartRate,
            $UnitSystem               = OptionValue @ UnitSystem,
            $ftp,
            $maxHR
        },
        $ftp   = setFTP @ $FunctionalThresholdPower;
        $maxHR = setMaxHR @ $MaxHeartRate;
        eval
    ];

optionsBlock // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*selectMessageType*)
selectMessageType // beginDefinition;

selectMessageType[ data_, type_String ] :=
    selectMessageType[ data, fitMessageTypeNumber @ type ];

selectMessageType[ data_, type_Integer ] :=
    Select[ data, #[[ 1 ]] === type & ];

selectMessageType // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*setFTP*)
setFTP // beginDefinition;

setFTP[ None|_Missing ] := None;
setFTP[ ftp_Integer   ] := N @ ftp;
setFTP[ ftp_Real      ] := ftp;

setFTP[ Quantity[ ftp_, "Watts" ] ] := setFTP @ ftp;
setFTP[ ftp_Quantity ] := setFTP @ UnitConvert[ ftp, "Watts" ];

setFTP[ ftp_ ] := throwFailure[ "InvalidFTP", ftp ];

setFTP // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*setMaxHR*)
setMaxHR // beginDefinition;

setMaxHR[ None|_Missing ] := None;
setMaxHR[ hr_Integer    ] := N @ hr;
setMaxHR[ hr_Real       ] := hr;

setMaxHR[ Quantity[ hr_, "Beats"/"Minutes" ] ] := setMaxHR @ hr;
setMaxHR[ hr_Quantity ] := setMaxHR @ UnitConvert[ hr, "Beats"/"Minutes" ];

setMaxHR[ hr_ ] := throwFailure[ "InvalidMaxHR", hr ];

setMaxHR // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*elementQ*)
elementQ[ elem_String ] := MemberQ[ $fitElements, elem ];
elementQ[ ___         ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*messageTypeQ*)
messageTypeQ[ type_String ] := MemberQ[ $messageTypes, type ];
messageTypeQ[ ___         ] := False;

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
    fitImport[
        source,
        file,
        Quiet[ fitImportLibFunction @ file, LibraryFunction::rterr ]
    ];

fitImport[ source_, file_, data_List? rawDataQ ] := (
    (* $start = data[[ 1, 1 ]]; *) (* Broken: need to ensure value is a timestamp *)
    data
);

fitImport[ source_, file_, err_LibraryFunctionError ] :=
    libraryError[ source, file, err ];

fitImport // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fitMessageTypes*)
fitMessageTypes // beginDefinition;

fitMessageTypes[ source: $$source ] :=
    Block[ { $tempFiles = Internal`Bag[ ] },
        WithCleanup[
            fitMessageTypes[ source, toFileString @ source ],
            DeleteFile /@ Internal`BagPart[ $tempFiles, All ]
        ]
    ];

fitMessageTypes[ source_, file_String ] :=
    fitMessageTypes[
        source,
        file,
        Quiet[ fitMessageTypesLibFunction @ file, LibraryFunction::rterr ]
    ];

fitMessageTypes[ source_, file_, data_List? rawDataQ ] :=
    data;

fitMessageTypes[ source_, file_, err_LibraryFunctionError ] :=
    libraryError[ source, file, err ];

fitImport // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*libraryError*)
libraryError // beginDefinition;

libraryError[
    source_,
    file_,
    LibraryFunctionError[ "LIBRARY_USER_ERROR", code_ ]
] := libraryUserError[ source, file, code ];

libraryError[ source_, file_, err_LibraryFunctionError ] :=
    throwFailure[ "LibraryError", err ];

libraryError // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*libraryUserError*)
libraryUserError // beginDefinition;

libraryUserError[ source_, file_, n_Integer ] :=
    With[ { tag = Lookup[ $libraryErrorCodes, n ] },
        throwFailure[ tag, source, file, n, $bugReportLink ] /; IntegerQ @ n
    ];

libraryUserError // endDefinition;

$libraryErrorCodes = <|
    8  -> "LibraryErrorConversion",
    9  -> "LibraryErrorUnexpectedEOF",
    10 -> "LibraryErrorConversion",
    11 -> "LibraryErrorUnsupportedProtocol",
    12 -> "LibraryErrorInternal",
    13 -> "LibraryErrorOpenFile"
|>;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*rawDataQ*)
rawDataQ[ { { } }  ] := False;
rawDataQ[ raw_List ] := MatrixQ[ raw, IntegerQ ];
rawDataQ[ ___      ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeMessageTypeData*)
makeMessageTypeData // beginDefinition;

makeMessageTypeData[ data_, type: $$messageType ] :=
    Module[ { ds },
        ds = makeMessageTypeData0[ data, type ];
        If[ MissingQ @ ds,
            ds,
            Dataset @ ds
        ]
    ];

makeMessageTypeData[ data_, types: { $$messageType.. } ] :=
    Dataset @ AssociationMap[ makeMessageTypeData0[ data, # ] &, types ];

makeMessageTypeData // endDefinition;

makeMessageTypeData0[ data_, type_ ] :=
    Module[ { formatted },
        formatted = formatFitData @ selectMessageType[ data, type ];
        If[ MissingQ @ formatted,
            formatted,
            KeyDrop[ formatted, "MessageType" ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeTimeSeriesData*)
makeTimeSeriesData // beginDefinition;

makeTimeSeriesData[ type_, data_, key_ ] :=
    makeTimeSeriesData[
        type,
        data,
        key,
        (fitValue[ type, "Timestamp", #1 ] &) /@ data
    ];

makeTimeSeriesData[ type_, data_, key_String, time_ ] :=
    Module[ { value },
        value = fitValue[ type, key, # ] & /@ data;
        If[ AllTrue[ value, MissingQ ],
            Missing[ "NotAvailable" ],
            TimeSeries @ Transpose @ { time, value }
        ]
    ];

makeTimeSeriesData[ type_, data_, keys_List, time_ ] :=
    AssociationMap[ makeTimeSeriesData[ type, data, #, time ] &, keys ];

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
(* ::Subsubsection::Closed:: *)
(*fitMessageTypesLibFunction*)
If[ MatchQ[ fitMessageTypesLibFunction, _LibraryFunction ],
    Quiet[ LibraryFunctionUnload @ fitMessageTypesLibFunction,
           LibraryFunction::nofun
    ]
];

fitMessageTypesLibFunction // ClearAll;
fitMessageTypesLibFunction := fitMessageTypesLibFunction = LibraryFunctionLoad[
    $libraryFile,
    "FITMessageTypes",
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
(*fitRecordKeyQ*)
fitRecordKeyQ // ClearAll;
fitRecordKeyQ[ key_ ] := MemberQ[ $fitRecordKeys, key ];
fitRecordKeyQ[ ___  ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fitEventKeyQ*)
fitEventKeyQ // ClearAll;
fitEventKeyQ[ key_ ] := MemberQ[ $fitEventKeys, key ];
fitEventKeyQ[ ___  ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Fit Keys*)
fitKeys // beginDefinition;
fitKeys[ "FileID"            ] := $fitFileIDKeys;
fitKeys[ "UserProfile"       ] := $fitUserProfileKeys;
fitKeys[ "Record"            ] := $fitRecordKeys;
fitKeys[ "Event"             ] := $fitEventKeys;
fitKeys[ "DeviceInformation" ] := $fitDeviceInformationKeys;
fitKeys[ "Session"           ] := $fitSessionKeys;
fitKeys[ _                   ] := $fitDefaultKeys;
fitKeys // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitFileIDKeys*)
$fitFileIDKeys // ClearAll;
$fitFileIDKeys = {
    "MessageType",
    "SerialNumber",
    "TimeCreated",
    "Manufacturer",
    "Product",
    "Number",
    "Type",
    "ProductName"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitUserProfileKeys*)
$fitUserProfileKeys // ClearAll;
$fitUserProfileKeys = {
    "MessageType",
    "MessageIndex",
    "Weight",
    "LocalID",
    "UserRunningStepLength",
    "UserWalkingStepLength",
    "Gender",
    "Age",
    "Height",
    "Language",
    "ElevationSetting",
    "WeightSetting",
    "RestingHeartRate",
    "DefaultMaxRunningHeartRate",
    "DefaultMaxBikingHeartRate",
    "DefaultMaxHeartRate",
    "HeartRateSetting",
    "SpeedSetting",
    "DistanceSetting",
    "PowerSetting",
    "ActivityClass",
    "PositionSetting",
    "TemperatureSetting",
    "HeightSetting",
    "FriendlyName",
    "GlobalID"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitRecordKeys*)
$fitRecordKeys // ClearAll;
$fitRecordKeys = {
    "MessageType",
    "Timestamp",
    "GeoPosition",
    "Distance",
    "TimeFromCourse",
    "TotalCycles",
    (* "AccumulatedPower", *) (* Currently broken *)
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
    "DeviceIndex",
    "PowerZone",
    "HeartRateZone"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitEventKeys*)
$fitEventKeys // ClearAll;
$fitEventKeys = {
    "MessageType",
    "Timestamp",
    "Data",
    "Data16",
    "Score",
    "OpponentScore",
    "Event",
    "EventType",
    "EventGroup",
    "FrontGearNum",
    "FrontGear",
    "RearGearNum",
    "RearGear",
    "RadarThreatLevelType",
    "RadarThreatCount"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitDeviceInformationKeys*)
$fitDeviceInformationKeys // ClearAll;
$fitDeviceInformationKeys = {
    "MessageType",
    "Timestamp",
    "DeviceType",
    "Manufacturer",
    "ProductName",
    "BatteryVoltage",
    "BatteryStatus",
    "Product",
    "SerialNumber",
    "CumulativeOperatingTime",
    "SoftwareVersion",
    "ANTDeviceNumber",
    "DeviceIndex",
    "HardwareVersion",
    "SensorPosition",
    "ANTTransmissionType",
    "ANTNetwork",
    "SourceType"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitSessionKeys*)
$fitSessionKeys // ClearAll;
$fitSessionKeys = {
    "MessageType",
    "Sport",
    "SubSport",
    "Timestamp",
    "StartTime",
    "StartPosition",
    "TotalElapsedTime",
    "TotalTimerTime",
    "TotalDistance",
    "TotalCycles",
    "AverageStrokeCount",
    "TotalWork",
    "TotalMovingTime",
    "NormalizedPower",
    "TrainingStressScore",
    "IntensityFactor",
    "LeftRightBalance",
    "TimeInHeartRateZone",
    "TimeInSpeedZone",
    "TimeInCadenceZone",
    "TimeInPowerZone",
    "AverageLapTime",
    "EnhancedAverageSpeed",
    "EnhancedMaxSpeed",
    "EnhancedAverageAltitude",
    "EnhancedMinAltitude",
    "EnhancedMaxAltitude",
    "TotalCalories",
    "TotalFatCalories",
    "AverageSpeed",
    "MaxSpeed",
    "AveragePower",
    "MaxPower",
    "TotalAscent",
    "TotalDescent",
    "NumberOfLaps",
    "NumberOfLengths",
    "AverageStrokeDistance",
    "PoolLength",
    "ThresholdPower",
    "NumberOfActiveLengths",
    "AverageAltitude",
    "MaxAltitude",
    "AverageGrade",
    "AveragePositiveGrade",
    "AverageNegativeGrade",
    "MaxPositiveGrade",
    "MaxNegativeGrade",
    "AveragePositiveVerticalSpeed",
    "AverageNegativeVerticalSpeed",
    "MaxPositiveVerticalSpeed",
    "MaxNegativeVerticalSpeed",
    "BestLapIndex",
    "MinAltitude",
    "PlayerScore",
    "OpponentScore",
    "StrokeCount",
    "ZoneCount",
    "MaxBallSpeed",
    "AverageBallSpeed",
    "AverageVerticalOscillation",
    "AverageStanceTimePercent",
    "AverageStanceTime",
    "AverageVAM",
    "Event",
    "EventType",
    "AverageHeartRate",
    "MaxHeartRate",
    "AverageCadence",
    "MaxCadence",
    "TotalAerobicTrainingEffect",
    "TotalAerobicTrainingEffectDescription",
    "TotalAnaerobicTrainingEffect",
    "TotalAnaerobicTrainingEffectDescription",
    "EventGroup",
    "Trigger",
    "SwimStroke",
    "PoolLengthUnit",
    "GeoBoundingBox",
    "GPSAccuracy",
    "AverageTemperature",
    "MaxTemperature",
    "MinHeartRate",
    "AverageFractionalCadence",
    "MaxFractionalCadence",
    "TotalFractionalCycles",
    "FirstLapIndex",
    "MessageIndex",
    "SportIndex"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitDefaultKeys*)
$fitDefaultKeys // ClearAll;
$fitDefaultKeys = {
    "MessageType",
    "RawData"
};

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatFitData*)
formatFitData // beginDefinition;

formatFitData[ data_ ] :=
    Module[ { fa, tr, filtered },
        (* fa = Block[ { $start = data[[ 1, 1 ]] }, makeFitAssociation /@ data ]; *) (* Broken: need to ensure value is a timestamp *)
        fa = makeFitAssociation /@ data;
        If[ ! MatchQ[ fa, { __Association } ],
            Throw[ Missing[ "NotAvailable" ], $tag ]
        ];
        tr = gu`AssociationTranspose @ fa;
        filtered = Select[ tr, Composition[ Not, AllTrue @ MissingQ ] ];
        gu`AssociationTranspose @ filtered
    ] ~Catch~ $tag;

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
    With[ { msgType = fitMessageType @ values },
        AssociationMap[ fitValue[ msgType, #1, values ] &, fitKeys @ msgType ]
    ];

makeFitAssociation // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fitMessageType*)
fitMessageType // ClearAll;
fitMessageType[ v_ ] := Lookup[ $fitMessageTypes, v[[ 1 ]], "UNKNOWN" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toNiceCamelCase*)
toNiceCamelCase // beginDefinition;

toNiceCamelCase[ s_String ] :=
    snakeToCamel @ StringDelete[ s, StartOfString~~$deletePrefixes ];

toNiceCamelCase // endDefinition;

$deletePrefixes = Alternatives[
    "FIT_ANT_NETWORK_",
    "FIT_ANTPLUS_DEVICE_TYPE_",
    "FIT_BODY_LOCATION_",
    "FIT_EVENT_TYPE_",
    "FIT_EVENT_",
    "FIT_MANUFACTURER_",
    "FIT_MESG_NUM_",
    "FIT_SOURCE_TYPE_",
    "FIT_SUB_SPORT_",
    "FIT_SPORT_",
    "FIT_SESSION_TRIGGER_",
    "FIT_SWIM_STROKE_",
    "FIT_DISPLAY_MEASURE_",
    "FIT_BATTERY_STATUS_",
    "FIT_FILE_"
];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*snakeToCamel*)
snakeToCamel // beginDefinition;

snakeToCamel[ s_String ] :=
    StringReplace[
        StringJoin @ ReplaceAll[
            Capitalize @ ToLowerCase @ StringSplit[ s, "_" ],
            $capitalizationRules1
        ],
        $capitalizationRules2
    ];

snakeToCamel // endDefinition;


$capitalizationRules1 // ClearAll;
$capitalizationRules1 = {
    "Id"    -> "ID",
    "Hr"    -> "HeartRate",
    "Hrm"   -> "HeartRateMonitor",
    "Sdm"   -> "SDM",
    "Met"   -> "MET",
    "Mesg"  -> "Message",
    "Ant"   -> "ANT",
    "Rx"    -> "Receive",
    "Tx"    -> "Transmit",
    "Info"  -> "Information",
    "Hrv"   -> "HeartRateVariability",
    "Gps"   -> "GPS",
    "Obdii" -> "OBDII",
    "Nmea"  -> "NMEA",
    "Ohr"   -> "OHR",
    "Aux"   -> "Auxiliary",
    "Elev"  -> "Elevation",
    "Comm"  -> "Communication",
    "Ftp"   -> "FTP"
};


$capitalizationRules2 // ClearAll;
$capitalizationRules2 = {
    "Antfs"   -> "ANTFS",
    "Antplus" -> "ANTPlus",
    "CadLow"  -> "CadenceLow",
    "CadHigh" -> "CadenceHigh"
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fitMessageTypes*)
$fitMessageTypes0 = <|
    0     -> "FIT_MESG_NUM_FILE_ID",
    1     -> "FIT_MESG_NUM_CAPABILITIES",
    2     -> "FIT_MESG_NUM_DEVICE_SETTINGS",
    3     -> "FIT_MESG_NUM_USER_PROFILE",
    4     -> "FIT_MESG_NUM_HRM_PROFILE",
    5     -> "FIT_MESG_NUM_SDM_PROFILE",
    6     -> "FIT_MESG_NUM_BIKE_PROFILE",
    7     -> "FIT_MESG_NUM_ZONES_TARGET",
    8     -> "FIT_MESG_NUM_HR_ZONE",
    9     -> "FIT_MESG_NUM_POWER_ZONE",
    10    -> "FIT_MESG_NUM_MET_ZONE",
    12    -> "FIT_MESG_NUM_SPORT",
    15    -> "FIT_MESG_NUM_GOAL",
    18    -> "FIT_MESG_NUM_SESSION",
    19    -> "FIT_MESG_NUM_LAP",
    20    -> "FIT_MESG_NUM_RECORD",
    21    -> "FIT_MESG_NUM_EVENT",
    23    -> "FIT_MESG_NUM_DEVICE_INFO",
    26    -> "FIT_MESG_NUM_WORKOUT",
    27    -> "FIT_MESG_NUM_WORKOUT_STEP",
    28    -> "FIT_MESG_NUM_SCHEDULE",
    30    -> "FIT_MESG_NUM_WEIGHT_SCALE",
    31    -> "FIT_MESG_NUM_COURSE",
    32    -> "FIT_MESG_NUM_COURSE_POINT",
    33    -> "FIT_MESG_NUM_TOTALS",
    34    -> "FIT_MESG_NUM_ACTIVITY",
    35    -> "FIT_MESG_NUM_SOFTWARE",
    37    -> "FIT_MESG_NUM_FILE_CAPABILITIES",
    38    -> "FIT_MESG_NUM_MESG_CAPABILITIES",
    39    -> "FIT_MESG_NUM_FIELD_CAPABILITIES",
    49    -> "FIT_MESG_NUM_FILE_CREATOR",
    51    -> "FIT_MESG_NUM_BLOOD_PRESSURE",
    53    -> "FIT_MESG_NUM_SPEED_ZONE",
    55    -> "FIT_MESG_NUM_MONITORING",
    72    -> "FIT_MESG_NUM_TRAINING_FILE",
    78    -> "FIT_MESG_NUM_HRV",
    80    -> "FIT_MESG_NUM_ANT_RX",
    81    -> "FIT_MESG_NUM_ANT_TX",
    82    -> "FIT_MESG_NUM_ANT_CHANNEL_ID",
    101   -> "FIT_MESG_NUM_LENGTH",
    103   -> "FIT_MESG_NUM_MONITORING_INFO",
    105   -> "FIT_MESG_NUM_PAD",
    106   -> "FIT_MESG_NUM_SLAVE_DEVICE",
    127   -> "FIT_MESG_NUM_CONNECTIVITY",
    128   -> "FIT_MESG_NUM_WEATHER_CONDITIONS",
    129   -> "FIT_MESG_NUM_WEATHER_ALERT",
    131   -> "FIT_MESG_NUM_CADENCE_ZONE",
    132   -> "FIT_MESG_NUM_HR",
    142   -> "FIT_MESG_NUM_SEGMENT_LAP",
    145   -> "FIT_MESG_NUM_MEMO_GLOB",
    148   -> "FIT_MESG_NUM_SEGMENT_ID",
    149   -> "FIT_MESG_NUM_SEGMENT_LEADERBOARD_ENTRY",
    150   -> "FIT_MESG_NUM_SEGMENT_POINT",
    151   -> "FIT_MESG_NUM_SEGMENT_FILE",
    158   -> "FIT_MESG_NUM_WORKOUT_SESSION",
    159   -> "FIT_MESG_NUM_WATCHFACE_SETTINGS",
    160   -> "FIT_MESG_NUM_GPS_METADATA",
    161   -> "FIT_MESG_NUM_CAMERA_EVENT",
    162   -> "FIT_MESG_NUM_TIMESTAMP_CORRELATION",
    164   -> "FIT_MESG_NUM_GYROSCOPE_DATA",
    165   -> "FIT_MESG_NUM_ACCELEROMETER_DATA",
    167   -> "FIT_MESG_NUM_THREE_D_SENSOR_CALIBRATION",
    169   -> "FIT_MESG_NUM_VIDEO_FRAME",
    174   -> "FIT_MESG_NUM_OBDII_DATA",
    177   -> "FIT_MESG_NUM_NMEA_SENTENCE",
    178   -> "FIT_MESG_NUM_AVIATION_ATTITUDE",
    184   -> "FIT_MESG_NUM_VIDEO",
    185   -> "FIT_MESG_NUM_VIDEO_TITLE",
    186   -> "FIT_MESG_NUM_VIDEO_DESCRIPTION",
    187   -> "FIT_MESG_NUM_VIDEO_CLIP",
    188   -> "FIT_MESG_NUM_OHR_SETTINGS",
    200   -> "FIT_MESG_NUM_EXD_SCREEN_CONFIGURATION",
    201   -> "FIT_MESG_NUM_EXD_DATA_FIELD_CONFIGURATION",
    202   -> "FIT_MESG_NUM_EXD_DATA_CONCEPT_CONFIGURATION",
    206   -> "FIT_MESG_NUM_FIELD_DESCRIPTION",
    207   -> "FIT_MESG_NUM_DEVELOPER_DATA_ID",
    208   -> "FIT_MESG_NUM_MAGNETOMETER_DATA",
    209   -> "FIT_MESG_NUM_BAROMETER_DATA",
    210   -> "FIT_MESG_NUM_ONE_D_SENSOR_CALIBRATION",
    225   -> "FIT_MESG_NUM_SET",
    227   -> "FIT_MESG_NUM_STRESS_LEVEL",
    258   -> "FIT_MESG_NUM_DIVE_SETTINGS",
    259   -> "FIT_MESG_NUM_DIVE_GAS",
    262   -> "FIT_MESG_NUM_DIVE_ALARM",
    264   -> "FIT_MESG_NUM_EXERCISE_TITLE",
    268   -> "FIT_MESG_NUM_DIVE_SUMMARY",
    285   -> "FIT_MESG_NUM_JUMP",
    317   -> "FIT_MESG_NUM_CLIMB_PRO",
    375   -> "FIT_MESG_NUM_DEVICE_AUX_BATTERY_INFO",
    65535 -> "FIT_MESG_NUM_INVALID"
|>;

$fitMessageTypes = toNiceCamelCase /@ $fitMessageTypes0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitMessageTypeNumber*)
fitMessageTypeNumber // beginDefinition;

fitMessageTypeNumber[ "Events"  ] := fitMessageTypeNumber[ "Event"  ];
fitMessageTypeNumber[ "Records" ] := fitMessageTypeNumber[ "Record" ];

fitMessageTypeNumber[ type_String ] :=
    With[ { n = $fitMessageTypeNumbers[ type ] }, n /; IntegerQ @ n ];

fitMessageTypeNumber // endDefinition;

$fitMessageTypeNumbers = AssociationMap[ Reverse, $fitMessageTypes ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fitValue*)
fitValue // beginDefinition;
fitValue[ type_, "MessageType", v_ ] := type;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*FileID*)
fitValue[ "FileID", "SerialNumber", v_ ] := fitSerialNumber @ v[[ 2 ]];
fitValue[ "FileID", "TimeCreated" , v_ ] := fitTimestamp @ v[[ 3 ]];
fitValue[ "FileID", "Manufacturer", v_ ] := fitManufacturer @ v[[ 4 ]];
fitValue[ "FileID", "Product"     , v_ ] := fitProduct @ v[[ 5 ]];
fitValue[ "FileID", "Number"      , v_ ] := fitUINT16 @ v[[ 6 ]];
fitValue[ "FileID", "Type"        , v_ ] := fitFileType @ v[[ 7 ]];
fitValue[ "FileID", "ProductName" , v_ ] := fitProductName[ v[[ 4;;5 ]], v[[ 8;;27 ]] ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*UserProfile*)
fitValue[ "UserProfile", "MessageIndex"              , v_ ] := fitUINT16 @ v[[ 2 ]];
fitValue[ "UserProfile", "Weight"                    , v_ ] := fitWeight @ v[[ 3 ]];
fitValue[ "UserProfile", "LocalID"                   , v_ ] := fitUINT16 @ v[[ 4 ]];
fitValue[ "UserProfile", "UserRunningStepLength"     , v_ ] := fitUINT16 @ v[[ 5 ]];
fitValue[ "UserProfile", "UserWalkingStepLength"     , v_ ] := fitUINT16 @ v[[ 6 ]];
fitValue[ "UserProfile", "Gender"                    , v_ ] := fitGender @ v[[ 7 ]];
fitValue[ "UserProfile", "Age"                       , v_ ] := fitAge @ v[[ 8 ]];
fitValue[ "UserProfile", "Height"                    , v_ ] := fitHeight @ v[[ 9 ]];
fitValue[ "UserProfile", "Language"                  , v_ ] := fitLanguage @ v[[ 10 ]];
fitValue[ "UserProfile", "ElevationSetting"          , v_ ] := fitDisplayMeasure @ v[[ 11 ]];
fitValue[ "UserProfile", "WeightSetting"             , v_ ] := fitDisplayMeasure @ v[[ 12 ]];
fitValue[ "UserProfile", "RestingHeartRate"          , v_ ] := fitHeartRate @ v[[ 13 ]];
fitValue[ "UserProfile", "DefaultMaxRunningHeartRate", v_ ] := fitHeartRate @ v[[ 14 ]];
fitValue[ "UserProfile", "DefaultMaxBikingHeartRate" , v_ ] := fitHeartRate @ v[[ 15 ]];
fitValue[ "UserProfile", "DefaultMaxHeartRate"       , v_ ] := fitHeartRate @ v[[ 16 ]];
fitValue[ "UserProfile", "HeartRateSetting"          , v_ ] := fitDisplayHeart @ v[[ 17 ]];
fitValue[ "UserProfile", "SpeedSetting"              , v_ ] := fitDisplayMeasure @ v[[ 18 ]];
fitValue[ "UserProfile", "DistanceSetting"           , v_ ] := fitDisplayMeasure @ v[[ 19 ]];
fitValue[ "UserProfile", "PowerSetting"              , v_ ] := fitDisplayPower @ v[[ 20 ]];
fitValue[ "UserProfile", "ActivityClass"             , v_ ] := fitActivityClass @ v[[ 21 ]];
fitValue[ "UserProfile", "PositionSetting"           , v_ ] := fitDisplayPosition @ v[[ 22 ]];
fitValue[ "UserProfile", "TemperatureSetting"        , v_ ] := fitDisplayMeasure @ v[[ 23 ]];
fitValue[ "UserProfile", "HeightSetting"             , v_ ] := fitDisplayMeasure @ v[[ 24 ]];
fitValue[ "UserProfile", "FriendlyName"              , v_ ] := fitString @ v[[ 25 ;; 40 ]];
fitValue[ "UserProfile", "GlobalID"                  , v_ ] := fitGlobalID @ v[[ 41 ;; 46 ]];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Record*)
fitValue[ "Record", "Timestamp"                      , v_ ] := fitTimestamp @ v[[ 2 ]];
fitValue[ "Record", "GeoPosition"                    , v_ ] := fitGeoPosition @ v[[ 3;;4 ]];
fitValue[ "Record", "Distance"                       , v_ ] := fitDistance @ v[[ 5 ]];
fitValue[ "Record", "TimeFromCourse"                 , v_ ] := fitTimeFromCourse @ v[[ 6 ]];
fitValue[ "Record", "TotalCycles"                    , v_ ] := fitTotalCycles @ v[[ 7 ]];
fitValue[ "Record", "AccumulatedPower"               , v_ ] := fitAccumulatedPower @ v[[ { 2, 8 } ]];
fitValue[ "Record", "EnhancedSpeed"                  , v_ ] := fitEnhancedSpeed @ v[[ 9 ]];
fitValue[ "Record", "EnhancedAltitude"               , v_ ] := fitEnhancedAltitude @ v[[ 10 ]];
fitValue[ "Record", "Altitude"                       , v_ ] := fitAltitude @ v[[ 11 ]];
fitValue[ "Record", "Speed"                          , v_ ] := fitSpeed @ v[[ 12 ]];
fitValue[ "Record", "Power"                          , v_ ] := fitPower @ v[[ 13 ]];
fitValue[ "Record", "Grade"                          , v_ ] := fitGrade @ v[[ 14 ]];
fitValue[ "Record", "CompressedAccumulatedPower"     , v_ ] := fitCompressedAccumulatedPower @ v[[ 15 ]];
fitValue[ "Record", "VerticalSpeed"                  , v_ ] := fitVerticalSpeed @ v[[ 16 ]];
fitValue[ "Record", "Calories"                       , v_ ] := fitCalories @ v[[ 17 ]];
fitValue[ "Record", "VerticalOscillation"            , v_ ] := fitVerticalOscillation @ v[[ 18 ]];
fitValue[ "Record", "StanceTimePercent"              , v_ ] := fitStanceTimePercent @ v[[ 19 ]];
fitValue[ "Record", "StanceTime"                     , v_ ] := fitStanceTime @ v[[ 20 ]];
fitValue[ "Record", "BallSpeed"                      , v_ ] := fitBallSpeed @ v[[ 21 ]];
fitValue[ "Record", "Cadence256"                     , v_ ] := fitCadence256 @ v[[ 22 ]];
fitValue[ "Record", "TotalHemoglobinConcentration"   , v_ ] := fitTotalHemoglobinConcentration @ v[[ 23 ]];
fitValue[ "Record", "TotalHemoglobinConcentrationMin", v_ ] := fitTotalHemoglobinConcentrationMin @ v[[ 24 ]];
fitValue[ "Record", "TotalHemoglobinConcentrationMax", v_ ] := fitTotalHemoglobinConcentrationMax @ v[[ 25 ]];
fitValue[ "Record", "SaturatedHemoglobinPercent"     , v_ ] := fitSaturatedHemoglobinPercent @ v[[ 26 ]];
fitValue[ "Record", "SaturatedHemoglobinPercentMin"  , v_ ] := fitSaturatedHemoglobinPercentMin @ v[[ 27 ]];
fitValue[ "Record", "SaturatedHemoglobinPercentMax"  , v_ ] := fitSaturatedHemoglobinPercentMax @ v[[ 28 ]];
fitValue[ "Record", "HeartRate"                      , v_ ] := fitHeartRate @ v[[ 29 ]];
fitValue[ "Record", "Cadence"                        , v_ ] := fitCadence @ v[[ 30 ]];
fitValue[ "Record", "Resistance"                     , v_ ] := fitResistance @ v[[ 31 ]];
fitValue[ "Record", "CycleLength"                    , v_ ] := fitCycleLength @ v[[ 32 ]];
fitValue[ "Record", "Temperature"                    , v_ ] := fitTemperature @ v[[ 33 ]];
fitValue[ "Record", "Cycles"                         , v_ ] := fitCycles @ v[[ 34 ]];
fitValue[ "Record", "LeftRightBalance"               , v_ ] := fitLeftRightBalance @ v[[ 35 ]];
fitValue[ "Record", "GPSAccuracy"                    , v_ ] := fitGPSAccuracy @ v[[ 36 ]];
fitValue[ "Record", "ActivityType"                   , v_ ] := fitActivityType @ v[[ 37 ]];
fitValue[ "Record", "LeftTorqueEffectiveness"        , v_ ] := fitLeftTorqueEffectiveness @ v[[ 38 ]];
fitValue[ "Record", "RightTorqueEffectiveness"       , v_ ] := fitRightTorqueEffectiveness @ v[[ 39 ]];
fitValue[ "Record", "LeftPedalSmoothness"            , v_ ] := fitLeftPedalSmoothness @ v[[ 40 ]];
fitValue[ "Record", "RightPedalSmoothness"           , v_ ] := fitRightPedalSmoothness @ v[[ 41 ]];
fitValue[ "Record", "CombinedPedalSmoothness"        , v_ ] := fitCombinedPedalSmoothness @ v[[ 42 ]];
fitValue[ "Record", "Time128"                        , v_ ] := fitTime128 @ v[[ 43 ]];
fitValue[ "Record", "StrokeType"                     , v_ ] := fitStrokeType @ v[[ 44 ]];
fitValue[ "Record", "Zone"                           , v_ ] := fitZone @ v[[ 45 ]];
fitValue[ "Record", "FractionalCadence"              , v_ ] := fitFractionalCadence @ v[[ 46 ]];
fitValue[ "Record", "DeviceIndex"                    , v_ ] := fitDeviceIndex @ v[[ 47 ]];
fitValue[ "Record", "PowerZone"                      , v_ ] := fitPowerZone @ v[[ 13 ]];
fitValue[ "Record", "HeartRateZone"                  , v_ ] := fitHeartRateZone @ v[[ 29 ]];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Event*)
fitValue[ "Event", "Timestamp"           , v_ ] := fitTimestamp @ v[[ 2 ]];
fitValue[ "Event", "Data"                , v_ ] := fitData @ v[[ 3 ]];
fitValue[ "Event", "Data16"              , v_ ] := fitData16 @ v[[ 4 ]];
fitValue[ "Event", "Score"               , v_ ] := fitScore @ v[[ 5 ]];
fitValue[ "Event", "OpponentScore"       , v_ ] := fitOpponentScore @ v[[ 6 ]];
fitValue[ "Event", "Event"               , v_ ] := fitEvent @ v[[ 7 ]];
fitValue[ "Event", "EventType"           , v_ ] := fitEventType @ v[[ 8 ]];
fitValue[ "Event", "EventGroup"          , v_ ] := fitEventGroup @ v[[ 9 ]];
fitValue[ "Event", "FrontGearNum"        , v_ ] := fitFrontGearNum @ v[[ 10 ]];
fitValue[ "Event", "FrontGear"           , v_ ] := fitFrontGear @ v[[ 11 ]];
fitValue[ "Event", "RearGearNum"         , v_ ] := fitRearGearNum @ v[[ 12 ]];
fitValue[ "Event", "RearGear"            , v_ ] := fitRearGear @ v[[ 13 ]];
fitValue[ "Event", "RadarThreatLevelType", v_ ] := fitRadarThreatLevelType @ v[[ 14 ]];
fitValue[ "Event", "RadarThreatCount"    , v_ ] := fitRadarThreatCount @ v[[ 15 ]];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*DeviceInformation*)
fitValue[ "DeviceInformation", "Timestamp"              , v_ ] := fitTimestamp @ v[[ 2 ]];
fitValue[ "DeviceInformation", "SerialNumber"           , v_ ] := fitSerialNumber @ v[[ 3 ]];
fitValue[ "DeviceInformation", "CumulativeOperatingTime", v_ ] := fitCumulativeOperatingTime @ v[[ 4 ]];
fitValue[ "DeviceInformation", "Manufacturer"           , v_ ] := fitManufacturer @ v[[ 5 ]];
fitValue[ "DeviceInformation", "Product"                , v_ ] := fitProduct @ v[[ 6 ]];
fitValue[ "DeviceInformation", "SoftwareVersion"        , v_ ] := fitSoftwareVersion @ v[[ 7 ]];
fitValue[ "DeviceInformation", "BatteryVoltage"         , v_ ] := fitBatteryVoltage @ v[[ 8 ]];
fitValue[ "DeviceInformation", "ANTDeviceNumber"        , v_ ] := fitANTDeviceNumber @ v[[ 9 ]];
fitValue[ "DeviceInformation", "DeviceIndex"            , v_ ] := fitDeviceIndex @ v[[ 10 ]];
fitValue[ "DeviceInformation", "DeviceType"             , v_ ] := fitDeviceType @ v[[ 11 ]];
fitValue[ "DeviceInformation", "HardwareVersion"        , v_ ] := fitHardwareVersion @ v[[ 12 ]];
fitValue[ "DeviceInformation", "BatteryStatus"          , v_ ] := fitBatteryStatus @ v[[ 13 ]];
fitValue[ "DeviceInformation", "SensorPosition"         , v_ ] := fitSensorPosition @ v[[ 14 ]];
fitValue[ "DeviceInformation", "ANTTransmissionType"    , v_ ] := fitANTTransmissionType @ v[[ 15 ]];
fitValue[ "DeviceInformation", "ANTNetwork"             , v_ ] := fitANTNetwork @ v[[ 16 ]];
fitValue[ "DeviceInformation", "SourceType"             , v_ ] := fitSourceType @ v[[ 17 ]];
fitValue[ "DeviceInformation", "ProductName"            , v_ ] := fitProductName[ v[[ 5;;6 ]], v[[ 18;;37 ]] ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Session*)
fitValue[ "Session", "Timestamp"                              , v_ ] := fitTimestamp @ v[[ 2 ]];
fitValue[ "Session", "StartTime"                              , v_ ] := fitTimestamp @ v[[ 3 ]];
fitValue[ "Session", "StartPosition"                          , v_ ] := fitGeoPosition @ v[[ 4;;5 ]];
fitValue[ "Session", "TotalElapsedTime"                       , v_ ] := fitTime @ v[[ 6 ]];
fitValue[ "Session", "TotalTimerTime"                         , v_ ] := fitTime @ v[[ 7 ]];
fitValue[ "Session", "TotalDistance"                          , v_ ] := fitDistance @ v[[ 8 ]];
fitValue[ "Session", "TotalCycles"                            , v_ ] := fitCycles @ v[[ 9 ]];
fitValue[ "Session", "GeoBoundingBox"                         , v_ ] := fitGeoBoundingBox @ v[[ 10;;13 ]];
fitValue[ "Session", "AverageStrokeCount"                     , v_ ] := fitAverageStrokeCount @ v[[ 14 ]];
fitValue[ "Session", "TotalWork"                              , v_ ] := fitWork @ v[[ 15 ]];
fitValue[ "Session", "TotalMovingTime"                        , v_ ] := fitTime @ v[[ 16 ]];
fitValue[ "Session", "TimeInHeartRateZone"                    , v_ ] := fitTimeInZone @ v[[ 17 ]];
fitValue[ "Session", "TimeInSpeedZone"                        , v_ ] := fitTimeInZone @ v[[ 18 ]];
fitValue[ "Session", "TimeInCadenceZone"                      , v_ ] := fitTimeInZone @ v[[ 19 ]];
fitValue[ "Session", "TimeInPowerZone"                        , v_ ] := fitTimeInZone @ v[[ 20 ]];
fitValue[ "Session", "AverageLapTime"                         , v_ ] := fitTime @ v[[ 21 ]];
fitValue[ "Session", "EnhancedAverageSpeed"                   , v_ ] := fitEnhancedSpeed @ v[[ 22 ]];
fitValue[ "Session", "EnhancedMaxSpeed"                       , v_ ] := fitEnhancedSpeed @ v[[ 23 ]];
fitValue[ "Session", "EnhancedAverageAltitude"                , v_ ] := fitEnhancedAltitude @ v[[ 24 ]];
fitValue[ "Session", "EnhancedMinAltitude"                    , v_ ] := fitEnhancedAltitude @ v[[ 25 ]];
fitValue[ "Session", "EnhancedMaxAltitude"                    , v_ ] := fitEnhancedAltitude @ v[[ 26 ]];
fitValue[ "Session", "MessageIndex"                           , v_ ] := fitMessageIndex @ v[[ 27 ]];
fitValue[ "Session", "TotalCalories"                          , v_ ] := fitCalories @ v[[ 28 ]];
fitValue[ "Session", "TotalFatCalories"                       , v_ ] := fitCalories @ v[[ 29 ]];
fitValue[ "Session", "AverageSpeed"                           , v_ ] := fitSpeed @ v[[ 30 ]];
fitValue[ "Session", "MaxSpeed"                               , v_ ] := fitSpeed @ v[[ 31 ]];
fitValue[ "Session", "AveragePower"                           , v_ ] := fitPower @ v[[ 32 ]];
fitValue[ "Session", "MaxPower"                               , v_ ] := fitPower @ v[[ 33 ]];
fitValue[ "Session", "TotalAscent"                            , v_ ] := fitAscent @ v[[ 34 ]];
fitValue[ "Session", "TotalDescent"                           , v_ ] := fitAscent @ v[[ 35 ]];
fitValue[ "Session", "FirstLapIndex"                          , v_ ] := fitUINT16 @ v[[ 36 ]];
fitValue[ "Session", "NumberOfLaps"                           , v_ ] := fitLaps @ v[[ 37 ]];
fitValue[ "Session", "NumberOfLengths"                        , v_ ] := fitLengths @ v[[ 38 ]];
fitValue[ "Session", "NormalizedPower"                        , v_ ] := fitPower @ v[[ 39 ]];
fitValue[ "Session", "TrainingStressScore"                    , v_ ] := fitTrainingStressScore @ v[[ 40 ]];
fitValue[ "Session", "IntensityFactor"                        , v_ ] := fitIntensityFactor @ v[[ 41 ]];
fitValue[ "Session", "LeftRightBalance"                       , v_ ] := fitLeftRightBalance @ v[[ 42 ]];
fitValue[ "Session", "AverageStrokeDistance"                  , v_ ] := fitMeters100 @ v[[ 43 ]];
fitValue[ "Session", "PoolLength"                             , v_ ] := fitMeters100 @ v[[ 44 ]];
fitValue[ "Session", "ThresholdPower"                         , v_ ] := fitPower @ v[[ 45 ]];
fitValue[ "Session", "NumberOfActiveLengths"                  , v_ ] := fitLengths @ v[[ 46 ]];
fitValue[ "Session", "AverageAltitude"                        , v_ ] := fitAltitude @ v[[ 47 ]];
fitValue[ "Session", "MaxAltitude"                            , v_ ] := fitAltitude @ v[[ 48 ]];
fitValue[ "Session", "AverageGrade"                           , v_ ] := fitGrade @ v[[ 49 ]];
fitValue[ "Session", "AveragePositiveGrade"                   , v_ ] := fitGrade @ v[[ 50 ]];
fitValue[ "Session", "AverageNegativeGrade"                   , v_ ] := fitGrade @ v[[ 51 ]];
fitValue[ "Session", "MaxPositiveGrade"                       , v_ ] := fitGrade @ v[[ 52 ]];
fitValue[ "Session", "MaxNegativeGrade"                       , v_ ] := fitGrade @ v[[ 53 ]];
fitValue[ "Session", "AveragePositiveVerticalSpeed"           , v_ ] := fitVerticalSpeed @ v[[ 54 ]];
fitValue[ "Session", "AverageNegativeVerticalSpeed"           , v_ ] := fitVerticalSpeed @ v[[ 55 ]];
fitValue[ "Session", "MaxPositiveVerticalSpeed"               , v_ ] := fitVerticalSpeed @ v[[ 56 ]];
fitValue[ "Session", "MaxNegativeVerticalSpeed"               , v_ ] := fitVerticalSpeed @ v[[ 57 ]];
fitValue[ "Session", "BestLapIndex"                           , v_ ] := fitUINT16 @ v[[ 58 ]];
fitValue[ "Session", "MinAltitude"                            , v_ ] := fitAltitude @ v[[ 59 ]];
fitValue[ "Session", "PlayerScore"                            , v_ ] := fitScore @ v[[ 60 ]];
fitValue[ "Session", "OpponentScore"                          , v_ ] := fitScore @ v[[ 61 ]];
fitValue[ "Session", "StrokeCount"                            , v_ ] := fitStrokeCount @ v[[ 62 ]];
fitValue[ "Session", "ZoneCount"                              , v_ ] := fitZoneCount @ v[[ 63 ]];
fitValue[ "Session", "MaxBallSpeed"                           , v_ ] := fitBallSpeed @ v[[ 64 ]];
fitValue[ "Session", "AverageBallSpeed"                       , v_ ] := fitBallSpeed @ v[[ 65 ]];
fitValue[ "Session", "AverageVerticalOscillation"             , v_ ] := fitVerticalOscillation @ v[[ 66 ]];
fitValue[ "Session", "AverageStanceTimePercent"               , v_ ] := fitStanceTimePercent @ v[[ 67 ]];
fitValue[ "Session", "AverageStanceTime"                      , v_ ] := fitStanceTime @ v[[ 68 ]];
fitValue[ "Session", "AverageVAM"                             , v_ ] := fitVerticalSpeed @ v[[ 69 ]];
fitValue[ "Session", "Event"                                  , v_ ] := fitEvent @ v[[ 70 ]];
fitValue[ "Session", "EventType"                              , v_ ] := fitEventType @ v[[ 71 ]];
fitValue[ "Session", "Sport"                                  , v_ ] := fitSport @ v[[ 72 ]];
fitValue[ "Session", "SubSport"                               , v_ ] := fitSubSport @ v[[ 73 ]];
fitValue[ "Session", "AverageHeartRate"                       , v_ ] := fitHeartRate @ v[[ 74 ]];
fitValue[ "Session", "MaxHeartRate"                           , v_ ] := fitHeartRate @ v[[ 75 ]];
fitValue[ "Session", "AverageCadence"                         , v_ ] := fitCadence @ v[[ 76 ]];
fitValue[ "Session", "MaxCadence"                             , v_ ] := fitCadence @ v[[ 77 ]];
fitValue[ "Session", "TotalAerobicTrainingEffect"             , v_ ] := fitTrainingEffect @ v[[ 78 ]];
fitValue[ "Session", "TotalAerobicTrainingEffectDescription"  , v_ ] := fitTrainingEffectDescription @ v[[ 78 ]];
fitValue[ "Session", "EventGroup"                             , v_ ] := fitEventGroup @ v[[ 79 ]];
fitValue[ "Session", "Trigger"                                , v_ ] := fitSessionTrigger @ v[[ 80 ]];
fitValue[ "Session", "SwimStroke"                             , v_ ] := fitSwimStroke @ v[[ 81 ]];
fitValue[ "Session", "PoolLengthUnit"                         , v_ ] := fitDisplayMeasure @ v[[ 82 ]];
fitValue[ "Session", "GPSAccuracy"                            , v_ ] := fitGPSAccuracy @ v[[ 83 ]];
fitValue[ "Session", "AverageTemperature"                     , v_ ] := fitTemperature @ v[[ 84 ]];
fitValue[ "Session", "MaxTemperature"                         , v_ ] := fitTemperature @ v[[ 85 ]];
fitValue[ "Session", "MinHeartRate"                           , v_ ] := fitHeartRate @ v[[ 86 ]];
fitValue[ "Session", "AverageFractionalCadence"               , v_ ] := fitFractionalCadence @ v[[ 87 ]];
fitValue[ "Session", "MaxFractionalCadence"                   , v_ ] := fitFractionalCadence @ v[[ 88 ]];
fitValue[ "Session", "TotalFractionalCycles"                  , v_ ] := fitFractionalCycles @ v[[ 89 ]];
fitValue[ "Session", "SportIndex"                             , v_ ] := fitUINT8 @ v[[ 90 ]];
fitValue[ "Session", "TotalAnaerobicTrainingEffect"           , v_ ] := fitTrainingEffect @ v[[ 91 ]];
fitValue[ "Session", "TotalAnaerobicTrainingEffectDescription", v_ ] := fitTrainingEffectDescription @ v[[ 91 ]];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Default*)
fitValue[ _, "RawData", v_ ] := ByteArray @ v[[ 2;; ]];
fitValue[ _, _, _ ] := Missing[ "NotAvailable" ];
fitValue // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitUINT8*)
fitUINT8 // ClearAll;
fitUINT8[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitUINT8[ n_Integer ] := n;
fitUINT8[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitUINT16*)
fitUINT16 // ClearAll;
fitUINT16[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitUINT16[ n_Integer ] := n;
fitUINT16[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSINT16*)
fitSINT16 // ClearAll;
fitSINT16[ $invalidSINT16 ] := Missing[ "NotAvailable" ];
fitSINT16[ n_Integer ] := n;
fitSINT16[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitString*)
fitString // ClearAll;
fitString[ { 0, ___ } ] := Missing[ "NotAvailable" ];
fitString[ bytes: { __Integer } ] := FromCharacterCode[ TakeWhile[ bytes, Positive ], "UTF-8" ];
fitString[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitGlobalID*)
fitGlobalID // ClearAll;
fitGlobalID[ { 255 .. } ] := Missing[ "NotAvailable" ];
fitGlobalID[ bytes: { __Integer } ] := FromDigits[ bytes, 256 ];
fitGlobalID[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTimestamp*)
fitTimestamp // ClearAll;
fitTimestamp[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitTimestamp[ n_Integer ] := TimeZoneConvert @ DateObject[ n, TimeZone -> 0 ];
fitTimestamp[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTime*)
fitTime // ClearAll;
fitTime[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitTime[ n_Integer ] := secondsToQuantity[ n/1000.0 ];
fitTime[ ___ ] := Missing[ "NotAvailable" ];

secondsToQuantity := secondsToQuantity =
    ResourceFunction[ "SecondsToQuantity", "Function" ];

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
(*fitGeoBoundingBox*)
fitGeoBoundingBox // ClearAll;

fitGeoBoundingBox[ { neLat_, neLon_, swLat_, swLon_ } ] :=
    fitGeoBoundingBox @ {
        fitGeoPosition @ { swLat, swLon },
        fitGeoPosition @ { neLat, neLon }
    };

fitGeoBoundingBox[ bounds: { _GeoPosition, _GeoPosition } ] :=
    bounds;

fitGeoBoundingBox[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitWeight*)
fitWeight // ClearAll;
fitWeight[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitWeight[ n_Integer ] := fitWeight[ n, $UnitSystem ];
fitWeight[ n_Integer, "Imperial" ] := Quantity[ 0.220462 * n, "Pounds" ];
fitWeight[ n_Integer, _ ] := Quantity[ n/10.0, "Kilograms" ];
fitWeight[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitAge*)
fitAge // ClearAll;
fitAge[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitAge[ n_Integer ] := Quantity[ n, "Years" ];
fitAge[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitHeight*)
fitHeight // ClearAll;
fitHeight[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitHeight[ n_Integer ] := fitHeight[ n, $UnitSystem ];
fitHeight[ n_Integer, "Imperial" ] := Quantity[ With[ { x = 0.0328 * n }, MixedMagnitude @ { IntegerPart @ x, 12 * FractionalPart @ x } ], MixedUnit @ { "Feet", "Inches" } ];
fitHeight[ n_Integer, _ ] := Quantity[ n/100.0, "Meters" ];
fitHeight[ ___ ] := Missing[ "NotAvailable" ];

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
(*fitWork*)
fitWork // ClearAll;
fitWork[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitWork[ n_Integer ] := Quantity[ n/1000.0, "Kilojoules" ];
fitWork[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTimeFromCourse*)
fitTimeFromCourse // ClearAll;
(* TODO *)
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
(*fitTimeInZone*)
fitTimeInZone // ClearAll;
fitTimeInZone[ ___ ] := Missing[ "NotAvailable" ];

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
(*fitAscent*)
fitAscent // ClearAll;
fitAscent[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitAscent[ n_Integer ] := fitAscent[ n, $UnitSystem ];
fitAscent[ n_, "Imperial" ] := Quantity[ 3.28084 * n, "Feet" ];
fitAscent[ n_, _ ] := Quantity[ n, "Meters" ];

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
(*fitAverageSpeed*)
fitAverageSpeed // ClearAll;
fitAverageSpeed[ 0|$invalidUINT32 ] := Missing[ "NotAvailable" ];
fitAverageSpeed[ n_Integer ] := fitAverageSpeed[ n, $UnitSystem ];
fitAverageSpeed[ n_, "Imperial" ] := Quantity[ 0.0022369362920544025*n, "Miles"/"Hours" ];
fitAverageSpeed[ n_, _ ] := Quantity[ n/1000.0, "Meters"/"Seconds" ];
fitAverageSpeed[ ___ ] := Missing[ "NotAvailable" ];

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
fitGrade[ $invalidSINT16 ] := Missing[ "NotAvailable" ];
fitGrade[ n_Integer ] := Quantity[ 0.01 * n, "Percent" ];
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
fitVerticalSpeed[ $invalidSINT16 ] := Missing[ "NotAvailable" ];
fitVerticalSpeed[ n_Integer ] := fitVerticalSpeed[ n, $UnitSystem ];
fitVerticalSpeed[ n_, "Imperial" ] := Quantity[ 0.00328084 * n, "Feet"/"Seconds" ];
fitVerticalSpeed[ n_, _ ] := Quantity[ n / 1000.0, "Meters"/"Seconds" ];
fitVerticalSpeed[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCalories*)
fitCalories // ClearAll;
fitCalories[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitCalories[ n_Integer ] := Quantity[ n, "DietaryCalories" ];
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
fitStanceTimePercent[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitStanceTimePercent[ n_Integer ] := Quantity[ 0.01 * n, "Percent" ];
fitStanceTimePercent[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitStanceTime*)
fitStanceTime // ClearAll;
fitStanceTime[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitStanceTime[ n_Integer ] := Quantity[ n/10.0, "Milliseconds" ];
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
fitLeftRightBalance[ $invalidUINT16 ] := Missing[ "NotAvailable" ];

fitLeftRightBalance[ n_Integer ] /; n >= 32768 :=
    With[ { bal = BitAnd[ n, 16383 ] / 100.0 },
        {
            Quantity[ 100 - bal, "Percent" ],
            Quantity[ bal      , "Percent" ]
        }
    ];

fitLeftRightBalance[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitGPSAccuracy*)
fitGPSAccuracy // ClearAll;
fitGPSAccuracy[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitGPSAccuracy[ n_Integer ] := Quantity[ n, "Meters" ];
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
fitFractionalCadence[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitFractionalCadence[ n_Integer ] := Quantity[ n/128.0, "Revolutions"/"Minute" ];
fitFractionalCadence[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitFractionalCycles*)
fitFractionalCycles // ClearAll;
fitFractionalCycles[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitFractionalCycles[ n_Integer ] := Quantity[ n/128.0, "Revolutions" ];
fitFractionalCycles[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDeviceIndex*)
fitDeviceIndex // ClearAll;
(* TODO *)
fitDeviceIndex[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitPowerZone*)
fitPowerZone // ClearAll;
fitPowerZone[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitPowerZone[ n_Integer ] := fitPowerZone[ n, $ftp ];
fitPowerZone[ n_, ftp_Real ] := fitPowerZone0[ n / ftp ];
fitPowerZone[ a___ ] := Missing[ "NotAvailable" ];

fitPowerZone0[ p_ ] :=
    Which[ p > 1.50, 7,
           p > 1.20, 6,
           p > 1.05, 5,
           p > 0.90, 4,
           p > 0.75, 3,
           p > 0.55, 2,
           p > 0.05, 1,
           True,     Missing[ "NotAvailable" ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitHeartRateZone*)
fitHeartRateZone // ClearAll;
fitHeartRateZone[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitHeartRateZone[ n_Integer ] := fitHeartRateZone[ n, $maxHR ];
fitHeartRateZone[ n_Integer, max_Real ] := fitHeartRateZone0[ n / max ];
fitHeartRateZone[ ___ ] := Missing[ "NotAvailable" ];

fitHeartRateZone0[ p_ ] :=
    Which[ p > 1.06, 5,
           p > 0.95, 4,
           p > 0.84, 3,
           p > 0.69, 2,
           True,     1
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitData*)
fitData // ClearAll;
(* TODO *)
fitData[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitData16*)
fitData16 // ClearAll;
(* TODO *)
fitData16[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitMessageIndex*)
fitMessageIndex // ClearAll;
fitMessageIndex[ 32768 ] := "Selected";
fitMessageIndex[ 28672 ] := "Reserved";
fitMessageIndex[ 4095  ] := "Mask";
fitMessageIndex[ ___   ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitScore*)
fitScore // ClearAll;
(* TODO *)
fitScore[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitOpponentScore*)
fitOpponentScore // ClearAll;
(* TODO *)
fitOpponentScore[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitFileType*)
fitFileType // ClearAll;
fitFileType[ n_Integer ] := Lookup[ $fitFileTypes, n, Missing[ "NotAvailable" ] ];
fitFileType[ ___ ] := Missing[ "NotAvailable" ];

$fitFileTypes0 = <|
    1  -> "FIT_FILE_DEVICE",
    2  -> "FIT_FILE_SETTINGS",
    3  -> "FIT_FILE_SPORT",
    4  -> "FIT_FILE_ACTIVITY",
    5  -> "FIT_FILE_WORKOUT",
    6  -> "FIT_FILE_COURSE",
    7  -> "FIT_FILE_SCHEDULES",
    9  -> "FIT_FILE_WEIGHT",
    10 -> "FIT_FILE_TOTALS",
    11 -> "FIT_FILE_GOALS",
    14 -> "FIT_FILE_BLOOD_PRESSURE",
    15 -> "FIT_FILE_MONITORING_A",
    20 -> "FIT_FILE_ACTIVITY_SUMMARY",
    28 -> "FIT_FILE_MONITORING_DAILY",
    32 -> "FIT_FILE_MONITORING_B",
    34 -> "FIT_FILE_SEGMENT",
    35 -> "FIT_FILE_SEGMENT_LIST",
    40 -> "FIT_FILE_EXD_CONFIGURATION"
|>;

$fitFileTypes = toNiceCamelCase /@ $fitFileTypes0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitEvent*)
fitEvent // ClearAll;
fitEvent[ n_Integer ] := Lookup[ $fitEvents, n, Missing[ "NotAvailable" ] ];
fitEvent[ ___ ] := Missing[ "NotAvailable" ];

$fitEvents0 = <|
    0  -> "FIT_EVENT_TIMER",
    3  -> "FIT_EVENT_WORKOUT",
    4  -> "FIT_EVENT_WORKOUT_STEP",
    5  -> "FIT_EVENT_POWER_DOWN",
    6  -> "FIT_EVENT_POWER_UP",
    7  -> "FIT_EVENT_OFF_COURSE",
    8  -> "FIT_EVENT_SESSION",
    9  -> "FIT_EVENT_LAP",
    10 -> "FIT_EVENT_COURSE_POINT",
    11 -> "FIT_EVENT_BATTERY",
    12 -> "FIT_EVENT_VIRTUAL_PARTNER_PACE",
    13 -> "FIT_EVENT_HR_HIGH_ALERT",
    14 -> "FIT_EVENT_HR_LOW_ALERT",
    15 -> "FIT_EVENT_SPEED_HIGH_ALERT",
    16 -> "FIT_EVENT_SPEED_LOW_ALERT",
    17 -> "FIT_EVENT_CAD_HIGH_ALERT",
    18 -> "FIT_EVENT_CAD_LOW_ALERT",
    19 -> "FIT_EVENT_POWER_HIGH_ALERT",
    20 -> "FIT_EVENT_POWER_LOW_ALERT",
    21 -> "FIT_EVENT_RECOVERY_HR",
    22 -> "FIT_EVENT_BATTERY_LOW",
    23 -> "FIT_EVENT_TIME_DURATION_ALERT",
    24 -> "FIT_EVENT_DISTANCE_DURATION_ALERT",
    25 -> "FIT_EVENT_CALORIE_DURATION_ALERT",
    26 -> "FIT_EVENT_ACTIVITY",
    27 -> "FIT_EVENT_FITNESS_EQUIPMENT",
    28 -> "FIT_EVENT_LENGTH",
    32 -> "FIT_EVENT_USER_MARKER",
    33 -> "FIT_EVENT_SPORT_POINT",
    36 -> "FIT_EVENT_CALIBRATION",
    42 -> "FIT_EVENT_FRONT_GEAR_CHANGE",
    43 -> "FIT_EVENT_REAR_GEAR_CHANGE",
    44 -> "FIT_EVENT_RIDER_POSITION_CHANGE",
    45 -> "FIT_EVENT_ELEV_HIGH_ALERT",
    46 -> "FIT_EVENT_ELEV_LOW_ALERT",
    47 -> "FIT_EVENT_COMM_TIMEOUT",
    75 -> "FIT_EVENT_RADAR_THREAT_ALERT"
|>;

$fitEvents = toNiceCamelCase /@ $fitEvents0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitEventType*)
fitEventType // ClearAll;
fitEventType[ n_Integer ] := Lookup[ $fitEventTypes, n, Missing[ "NotAvailable" ] ];
fitEventType[ ___ ] := Missing[ "NotAvailable" ];

$fitEventTypes0 = <|
    0 -> "FIT_EVENT_TYPE_START",
    1 -> "FIT_EVENT_TYPE_STOP",
    2 -> "FIT_EVENT_TYPE_CONSECUTIVE_DEPRECIATED",
    3 -> "FIT_EVENT_TYPE_MARKER",
    4 -> "FIT_EVENT_TYPE_STOP_ALL",
    5 -> "FIT_EVENT_TYPE_BEGIN_DEPRECIATED",
    6 -> "FIT_EVENT_TYPE_END_DEPRECIATED",
    7 -> "FIT_EVENT_TYPE_END_ALL_DEPRECIATED",
    8 -> "FIT_EVENT_TYPE_STOP_DISABLE",
    9 -> "FIT_EVENT_TYPE_STOP_DISABLE_ALL"
|>;

$fitEventTypes = toNiceCamelCase /@ $fitEventTypes0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitEventGroup*)
fitEventGroup // ClearAll;
fitEventGroup[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitEventGroup[ n_Integer ] := n;
fitEventGroup[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitFrontGearNum*)
fitFrontGearNum // ClearAll;
fitFrontGearNum[ $invalidUINT8Z ] := Missing[ "NotAvailable" ];
fitFrontGearNum[ n_Integer ] := n;
fitFrontGearNum[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitFrontGear*)
fitFrontGear // ClearAll;
fitFrontGear[ $invalidUINT8Z ] := Missing[ "NotAvailable" ];
fitFrontGear[ n_Integer ] := n;
fitFrontGear[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitRearGearNum*)
fitRearGearNum // ClearAll;
fitRearGearNum[ $invalidUINT8Z ] := Missing[ "NotAvailable" ];
fitRearGearNum[ n_Integer ] := n;
fitRearGearNum[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitRearGear*)
fitRearGear // ClearAll;
fitRearGear[ $invalidUINT8Z ] := Missing[ "NotAvailable" ];
fitRearGear[ n_Integer ] := n;
fitRearGear[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitRadarThreatLevelType*)
fitRadarThreatLevelType // ClearAll;
fitRadarThreatLevelType[ n_Integer ] := Lookup[ $fitRadarThreatLevelTypes, n, Missing[ "NotAvailable" ] ];
fitRadarThreatLevelType[ ___ ] := Missing[ "NotAvailable" ];

$fitRadarThreatLevelTypes = <|
    0 -> "THREAT_UNKNOWN",
    1 -> "THREAT_NONE",
    2 -> "THREAT_APPROACHING",
    3 -> "THREAT_APPROACHING_FAST"
|>;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitRadarThreatCount*)
fitRadarThreatCount // ClearAll;
fitRadarThreatCount[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitRadarThreatCount[ n_Integer ] := n;
fitRadarThreatCount[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSerialNumber*)
fitSerialNumber // ClearAll;
fitSerialNumber[ $invalidUINT32Z ] := Missing[ "NotAvailable" ];
fitSerialNumber[ n_Integer ] := n;
fitSerialNumber[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitCumulativeOperatingTime*)
fitCumulativeOperatingTime // ClearAll;
fitCumulativeOperatingTime[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitCumulativeOperatingTime[ n_Integer ] := Quantity[ n, "Seconds" ];
fitCumulativeOperatingTime[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitManufacturer*)
fitManufacturer // ClearAll;
fitManufacturer[ n_Integer ] := Lookup[ $fitManufacturers, n, Missing[ "NotAvailable" ] ];
fitManufacturer[ ___ ] := Missing[ "NotAvailable" ];

$fitManufacturers0 = <|
    1    -> "FIT_MANUFACTURER_GARMIN",
    3    -> "FIT_MANUFACTURER_ZEPHYR",
    4    -> "FIT_MANUFACTURER_DAYTON",
    5    -> "FIT_MANUFACTURER_IDT",
    6    -> "FIT_MANUFACTURER_SRM",
    7    -> "FIT_MANUFACTURER_QUARQ",
    8    -> "FIT_MANUFACTURER_IBIKE",
    9    -> "FIT_MANUFACTURER_SARIS",
    10   -> "FIT_MANUFACTURER_SPARK_HK",
    11   -> "FIT_MANUFACTURER_TANITA",
    12   -> "FIT_MANUFACTURER_ECHOWELL",
    13   -> "FIT_MANUFACTURER_DYNASTREAM_OEM",
    14   -> "FIT_MANUFACTURER_NAUTILUS",
    15   -> "FIT_MANUFACTURER_DYNASTREAM",
    16   -> "FIT_MANUFACTURER_TIMEX",
    17   -> "FIT_MANUFACTURER_METRIGEAR",
    18   -> "FIT_MANUFACTURER_XELIC",
    19   -> "FIT_MANUFACTURER_BEURER",
    20   -> "FIT_MANUFACTURER_CARDIOSPORT",
    21   -> "FIT_MANUFACTURER_A_AND_D",
    22   -> "FIT_MANUFACTURER_HMM",
    23   -> "FIT_MANUFACTURER_SUUNTO",
    24   -> "FIT_MANUFACTURER_THITA_ELEKTRONIK",
    25   -> "FIT_MANUFACTURER_GPULSE",
    26   -> "FIT_MANUFACTURER_CLEAN_MOBILE",
    27   -> "FIT_MANUFACTURER_PEDAL_BRAIN",
    28   -> "FIT_MANUFACTURER_PEAKSWARE",
    29   -> "FIT_MANUFACTURER_SAXONAR",
    30   -> "FIT_MANUFACTURER_LEMOND_FITNESS",
    31   -> "FIT_MANUFACTURER_DEXCOM",
    32   -> "FIT_MANUFACTURER_WAHOO_FITNESS",
    33   -> "FIT_MANUFACTURER_OCTANE_FITNESS",
    34   -> "FIT_MANUFACTURER_ARCHINOETICS",
    35   -> "FIT_MANUFACTURER_THE_HURT_BOX",
    36   -> "FIT_MANUFACTURER_CITIZEN_SYSTEMS",
    37   -> "FIT_MANUFACTURER_MAGELLAN",
    38   -> "FIT_MANUFACTURER_OSYNCE",
    39   -> "FIT_MANUFACTURER_HOLUX",
    41   -> "FIT_MANUFACTURER_SHIMANO",
    42   -> "FIT_MANUFACTURER_ONE_GIANT_LEAP",
    43   -> "FIT_MANUFACTURER_ACE_SENSOR",
    44   -> "FIT_MANUFACTURER_BRIM_BROTHERS",
    45   -> "FIT_MANUFACTURER_XPLOVA",
    46   -> "FIT_MANUFACTURER_PERCEPTION_DIGITAL",
    48   -> "FIT_MANUFACTURER_PIONEER",
    49   -> "FIT_MANUFACTURER_SPANTEC",
    50   -> "FIT_MANUFACTURER_METALOGICS",
    52   -> "FIT_MANUFACTURER_SEIKO_EPSON",
    53   -> "FIT_MANUFACTURER_SEIKO_EPSON_OEM",
    54   -> "FIT_MANUFACTURER_IFOR_POWELL",
    55   -> "FIT_MANUFACTURER_MAXWELL_GUIDER",
    56   -> "FIT_MANUFACTURER_STAR_TRAC",
    57   -> "FIT_MANUFACTURER_BREAKAWAY",
    58   -> "FIT_MANUFACTURER_ALATECH_TECHNOLOGY_LTD",
    59   -> "FIT_MANUFACTURER_MIO_TECHNOLOGY_EUROPE",
    60   -> "FIT_MANUFACTURER_ROTOR",
    61   -> "FIT_MANUFACTURER_GEONAUTE",
    62   -> "FIT_MANUFACTURER_ID_BIKE",
    63   -> "FIT_MANUFACTURER_SPECIALIZED",
    64   -> "FIT_MANUFACTURER_WTEK",
    65   -> "FIT_MANUFACTURER_PHYSICAL_ENTERPRISES",
    66   -> "FIT_MANUFACTURER_NORTH_POLE_ENGINEERING",
    67   -> "FIT_MANUFACTURER_BKOOL",
    68   -> "FIT_MANUFACTURER_CATEYE",
    69   -> "FIT_MANUFACTURER_STAGES_CYCLING",
    70   -> "FIT_MANUFACTURER_SIGMASPORT",
    71   -> "FIT_MANUFACTURER_TOMTOM",
    72   -> "FIT_MANUFACTURER_PERIPEDAL",
    73   -> "FIT_MANUFACTURER_WATTBIKE",
    76   -> "FIT_MANUFACTURER_MOXY",
    77   -> "FIT_MANUFACTURER_CICLOSPORT",
    78   -> "FIT_MANUFACTURER_POWERBAHN",
    79   -> "FIT_MANUFACTURER_ACORN_PROJECTS_APS",
    80   -> "FIT_MANUFACTURER_LIFEBEAM",
    81   -> "FIT_MANUFACTURER_BONTRAGER",
    82   -> "FIT_MANUFACTURER_WELLGO",
    83   -> "FIT_MANUFACTURER_SCOSCHE",
    84   -> "FIT_MANUFACTURER_MAGURA",
    85   -> "FIT_MANUFACTURER_WOODWAY",
    86   -> "FIT_MANUFACTURER_ELITE",
    87   -> "FIT_MANUFACTURER_NIELSEN_KELLERMAN",
    88   -> "FIT_MANUFACTURER_DK_CITY",
    89   -> "FIT_MANUFACTURER_TACX",
    90   -> "FIT_MANUFACTURER_DIRECTION_TECHNOLOGY",
    91   -> "FIT_MANUFACTURER_MAGTONIC",
    93   -> "FIT_MANUFACTURER_INSIDE_RIDE_TECHNOLOGIES",
    94   -> "FIT_MANUFACTURER_SOUND_OF_MOTION",
    95   -> "FIT_MANUFACTURER_STRYD",
    96   -> "FIT_MANUFACTURER_ICG",
    97   -> "FIT_MANUFACTURER_MIPULSE",
    98   -> "FIT_MANUFACTURER_BSX_ATHLETICS",
    99   -> "FIT_MANUFACTURER_LOOK",
    100  -> "FIT_MANUFACTURER_CAMPAGNOLO_SRL",
    101  -> "FIT_MANUFACTURER_BODY_BIKE_SMART",
    102  -> "FIT_MANUFACTURER_PRAXISWORKS",
    103  -> "FIT_MANUFACTURER_LIMITS_TECHNOLOGY",
    104  -> "FIT_MANUFACTURER_TOPACTION_TECHNOLOGY",
    105  -> "FIT_MANUFACTURER_COSINUSS",
    106  -> "FIT_MANUFACTURER_FITCARE",
    107  -> "FIT_MANUFACTURER_MAGENE",
    108  -> "FIT_MANUFACTURER_GIANT_MANUFACTURING_CO",
    109  -> "FIT_MANUFACTURER_TIGRASPORT",
    110  -> "FIT_MANUFACTURER_SALUTRON",
    111  -> "FIT_MANUFACTURER_TECHNOGYM",
    112  -> "FIT_MANUFACTURER_BRYTON_SENSORS",
    113  -> "FIT_MANUFACTURER_LATITUDE_LIMITED",
    114  -> "FIT_MANUFACTURER_SOARING_TECHNOLOGY",
    115  -> "FIT_MANUFACTURER_IGPSPORT",
    116  -> "FIT_MANUFACTURER_THINKRIDER",
    117  -> "FIT_MANUFACTURER_GOPHER_SPORT",
    118  -> "FIT_MANUFACTURER_WATERROWER",
    119  -> "FIT_MANUFACTURER_ORANGETHEORY",
    120  -> "FIT_MANUFACTURER_INPEAK",
    121  -> "FIT_MANUFACTURER_KINETIC",
    122  -> "FIT_MANUFACTURER_JOHNSON_HEALTH_TECH",
    123  -> "FIT_MANUFACTURER_POLAR_ELECTRO",
    124  -> "FIT_MANUFACTURER_SEESENSE",
    125  -> "FIT_MANUFACTURER_NCI_TECHNOLOGY",
    126  -> "FIT_MANUFACTURER_IQSQUARE",
    127  -> "FIT_MANUFACTURER_LEOMO",
    128  -> "FIT_MANUFACTURER_IFIT_COM",
    129  -> "FIT_MANUFACTURER_COROS_BYTE",
    130  -> "FIT_MANUFACTURER_VERSA_DESIGN",
    131  -> "FIT_MANUFACTURER_CHILEAF",
    132  -> "FIT_MANUFACTURER_CYCPLUS",
    133  -> "FIT_MANUFACTURER_GRAVAA_BYTE",
    134  -> "FIT_MANUFACTURER_SIGEYI",
    135  -> "FIT_MANUFACTURER_COOSPO",
    136  -> "FIT_MANUFACTURER_GEOID",
    137  -> "FIT_MANUFACTURER_BOSCH",
    138  -> "FIT_MANUFACTURER_KYTO",
    139  -> "FIT_MANUFACTURER_KINETIC_SPORTS",
    140  -> "FIT_MANUFACTURER_DECATHLON_BYTE",
    141  -> "FIT_MANUFACTURER_TQ_SYSTEMS",
    142  -> "FIT_MANUFACTURER_TAG_HEUER",
    143  -> "FIT_MANUFACTURER_KEISER_FITNESS",
    144  -> "FIT_MANUFACTURER_ZWIFT_BYTE",
    255  -> "FIT_MANUFACTURER_DEVELOPMENT",
    257  -> "FIT_MANUFACTURER_HEALTHANDLIFE",
    258  -> "FIT_MANUFACTURER_LEZYNE",
    259  -> "FIT_MANUFACTURER_SCRIBE_LABS",
    260  -> "FIT_MANUFACTURER_ZWIFT",
    261  -> "FIT_MANUFACTURER_WATTEAM",
    262  -> "FIT_MANUFACTURER_RECON",
    263  -> "FIT_MANUFACTURER_FAVERO_ELECTRONICS",
    264  -> "FIT_MANUFACTURER_DYNOVELO",
    265  -> "FIT_MANUFACTURER_STRAVA",
    266  -> "FIT_MANUFACTURER_PRECOR",
    267  -> "FIT_MANUFACTURER_BRYTON",
    268  -> "FIT_MANUFACTURER_SRAM",
    269  -> "FIT_MANUFACTURER_NAVMAN",
    270  -> "FIT_MANUFACTURER_COBI",
    271  -> "FIT_MANUFACTURER_SPIVI",
    272  -> "FIT_MANUFACTURER_MIO_MAGELLAN",
    273  -> "FIT_MANUFACTURER_EVESPORTS",
    274  -> "FIT_MANUFACTURER_SENSITIVUS_GAUGE",
    275  -> "FIT_MANUFACTURER_PODOON",
    276  -> "FIT_MANUFACTURER_LIFE_TIME_FITNESS",
    277  -> "FIT_MANUFACTURER_FALCO_E_MOTORS",
    278  -> "FIT_MANUFACTURER_MINOURA",
    279  -> "FIT_MANUFACTURER_CYCLIQ",
    280  -> "FIT_MANUFACTURER_LUXOTTICA",
    281  -> "FIT_MANUFACTURER_TRAINER_ROAD",
    282  -> "FIT_MANUFACTURER_THE_SUFFERFEST",
    283  -> "FIT_MANUFACTURER_FULLSPEEDAHEAD",
    284  -> "FIT_MANUFACTURER_VIRTUALTRAINING",
    285  -> "FIT_MANUFACTURER_FEEDBACKSPORTS",
    286  -> "FIT_MANUFACTURER_OMATA",
    287  -> "FIT_MANUFACTURER_VDO",
    288  -> "FIT_MANUFACTURER_MAGNETICDAYS",
    289  -> "FIT_MANUFACTURER_HAMMERHEAD",
    290  -> "FIT_MANUFACTURER_KINETIC_BY_KURT",
    291  -> "FIT_MANUFACTURER_SHAPELOG",
    292  -> "FIT_MANUFACTURER_DABUZIDUO",
    293  -> "FIT_MANUFACTURER_JETBLACK",
    294  -> "FIT_MANUFACTURER_COROS",
    295  -> "FIT_MANUFACTURER_VIRTUGO",
    296  -> "FIT_MANUFACTURER_VELOSENSE",
    297  -> "FIT_MANUFACTURER_CYCLIGENTINC",
    298  -> "FIT_MANUFACTURER_TRAILFORKS",
    299  -> "FIT_MANUFACTURER_MAHLE_EBIKEMOTION",
    300  -> "FIT_MANUFACTURER_NURVV",
    301  -> "FIT_MANUFACTURER_MICROPROGRAM",
    303  -> "FIT_MANUFACTURER_GREENTEG",
    304  -> "FIT_MANUFACTURER_YAMAHA_MOTORS",
    305  -> "FIT_MANUFACTURER_WHOOP",
    306  -> "FIT_MANUFACTURER_GRAVAA",
    307  -> "FIT_MANUFACTURER_ONELAP",
    308  -> "FIT_MANUFACTURER_MONARK_EXERCISE",
    309  -> "FIT_MANUFACTURER_FORM",
    310  -> "FIT_MANUFACTURER_DECATHLON",
    311  -> "FIT_MANUFACTURER_SYNCROS",
    312  -> "FIT_MANUFACTURER_HEATUP",
    313  -> "FIT_MANUFACTURER_CANNONDALE",
    314  -> "FIT_MANUFACTURER_TRUE_FITNESS",
    315  -> "FIT_MANUFACTURER_RGT_CYCLING",
    316  -> "FIT_MANUFACTURER_VASA",
    317  -> "FIT_MANUFACTURER_RACE_REPUBLIC",
    318  -> "FIT_MANUFACTURER_FAZUA",
    319  -> "FIT_MANUFACTURER_OREKA_TRAINING",
    320  -> "FIT_MANUFACTURER_ISEC",
    321  -> "FIT_MANUFACTURER_LULULEMON_STUDIO",
    5759 -> "FIT_MANUFACTURER_ACTIGRAPHCORP"
|>;

$fitManufacturers = toNiceCamelCase /@ $fitManufacturers0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitProduct*)
fitProduct // ClearAll;
fitProduct[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitProduct[ n_Integer ] := n;
fitProduct[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSoftwareVersion*)
fitSoftwareVersion // ClearAll;
fitSoftwareVersion[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitSoftwareVersion[ n_Integer ] := n;
fitSoftwareVersion[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitBatteryVoltage*)
fitBatteryVoltage // ClearAll;
fitBatteryVoltage[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitBatteryVoltage[ n_Integer ] := Quantity[ n / 256.0, "Volts" ];
fitBatteryVoltage[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitANTDeviceNumber*)
fitANTDeviceNumber // ClearAll;
fitANTDeviceNumber[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitANTDeviceNumber[ n_Integer ] := n;
fitANTDeviceNumber[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDeviceType*)
fitDeviceType // ClearAll;
fitDeviceType[ n_Integer ] := Lookup[ $fitDeviceTypes, n, Missing[ "NotAvailable" ] ];
fitDeviceType[ ___ ] := Missing[ "NotAvailable" ];

$fitDeviceTypes0 = <|
    1   -> "FIT_ANTPLUS_DEVICE_TYPE_ANTFS",
    11  -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_POWER",
    12  -> "FIT_ANTPLUS_DEVICE_TYPE_ENVIRONMENT_SENSOR_LEGACY",
    15  -> "FIT_ANTPLUS_DEVICE_TYPE_MULTI_SPORT_SPEED_DISTANCE",
    16  -> "FIT_ANTPLUS_DEVICE_TYPE_CONTROL",
    17  -> "FIT_ANTPLUS_DEVICE_TYPE_FITNESS_EQUIPMENT",
    18  -> "FIT_ANTPLUS_DEVICE_TYPE_BLOOD_PRESSURE",
    19  -> "FIT_ANTPLUS_DEVICE_TYPE_GEOCACHE_NODE",
    20  -> "FIT_ANTPLUS_DEVICE_TYPE_LIGHT_ELECTRIC_VEHICLE",
    25  -> "FIT_ANTPLUS_DEVICE_TYPE_ENV_SENSOR",
    26  -> "FIT_ANTPLUS_DEVICE_TYPE_RACQUET",
    27  -> "FIT_ANTPLUS_DEVICE_TYPE_CONTROL_HUB",
    31  -> "FIT_ANTPLUS_DEVICE_TYPE_MUSCLE_OXYGEN",
    34  -> "FIT_ANTPLUS_DEVICE_TYPE_SHIFTING",
    35  -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_LIGHT_MAIN",
    36  -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_LIGHT_SHARED",
    38  -> "FIT_ANTPLUS_DEVICE_TYPE_EXD",
    40  -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_RADAR",
    46  -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_AERO",
    119 -> "FIT_ANTPLUS_DEVICE_TYPE_WEIGHT_SCALE",
    120 -> "FIT_ANTPLUS_DEVICE_TYPE_HEART_RATE",
    121 -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_SPEED_CADENCE",
    122 -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_CADENCE",
    123 -> "FIT_ANTPLUS_DEVICE_TYPE_BIKE_SPEED",
    124 -> "FIT_ANTPLUS_DEVICE_TYPE_STRIDE_SPEED_DISTANCE"
|>;

$fitDeviceTypes = toNiceCamelCase /@ $fitDeviceTypes0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitHardwareVersion*)
fitHardwareVersion // ClearAll;
fitHardwareVersion[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitHardwareVersion[ n_Integer ] := n;
fitHardwareVersion[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitBatteryStatus*)
fitBatteryStatus // ClearAll;
fitBatteryStatus[ n_Integer ] := Lookup[ $fitBatteryStatus, n, Missing[ "NotAvailable" ] ];
fitBatteryStatus[ ___ ] := Missing[ "NotAvailable" ];

$fitBatteryStatus0 = <|
    1 -> "FIT_BATTERY_STATUS_NEW",
    2 -> "FIT_BATTERY_STATUS_GOOD",
    3 -> "FIT_BATTERY_STATUS_OK",
    4 -> "FIT_BATTERY_STATUS_LOW",
    5 -> "FIT_BATTERY_STATUS_CRITICAL",
    6 -> "FIT_BATTERY_STATUS_CHARGING",
    7 -> "FIT_BATTERY_STATUS_UNKNOWN"
|>;

$fitBatteryStatus = toNiceCamelCase /@ $fitBatteryStatus0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSensorPosition*)
fitSensorPosition // ClearAll;
fitSensorPosition[ n_Integer ] := Lookup[ $fitSensorPositions, n, Missing[ "NotAvailable" ] ];
fitSensorPosition[ ___ ] := Missing[ "NotAvailable" ];

$fitSensorPositions0 = <|
    0  -> "FIT_BODY_LOCATION_LEFT_LEG",
    1  -> "FIT_BODY_LOCATION_LEFT_CALF",
    2  -> "FIT_BODY_LOCATION_LEFT_SHIN",
    3  -> "FIT_BODY_LOCATION_LEFT_HAMSTRING",
    4  -> "FIT_BODY_LOCATION_LEFT_QUAD",
    5  -> "FIT_BODY_LOCATION_LEFT_GLUTE",
    6  -> "FIT_BODY_LOCATION_RIGHT_LEG",
    7  -> "FIT_BODY_LOCATION_RIGHT_CALF",
    8  -> "FIT_BODY_LOCATION_RIGHT_SHIN",
    9  -> "FIT_BODY_LOCATION_RIGHT_HAMSTRING",
    10 -> "FIT_BODY_LOCATION_RIGHT_QUAD",
    11 -> "FIT_BODY_LOCATION_RIGHT_GLUTE",
    12 -> "FIT_BODY_LOCATION_TORSO_BACK",
    13 -> "FIT_BODY_LOCATION_LEFT_LOWER_BACK",
    14 -> "FIT_BODY_LOCATION_LEFT_UPPER_BACK",
    15 -> "FIT_BODY_LOCATION_RIGHT_LOWER_BACK",
    16 -> "FIT_BODY_LOCATION_RIGHT_UPPER_BACK",
    17 -> "FIT_BODY_LOCATION_TORSO_FRONT",
    18 -> "FIT_BODY_LOCATION_LEFT_ABDOMEN",
    19 -> "FIT_BODY_LOCATION_LEFT_CHEST",
    20 -> "FIT_BODY_LOCATION_RIGHT_ABDOMEN",
    21 -> "FIT_BODY_LOCATION_RIGHT_CHEST",
    22 -> "FIT_BODY_LOCATION_LEFT_ARM",
    23 -> "FIT_BODY_LOCATION_LEFT_SHOULDER",
    24 -> "FIT_BODY_LOCATION_LEFT_BICEP",
    25 -> "FIT_BODY_LOCATION_LEFT_TRICEP",
    26 -> "FIT_BODY_LOCATION_LEFT_BRACHIORADIALIS",
    27 -> "FIT_BODY_LOCATION_LEFT_FOREARM_EXTENSORS",
    28 -> "FIT_BODY_LOCATION_RIGHT_ARM",
    29 -> "FIT_BODY_LOCATION_RIGHT_SHOULDER",
    30 -> "FIT_BODY_LOCATION_RIGHT_BICEP",
    31 -> "FIT_BODY_LOCATION_RIGHT_TRICEP",
    32 -> "FIT_BODY_LOCATION_RIGHT_BRACHIORADIALIS",
    33 -> "FIT_BODY_LOCATION_RIGHT_FOREARM_EXTENSORS",
    34 -> "FIT_BODY_LOCATION_NECK",
    35 -> "FIT_BODY_LOCATION_THROAT",
    36 -> "FIT_BODY_LOCATION_WAIST_MID_BACK",
    37 -> "FIT_BODY_LOCATION_WAIST_FRONT",
    38 -> "FIT_BODY_LOCATION_WAIST_LEFT",
    39 -> "FIT_BODY_LOCATION_WAIST_RIGHT"
|>;

$fitSensorPositions = toNiceCamelCase /@ $fitSensorPositions0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitANTTransmissionType*)
fitANTTransmissionType // ClearAll;
fitANTTransmissionType[ $invalidUINT8Z ] := Missing[ "NotAvailable" ];
fitANTTransmissionType[ n_Integer ] := n;
fitANTTransmissionType[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitANTNetwork*)
fitANTNetwork // ClearAll;
fitANTNetwork[ n_Integer ] := Lookup[ $fitANTNetworks, n, Missing[ "NotAvailable" ] ];
fitANTNetwork[ ___ ] := Missing[ "NotAvailable" ];

$fitANTNetworks0 = <|
    0 -> "FIT_ANT_NETWORK_PUBLIC",
    1 -> "FIT_ANT_NETWORK_ANTPLUS",
    2 -> "FIT_ANT_NETWORK_ANTFS",
    3 -> "FIT_ANT_NETWORK_PRIVATE"
|>;

$fitANTNetworks = toNiceCamelCase /@ $fitANTNetworks0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSourceType*)
fitSourceType // ClearAll;
fitSourceType[ n_Integer ] := Lookup[ $fitSourceTypes, n, Missing[ "NotAvailable" ] ];
fitSourceType[ ___ ] := Missing[ "NotAvailable" ];

$fitSourceTypes0 = <|
    0 -> "FIT_SOURCE_TYPE_ANT",
    1 -> "FIT_SOURCE_TYPE_ANTPLUS",
    2 -> "FIT_SOURCE_TYPE_BLUETOOTH",
    3 -> "FIT_SOURCE_TYPE_BLUETOOTH_LOW_ENERGY",
    4 -> "FIT_SOURCE_TYPE_WIFI",
    5 -> "FIT_SOURCE_TYPE_LOCAL"
|>;

$fitSourceTypes = toNiceCamelCase /@ $fitSourceTypes0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSport*)
fitSport // ClearAll;
fitSport[ n_Integer ] := Lookup[ $fitSports, n, Missing[ "NotAvailable" ] ];
fitSport[ ___ ] := Missing[ "NotAvailable" ];

$fitSports0 = <|
    0   -> "FIT_SPORT_GENERIC",
    1   -> "FIT_SPORT_RUNNING",
    2   -> "FIT_SPORT_CYCLING",
    3   -> "FIT_SPORT_TRANSITION",
    4   -> "FIT_SPORT_FITNESS_EQUIPMENT",
    5   -> "FIT_SPORT_SWIMMING",
    6   -> "FIT_SPORT_BASKETBALL",
    7   -> "FIT_SPORT_SOCCER",
    8   -> "FIT_SPORT_TENNIS",
    9   -> "FIT_SPORT_AMERICAN_FOOTBALL",
    10  -> "FIT_SPORT_TRAINING",
    11  -> "FIT_SPORT_WALKING",
    12  -> "FIT_SPORT_CROSS_COUNTRY_SKIING",
    13  -> "FIT_SPORT_ALPINE_SKIING",
    14  -> "FIT_SPORT_SNOWBOARDING",
    15  -> "FIT_SPORT_ROWING",
    16  -> "FIT_SPORT_MOUNTAINEERING",
    17  -> "FIT_SPORT_HIKING",
    18  -> "FIT_SPORT_MULTISPORT",
    19  -> "FIT_SPORT_PADDLING",
    20  -> "FIT_SPORT_FLYING",
    21  -> "FIT_SPORT_E_BIKING",
    22  -> "FIT_SPORT_MOTORCYCLING",
    23  -> "FIT_SPORT_BOATING",
    24  -> "FIT_SPORT_DRIVING",
    25  -> "FIT_SPORT_GOLF",
    26  -> "FIT_SPORT_HANG_GLIDING",
    27  -> "FIT_SPORT_HORSEBACK_RIDING",
    28  -> "FIT_SPORT_HUNTING",
    29  -> "FIT_SPORT_FISHING",
    30  -> "FIT_SPORT_INLINE_SKATING",
    31  -> "FIT_SPORT_ROCK_CLIMBING",
    32  -> "FIT_SPORT_SAILING",
    33  -> "FIT_SPORT_ICE_SKATING",
    34  -> "FIT_SPORT_SKY_DIVING",
    35  -> "FIT_SPORT_SNOWSHOEING",
    36  -> "FIT_SPORT_SNOWMOBILING",
    37  -> "FIT_SPORT_STAND_UP_PADDLEBOARDING",
    38  -> "FIT_SPORT_SURFING",
    39  -> "FIT_SPORT_WAKEBOARDING",
    40  -> "FIT_SPORT_WATER_SKIING",
    41  -> "FIT_SPORT_KAYAKING",
    42  -> "FIT_SPORT_RAFTING",
    43  -> "FIT_SPORT_WINDSURFING",
    44  -> "FIT_SPORT_KITESURFING",
    45  -> "FIT_SPORT_TACTICAL",
    46  -> "FIT_SPORT_JUMPMASTER",
    47  -> "FIT_SPORT_BOXING",
    48  -> "FIT_SPORT_FLOOR_CLIMBING",
    53  -> "FIT_SPORT_DIVING",
    254 -> "FIT_SPORT_ALL"
|>;

$fitSports = toNiceCamelCase /@ $fitSports0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSubSport*)
fitSubSport // ClearAll;
fitSubSport[ n_Integer ] := Lookup[ $fitSubSports, n, Missing[ "NotAvailable" ] ];
fitSubSport[ ___ ] := Missing[ "NotAvailable" ];

$fitSubSports0 = <|
    0   -> "FIT_SUB_SPORT_GENERIC",
    1   -> "FIT_SUB_SPORT_TREADMILL",
    2   -> "FIT_SUB_SPORT_STREET",
    3   -> "FIT_SUB_SPORT_TRAIL",
    4   -> "FIT_SUB_SPORT_TRACK",
    5   -> "FIT_SUB_SPORT_SPIN",
    6   -> "FIT_SUB_SPORT_INDOOR_CYCLING",
    7   -> "FIT_SUB_SPORT_ROAD",
    8   -> "FIT_SUB_SPORT_MOUNTAIN",
    9   -> "FIT_SUB_SPORT_DOWNHILL",
    10  -> "FIT_SUB_SPORT_RECUMBENT",
    11  -> "FIT_SUB_SPORT_CYCLOCROSS",
    12  -> "FIT_SUB_SPORT_HAND_CYCLING",
    13  -> "FIT_SUB_SPORT_TRACK_CYCLING",
    14  -> "FIT_SUB_SPORT_INDOOR_ROWING",
    15  -> "FIT_SUB_SPORT_ELLIPTICAL",
    16  -> "FIT_SUB_SPORT_STAIR_CLIMBING",
    17  -> "FIT_SUB_SPORT_LAP_SWIMMING",
    18  -> "FIT_SUB_SPORT_OPEN_WATER",
    19  -> "FIT_SUB_SPORT_FLEXIBILITY_TRAINING",
    20  -> "FIT_SUB_SPORT_STRENGTH_TRAINING",
    21  -> "FIT_SUB_SPORT_WARM_UP",
    22  -> "FIT_SUB_SPORT_MATCH",
    23  -> "FIT_SUB_SPORT_EXERCISE",
    24  -> "FIT_SUB_SPORT_CHALLENGE",
    25  -> "FIT_SUB_SPORT_INDOOR_SKIING",
    26  -> "FIT_SUB_SPORT_CARDIO_TRAINING",
    27  -> "FIT_SUB_SPORT_INDOOR_WALKING",
    28  -> "FIT_SUB_SPORT_E_BIKE_FITNESS",
    29  -> "FIT_SUB_SPORT_BMX",
    30  -> "FIT_SUB_SPORT_CASUAL_WALKING",
    31  -> "FIT_SUB_SPORT_SPEED_WALKING",
    32  -> "FIT_SUB_SPORT_BIKE_TO_RUN_TRANSITION",
    33  -> "FIT_SUB_SPORT_RUN_TO_BIKE_TRANSITION",
    34  -> "FIT_SUB_SPORT_SWIM_TO_BIKE_TRANSITION",
    35  -> "FIT_SUB_SPORT_ATV",
    36  -> "FIT_SUB_SPORT_MOTOCROSS",
    37  -> "FIT_SUB_SPORT_BACKCOUNTRY",
    38  -> "FIT_SUB_SPORT_RESORT",
    39  -> "FIT_SUB_SPORT_RC_DRONE",
    40  -> "FIT_SUB_SPORT_WINGSUIT",
    41  -> "FIT_SUB_SPORT_WHITEWATER",
    42  -> "FIT_SUB_SPORT_SKATE_SKIING",
    43  -> "FIT_SUB_SPORT_YOGA",
    44  -> "FIT_SUB_SPORT_PILATES",
    45  -> "FIT_SUB_SPORT_INDOOR_RUNNING",
    46  -> "FIT_SUB_SPORT_GRAVEL_CYCLING",
    47  -> "FIT_SUB_SPORT_E_BIKE_MOUNTAIN",
    48  -> "FIT_SUB_SPORT_COMMUTING",
    49  -> "FIT_SUB_SPORT_MIXED_SURFACE",
    50  -> "FIT_SUB_SPORT_NAVIGATE",
    51  -> "FIT_SUB_SPORT_TRACK_ME",
    52  -> "FIT_SUB_SPORT_MAP",
    53  -> "FIT_SUB_SPORT_SINGLE_GAS_DIVING",
    54  -> "FIT_SUB_SPORT_MULTI_GAS_DIVING",
    55  -> "FIT_SUB_SPORT_GAUGE_DIVING",
    56  -> "FIT_SUB_SPORT_APNEA_DIVING",
    57  -> "FIT_SUB_SPORT_APNEA_HUNTING",
    58  -> "FIT_SUB_SPORT_VIRTUAL_ACTIVITY",
    59  -> "FIT_SUB_SPORT_OBSTACLE",
    62  -> "FIT_SUB_SPORT_BREATHING",
    65  -> "FIT_SUB_SPORT_SAIL_RACE",
    67  -> "FIT_SUB_SPORT_ULTRA",
    68  -> "FIT_SUB_SPORT_INDOOR_CLIMBING",
    69  -> "FIT_SUB_SPORT_BOULDERING",
    254 -> "FIT_SUB_SPORT_ALL"
|>;

$fitSubSports = toNiceCamelCase /@ $fitSubSports0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitProductName*)
fitProductName // ClearAll;
fitProductName[ { 1, id_Integer }, { 0, ___ } ] := garminProductName @ id;
fitProductName[ _, { 0, ___ } ] := Missing[ "NotAvailable" ];
fitProductName[ _, bytes: { __Integer } ] := FromCharacterCode[ TakeWhile[ bytes, Positive ], "UTF-8" ];
fitProductName[ ___ ] := Missing[ "NotAvailable" ];

garminProductName[ id_ ] := Lookup[ $garminProductNames, id, Missing[ "NotAvailable" ] ];

$garminProductNames = <|
    1     -> "hrm1",
    2     -> "axh01",
    3     -> "axb01",
    4     -> "axb02",
    5     -> "hrm2ss",
    6     -> "dsi_alf02",
    7     -> "hrm3ss",
    8     -> "hrm_run_single_byte_product_id",
    9     -> "bsm",
    10    -> "bcm",
    11    -> "axs01",
    12    -> "hrm_tri_single_byte_product_id",
    13    -> "hrm4_run_single_byte_product_id",
    14    -> "fr225_single_byte_product_id",
    15    -> "gen3_bsm_single_byte_product_id",
    16    -> "gen3_bcm_single_byte_product_id",
    255   -> "OHR",
    473   -> "fr301_china",
    474   -> "fr301_japan",
    475   -> "fr301_korea",
    494   -> "fr301_taiwan",
    717   -> "fr405",
    782   -> "fr50",
    987   -> "fr405_japan",
    988   -> "fr60",
    1011  -> "dsi_alf01",
    1018  -> "fr310xt",
    1036  -> "edge500",
    1124  -> "fr110",
    1169  -> "edge800",
    1199  -> "edge500_taiwan",
    1213  -> "edge500_japan",
    1253  -> "chirp",
    1274  -> "fr110_japan",
    1325  -> "edge200",
    1328  -> "fr910xt",
    1333  -> "edge800_taiwan",
    1334  -> "edge800_japan",
    1341  -> "alf04",
    1345  -> "fr610",
    1360  -> "fr210_japan",
    1380  -> "vector_ss",
    1381  -> "vector_cp",
    1386  -> "edge800_china",
    1387  -> "edge500_china",
    1405  -> "approach_g10",
    1410  -> "fr610_japan",
    1422  -> "edge500_korea",
    1436  -> "fr70",
    1446  -> "fr310xt_4t",
    1461  -> "amx",
    1482  -> "fr10",
    1497  -> "edge800_korea",
    1499  -> "swim",
    1537  -> "fr910xt_china",
    1551  -> "fenix",
    1555  -> "edge200_taiwan",
    1561  -> "edge510",
    1567  -> "edge810",
    1570  -> "tempe",
    1600  -> "fr910xt_japan",
    1623  -> "fr620",
    1632  -> "fr220",
    1664  -> "fr910xt_korea",
    1688  -> "fr10_japan",
    1721  -> "edge810_japan",
    1735  -> "virb_elite",
    1736  -> "edge_touring",
    1742  -> "edge510_japan",
    1743  -> "hrm_tri",
    1752  -> "hrm_run",
    1765  -> "fr920xt",
    1821  -> "edge510_asia",
    1822  -> "edge810_china",
    1823  -> "edge810_taiwan",
    1836  -> "edge1000",
    1837  -> "vivo_fit",
    1853  -> "virb_remote",
    1885  -> "vivo_ki",
    1903  -> "fr15",
    1907  -> "vivo_active",
    1918  -> "edge510_korea",
    1928  -> "fr620_japan",
    1929  -> "fr620_china",
    1930  -> "fr220_japan",
    1931  -> "fr220_china",
    1936  -> "approach_s6",
    1956  -> "vivo_smart",
    1967  -> "fenix2",
    1988  -> "epix",
    2050  -> "fenix3",
    2052  -> "edge1000_taiwan",
    2053  -> "edge1000_japan",
    2061  -> "fr15_japan",
    2067  -> "edge520",
    2070  -> "edge1000_china",
    2072  -> "fr620_russia",
    2073  -> "fr220_russia",
    2079  -> "vector_s",
    2100  -> "edge1000_korea",
    2130  -> "fr920xt_taiwan",
    2131  -> "fr920xt_china",
    2132  -> "fr920xt_japan",
    2134  -> "virbx",
    2135  -> "vivo_smart_apac",
    2140  -> "etrex_touch",
    2147  -> "edge25",
    2148  -> "fr25",
    2150  -> "vivo_fit2",
    2153  -> "fr225",
    2156  -> "fr630",
    2157  -> "fr230",
    2158  -> "fr735xt",
    2160  -> "vivo_active_apac",
    2161  -> "vector_2",
    2162  -> "vector_2s",
    2172  -> "virbxe",
    2173  -> "fr620_taiwan",
    2174  -> "fr220_taiwan",
    2175  -> "truswing",
    2187  -> "d2airvenu",
    2188  -> "fenix3_china",
    2189  -> "fenix3_twn",
    2192  -> "varia_headlight",
    2193  -> "varia_taillight_old",
    2204  -> "edge_explore_1000",
    2219  -> "fr225_asia",
    2225  -> "varia_radar_taillight",
    2226  -> "varia_radar_display",
    2238  -> "edge20",
    2260  -> "edge520_asia",
    2261  -> "edge520_japan",
    2262  -> "d2_bravo",
    2266  -> "approach_s20",
    2271  -> "vivo_smart2",
    2274  -> "edge1000_thai",
    2276  -> "varia_remote",
    2288  -> "edge25_asia",
    2289  -> "edge25_jpn",
    2290  -> "edge20_asia",
    2292  -> "approach_x40",
    2293  -> "fenix3_japan",
    2294  -> "vivo_smart_emea",
    2310  -> "fr630_asia",
    2311  -> "fr630_jpn",
    2313  -> "fr230_jpn",
    2327  -> "hrm4_run",
    2332  -> "epix_japan",
    2337  -> "vivo_active_hr",
    2347  -> "vivo_smart_gps_hr",
    2348  -> "vivo_smart_hr",
    2361  -> "vivo_smart_hr_asia",
    2362  -> "vivo_smart_gps_hr_asia",
    2368  -> "vivo_move",
    2379  -> "varia_taillight",
    2396  -> "fr235_asia",
    2397  -> "fr235_japan",
    2398  -> "varia_vision",
    2406  -> "vivo_fit3",
    2407  -> "fenix3_korea",
    2408  -> "fenix3_sea",
    2413  -> "fenix3_hr",
    2417  -> "virb_ultra_30",
    2429  -> "index_smart_scale",
    2431  -> "fr235",
    2432  -> "fenix3_chronos",
    2441  -> "oregon7xx",
    2444  -> "rino7xx",
    2457  -> "epix_korea",
    2473  -> "fenix3_hr_chn",
    2474  -> "fenix3_hr_twn",
    2475  -> "fenix3_hr_jpn",
    2476  -> "fenix3_hr_sea",
    2477  -> "fenix3_hr_kor",
    2496  -> "nautix",
    2497  -> "vivo_active_hr_apac",
    2512  -> "oregon7xx_ww",
    2530  -> "edge_820",
    2531  -> "edge_explore_820",
    2533  -> "fr735xt_apac",
    2534  -> "fr735xt_japan",
    2544  -> "fenix5s",
    2547  -> "d2_bravo_titanium",
    2567  -> "varia_ut800",
    2593  -> "running_dynamics_pod",
    2599  -> "edge_820_china",
    2600  -> "edge_820_japan",
    2604  -> "fenix5x",
    2606  -> "vivo_fit_jr",
    2622  -> "vivo_smart3",
    2623  -> "vivo_sport",
    2628  -> "edge_820_taiwan",
    2629  -> "edge_820_korea",
    2630  -> "edge_820_sea",
    2650  -> "fr35_hebrew",
    2656  -> "approach_s60",
    2667  -> "fr35_apac",
    2668  -> "fr35_japan",
    2675  -> "fenix3_chronos_asia",
    2687  -> "virb_360",
    2691  -> "fr935",
    2697  -> "fenix5",
    2700  -> "vivoactive3",
    2733  -> "fr235_china_nfc",
    2769  -> "foretrex_601_701",
    2772  -> "vivo_move_hr",
    2713  -> "edge_1030",
    2727  -> "fr35_sea",
    2787  -> "vector_3",
    2796  -> "fenix5_asia",
    2797  -> "fenix5s_asia",
    2798  -> "fenix5x_asia",
    2806  -> "approach_z80",
    2814  -> "fr35_korea",
    2819  -> "d2charlie",
    2831  -> "vivo_smart3_apac",
    2832  -> "vivo_sport_apac",
    2833  -> "fr935_asia",
    2859  -> "descent",
    2878  -> "vivo_fit4",
    2886  -> "fr645",
    2888  -> "fr645m",
    2891  -> "fr30",
    2900  -> "fenix5s_plus",
    2909  -> "Edge_130",
    2924  -> "edge_1030_asia",
    2927  -> "vivosmart_4",
    2945  -> "vivo_move_hr_asia",
    2962  -> "approach_x10",
    2977  -> "fr30_asia",
    2988  -> "vivoactive3m_w",
    3003  -> "fr645_asia",
    3004  -> "fr645m_asia",
    3011  -> "edge_explore",
    3028  -> "gpsmap66",
    3049  -> "approach_s10",
    3066  -> "vivoactive3m_l",
    3085  -> "approach_g80",
    3092  -> "edge_130_asia",
    3095  -> "edge_1030_bontrager",
    3110  -> "fenix5_plus",
    3111  -> "fenix5x_plus",
    3112  -> "edge_520_plus",
    3113  -> "fr945",
    3121  -> "edge_530",
    3122  -> "edge_830",
    3126  -> "instinct_esports",
    3134  -> "fenix5s_plus_apac",
    3135  -> "fenix5x_plus_apac",
    3142  -> "edge_520_plus_apac",
    3144  -> "fr235l_asia",
    3145  -> "fr245_asia",
    3163  -> "vivo_active3m_apac",
    3192  -> "gen3_bsm",
    3193  -> "gen3_bcm",
    3218  -> "vivo_smart4_asia",
    3224  -> "vivoactive4_small",
    3225  -> "vivoactive4_large",
    3226  -> "venu",
    3246  -> "marq_driver",
    3247  -> "marq_aviator",
    3248  -> "marq_captain",
    3249  -> "marq_commander",
    3250  -> "marq_expedition",
    3251  -> "marq_athlete",
    3258  -> "descent_mk2",
    3284  -> "gpsmap66i",
    3287  -> "fenix6S_sport",
    3288  -> "fenix6S",
    3289  -> "fenix6_sport",
    3290  -> "fenix6",
    3291  -> "fenix6x",
    3299  -> "hrm_dual",
    3300  -> "hrm_pro",
    3308  -> "vivo_move3_premium",
    3314  -> "approach_s40",
    3321  -> "fr245m_asia",
    3349  -> "edge_530_apac",
    3350  -> "edge_830_apac",
    3378  -> "vivo_move3",
    3387  -> "vivo_active4_small_asia",
    3388  -> "vivo_active4_large_asia",
    3389  -> "vivo_active4_oled_asia",
    3405  -> "swim2",
    3420  -> "marq_driver_asia",
    3421  -> "marq_aviator_asia",
    3422  -> "vivo_move3_asia",
    3441  -> "fr945_asia",
    3446  -> "vivo_active3t_chn",
    3448  -> "marq_captain_asia",
    3449  -> "marq_commander_asia",
    3450  -> "marq_expedition_asia",
    3451  -> "marq_athlete_asia",
    3466  -> "instinct_solar",
    3469  -> "fr45_asia",
    3473  -> "vivoactive3_daimler",
    3498  -> "legacy_rey",
    3499  -> "legacy_darth_vader",
    3500  -> "legacy_captain_marvel",
    3501  -> "legacy_first_avenger",
    3512  -> "fenix6s_sport_asia",
    3513  -> "fenix6s_asia",
    3514  -> "fenix6_sport_asia",
    3515  -> "fenix6_asia",
    3516  -> "fenix6x_asia",
    3535  -> "legacy_captain_marvel_asia",
    3536  -> "legacy_first_avenger_asia",
    3537  -> "legacy_rey_asia",
    3538  -> "legacy_darth_vader_asia",
    3542  -> "descent_mk2s",
    3558  -> "edge_130_plus",
    3570  -> "edge_1030_plus",
    3578  -> "rally_200",
    3589  -> "fr745",
    3600  -> "venusq",
    3615  -> "lily",
    3624  -> "marq_adventurer",
    3638  -> "enduro",
    3639  -> "swim2_apac",
    3648  -> "marq_adventurer_asia",
    3652  -> "fr945_lte",
    3702  -> "descent_mk2_asia",
    3703  -> "venu2",
    3704  -> "venu2s",
    3737  -> "venu_daimler_asia",
    3739  -> "marq_golfer",
    3740  -> "venu_daimler",
    3794  -> "fr745_asia",
    3809  -> "lily_asia",
    3812  -> "edge_1030_plus_asia",
    3813  -> "edge_130_plus_asia",
    3823  -> "approach_s12",
    3872  -> "enduro_asia",
    3837  -> "venusq_asia",
    3843  -> "edge_1040",
    3850  -> "marq_golfer_asia",
    3851  -> "venu2_plus",
    3869  -> "fr55",
    3888  -> "instinct_2",
    3905  -> "fenix7s",
    3906  -> "fenix7",
    3907  -> "fenix7x",
    3908  -> "fenix7s_apac",
    3909  -> "fenix7_apac",
    3910  -> "fenix7x_apac",
    3930  -> "descent_mk2s_asia",
    3934  -> "approach_s42",
    3943  -> "epix_gen2",
    3944  -> "epix_gen2_apac",
    3949  -> "venu2s_asia",
    3950  -> "venu2_asia",
    3978  -> "fr945_lte_asia",
    3982  -> "vivo_move_sport",
    3986  -> "approach_S12_asia",
    3990  -> "fr255_music",
    3991  -> "fr255_small_music",
    3992  -> "fr255",
    3993  -> "fr255_small",
    4002  -> "approach_s42_asia",
    4005  -> "descent_g1",
    4017  -> "venu2_plus_asia",
    4024  -> "fr955",
    4033  -> "fr55_asia",
    4063  -> "vivosmart_5",
    4071  -> "instinct_2_asia",
    4115  -> "venusq2",
    4116  -> "venusq2music",
    4125  -> "d2_air_x10",
    4130  -> "hrm_pro_plus",
    4132  -> "descent_g1_asia",
    4135  -> "tactix7",
    4169  -> "edge_explore2",
    4265  -> "tacx_neo_smart",
    4266  -> "tacx_neo2_smart",
    4267  -> "tacx_neo2_t_smart",
    4268  -> "tacx_neo_smart_bike",
    4269  -> "tacx_satori_smart",
    4270  -> "tacx_flow_smart",
    4271  -> "tacx_vortex_smart",
    4272  -> "tacx_bushido_smart",
    4273  -> "tacx_genius_smart",
    4274  -> "tacx_flux_flux_s_smart",
    4275  -> "tacx_flux2_smart",
    4276  -> "tacx_magnum",
    4305  -> "edge_1040_asia",
    4341  -> "enduro2",
    10007 -> "sdm4",
    10014 -> "edge_remote",
    20533 -> "tacx_training_app_win",
    20534 -> "tacx_training_app_mac",
    20565 -> "tacx_training_app_mac_catalyst",
    20119 -> "training_center",
    30045 -> "tacx_training_app_android",
    30046 -> "tacx_training_app_ios",
    30047 -> "tacx_training_app_legacy",
    65531 -> "connectiq_simulator",
    65532 -> "android_antplus_plugin",
    65534 -> "connect"
|>;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitStrokeCount*)
fitStrokeCount // ClearAll;
fitStrokeCount[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitStrokeCount[ n_Integer ] := Quantity[ n, "Strokes" ];
fitStrokeCount[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitZoneCount*)
fitZoneCount // ClearAll;
(* TODO *)
fitZoneCount[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitAverageStrokeCount*)
fitAverageStrokeCount // ClearAll;
fitAverageStrokeCount[ $invalidUINT32 ] := Missing[ "NotAvailable" ];
fitAverageStrokeCount[ n_Integer ] := Quantity[ n / 10.0, "Strokes" ];
fitAverageStrokeCount[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitLaps*)
fitLaps // ClearAll;
fitLaps[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitLaps[ n_Integer ] := Quantity[ n, "Laps" ];
fitLaps[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitLengths*)
fitLengths // ClearAll;
fitLengths[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitLengths[ n_Integer ] := Quantity[ n, IndependentUnit[ "PoolLengths" ] ];
fitLengths[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTrainingStressScore*)
fitTrainingStressScore // ClearAll;
fitTrainingStressScore[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitTrainingStressScore[ n_Integer ] := n / 10.0;
fitTrainingStressScore[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitIntensityFactor*)
fitIntensityFactor // ClearAll;
fitIntensityFactor[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitIntensityFactor[ n_Integer ] := n / 1000.0;
fitIntensityFactor[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitMeters100*)
fitMeters100 // ClearAll;
fitMeters100[ $invalidUINT16 ] := Missing[ "NotAvailable" ];
fitMeters100[ n_Integer ] := fitMeters100[ n, $UnitSystem ];
fitMeters100[ n_Integer, "Metric" ] := Quantity[ n / 100.0, "Meters" ];
fitMeters100[ n_Integer, "Imperial" ] := Quantity[ 0.0328084 * n, "Feet" ];
fitMeters100[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTrainingEffect*)
fitTrainingEffect // ClearAll;
fitTrainingEffect[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitTrainingEffect[ n_Integer ] := n/10.0;
fitTrainingEffect[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitTrainingEffectDescription*)
fitTrainingEffectDescription // ClearAll;
fitTrainingEffectDescription[ $invalidUINT8 ] := Missing[ "NotAvailable" ];
fitTrainingEffectDescription[ n_Integer ] :=
    Which[ n >= 50, "Overreaching",
           n >= 40, "Highly Impacting",
           n >= 30, "Impacting",
           n >= 20, "Maintaining",
           n >= 10, "Some Benefit",
           True, "No Benefit"
    ];

fitTrainingEffectDescription[ ___ ] := Missing[ "NotAvailable" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSessionTrigger*)
fitSessionTrigger // ClearAll;
fitSessionTrigger[ n_Integer ] := Lookup[ $fitSessionTriggers, n, Missing[ "NotAvailable" ] ];
fitSessionTrigger[ ___ ] := Missing[ "NotAvailable" ];

$fitSessionTriggers0 = <|
    0 -> "FIT_SESSION_TRIGGER_ACTIVITY_END",
    1 -> "FIT_SESSION_TRIGGER_MANUAL",
    2 -> "FIT_SESSION_TRIGGER_AUTO_MULTI_SPORT",
    3 -> "FIT_SESSION_TRIGGER_FITNESS_EQUIPMENT"
|>;

$fitSessionTriggers = toNiceCamelCase /@ $fitSessionTriggers0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitSwimStroke*)
fitSwimStroke // ClearAll;
fitSwimStroke[ n_Integer ] := Lookup[ $fitSwimStrokes, n, Missing[ "NotAvailable" ] ];
fitSwimStroke[ ___ ] := Missing[ "NotAvailable" ];

$fitSwimStrokes0 = <|
    0 -> "FIT_SWIM_STROKE_FREESTYLE",
    1 -> "FIT_SWIM_STROKE_BACKSTROKE",
    2 -> "FIT_SWIM_STROKE_BREASTSTROKE",
    3 -> "FIT_SWIM_STROKE_BUTTERFLY",
    4 -> "FIT_SWIM_STROKE_DRILL",
    5 -> "FIT_SWIM_STROKE_MIXED",
    6 -> "FIT_SWIM_STROKE_IM"
|>;

$fitSwimStrokes = toNiceCamelCase /@ $fitSwimStrokes0;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDisplayMeasure*)
fitDisplayMeasure // ClearAll;
fitDisplayMeasure[ n_Integer ] := Lookup[ $fitDisplayMeasures, n, Missing[ "NotAvailable" ] ];
fitDisplayMeasure[ ___ ] := Missing[ "NotAvailable" ];

$fitDisplayMeasures0 = <|
    0 -> "FIT_DISPLAY_MEASURE_METRIC",
    1 -> "FIT_DISPLAY_MEASURE_STATUTE",
    2 -> "FIT_DISPLAY_MEASURE_NAUTICAL"
|>;

$fitDisplayMeasures = toNiceCamelCase /@ $fitDisplayMeasures0;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Graphics*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$powerZoneColors*)
$powerZoneColors = <|
    1 -> RGBColor[ "#53b3d1" ],
    2 -> RGBColor[ "#00cba9" ],
    3 -> RGBColor[ "#b4de67" ],
    4 -> RGBColor[ "#e3e562" ],
    5 -> RGBColor[ "#f3b846" ],
    6 -> RGBColor[ "#fa7021" ],
    7 -> RGBColor[ "#fb0052" ]
|>;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$hrZoneColors*)
$hrZoneColors = <|
    1 -> RGBColor[ "#53b3d1" ],
    2 -> RGBColor[ "#5ad488" ],
    3 -> RGBColor[ "#e3e562" ],
    4 -> RGBColor[ "#f69434" ],
    5 -> RGBColor[ "#fb0052" ]
|>;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*FIT Enums*)

removePrefix[ a_, p_ ] :=
    AssociationThread[ Keys @ a -> StringDelete[ Values @ a, p ] ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitGender*)
fitGender // ClearAll;
fitGender[ n_Integer ] := Lookup[ $fitGender, n, Missing[ "NotAvailable" ] ];
fitGender[ ___ ] := Missing[ "NotAvailable" ];

$fitGender0 = <|
    0 -> "FIT_GENDER_FEMALE",
    1 -> "FIT_GENDER_MALE"
|>;

$fitGender = toNiceCamelCase /@ removePrefix[ $fitGender0, "FIT_GENDER_" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitLanguage*)
fitLanguage // ClearAll;
fitLanguage[ n_Integer ] := Lookup[ $fitLanguage, n, Missing[ "NotAvailable" ] ];
fitLanguage[ ___ ] := Missing[ "NotAvailable" ];

$fitLanguage0 = <|
    0   -> "FIT_LANGUAGE_ENGLISH",
    1   -> "FIT_LANGUAGE_FRENCH",
    2   -> "FIT_LANGUAGE_ITALIAN",
    3   -> "FIT_LANGUAGE_GERMAN",
    4   -> "FIT_LANGUAGE_SPANISH",
    5   -> "FIT_LANGUAGE_CROATIAN",
    6   -> "FIT_LANGUAGE_CZECH",
    7   -> "FIT_LANGUAGE_DANISH",
    8   -> "FIT_LANGUAGE_DUTCH",
    9   -> "FIT_LANGUAGE_FINNISH",
    10  -> "FIT_LANGUAGE_GREEK",
    11  -> "FIT_LANGUAGE_HUNGARIAN",
    12  -> "FIT_LANGUAGE_NORWEGIAN",
    13  -> "FIT_LANGUAGE_POLISH",
    14  -> "FIT_LANGUAGE_PORTUGUESE",
    15  -> "FIT_LANGUAGE_SLOVAKIAN",
    16  -> "FIT_LANGUAGE_SLOVENIAN",
    17  -> "FIT_LANGUAGE_SWEDISH",
    18  -> "FIT_LANGUAGE_RUSSIAN",
    19  -> "FIT_LANGUAGE_TURKISH",
    20  -> "FIT_LANGUAGE_LATVIAN",
    21  -> "FIT_LANGUAGE_UKRAINIAN",
    22  -> "FIT_LANGUAGE_ARABIC",
    23  -> "FIT_LANGUAGE_FARSI",
    24  -> "FIT_LANGUAGE_BULGARIAN",
    25  -> "FIT_LANGUAGE_ROMANIAN",
    26  -> "FIT_LANGUAGE_CHINESE",
    27  -> "FIT_LANGUAGE_JAPANESE",
    28  -> "FIT_LANGUAGE_KOREAN",
    29  -> "FIT_LANGUAGE_TAIWANESE",
    30  -> "FIT_LANGUAGE_THAI",
    31  -> "FIT_LANGUAGE_HEBREW",
    32  -> "FIT_LANGUAGE_BRAZILIAN_PORTUGUESE",
    33  -> "FIT_LANGUAGE_INDONESIAN",
    34  -> "FIT_LANGUAGE_MALAYSIAN",
    35  -> "FIT_LANGUAGE_VIETNAMESE",
    36  -> "FIT_LANGUAGE_BURMESE",
    37  -> "FIT_LANGUAGE_MONGOLIAN",
    254 -> "FIT_LANGUAGE_CUSTOM"
|>;


toLanguage // beginDefinition;

toLanguage[ "Taiwanese"           ] := Entity[ "Language", "ChineseMinNan" ];
toLanguage[ "Farsi"               ] := Entity[ "Language", "Dari"          ];
toLanguage[ "Slovakian"           ] := Entity[ "Language", "Slovak"        ];
toLanguage[ "BrazilianPortuguese" ] := Entity[ "Language", "Portuguese"    ];
toLanguage[ "Malaysian"           ] := Entity[ "Language", "MalayStandard" ];

toLanguage[ name_String ] :=
    With[ { lang = LanguageData @ name },
        If[ MatchQ[ lang, _Entity ],
            lang,
            Missing[ "NotAvailable" ]
        ]
    ];

toLanguage // endDefinition;


$fitLanguage = DeleteMissing @ Map[
    toLanguage,
    toNiceCamelCase /@ removePrefix[ $fitLanguage0, "FIT_LANGUAGE_" ]
];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDisplayHeart*)
fitDisplayHeart // ClearAll;
fitDisplayHeart[ n_Integer ] := Lookup[ $fitDisplayHeart, n, Missing[ "NotAvailable" ] ];
fitDisplayHeart[ ___ ] := Missing[ "NotAvailable" ];

$fitDisplayHeart0 = <|
    0 -> "FIT_DISPLAY_HEART_BPM",
    1 -> "FIT_DISPLAY_HEART_MAX",
    2 -> "FIT_DISPLAY_HEART_RESERVE"
|>;

$fitDisplayHeart = toNiceCamelCase /@ removePrefix[ $fitDisplayHeart0, "FIT_DISPLAY_HEART_" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDisplayPower*)
fitDisplayPower // ClearAll;
fitDisplayPower[ n_Integer ] := Lookup[ $fitDisplayPower, n, Missing[ "NotAvailable" ] ];
fitDisplayPower[ ___ ] := Missing[ "NotAvailable" ];

$fitDisplayPower0 = <|
    0 -> "FIT_DISPLAY_POWER_WATTS",
    1 -> "FIT_DISPLAY_POWER_PERCENT_FTP"
|>;

$fitDisplayPower = toNiceCamelCase /@ removePrefix[ $fitDisplayPower0, "FIT_DISPLAY_POWER_" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitActivityClass*)
fitActivityClass // ClearAll;
fitActivityClass[ n_Integer ] := Lookup[ $fitActivityClass, n, Missing[ "NotAvailable" ] ];
fitActivityClass[ ___ ] := Missing[ "NotAvailable" ];

$fitActivityClass0 = <|
    100 -> "FIT_ACTIVITY_CLASS_LEVEL_MAX",
    128 -> "FIT_ACTIVITY_CLASS_ATHLETE"
|>;

$fitActivityClass = toNiceCamelCase /@ removePrefix[ $fitActivityClass0, "FIT_ACTIVITY_CLASS_" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fitDisplayPosition*)
fitDisplayPosition // ClearAll;
fitDisplayPosition[ n_Integer ] := Lookup[ $fitDisplayPosition, n, Missing[ "NotAvailable" ] ];
fitDisplayPosition[ ___ ] := Missing[ "NotAvailable" ];

$fitDisplayPosition0 = <|
    0  -> "FIT_DISPLAY_POSITION_DEGREE",
    1  -> "FIT_DISPLAY_POSITION_DEGREE_MINUTE",
    2  -> "FIT_DISPLAY_POSITION_DEGREE_MINUTE_SECOND",
    3  -> "FIT_DISPLAY_POSITION_AUSTRIAN_GRID",
    4  -> "FIT_DISPLAY_POSITION_BRITISH_GRID",
    5  -> "FIT_DISPLAY_POSITION_DUTCH_GRID",
    6  -> "FIT_DISPLAY_POSITION_HUNGARIAN_GRID",
    7  -> "FIT_DISPLAY_POSITION_FINNISH_GRID",
    8  -> "FIT_DISPLAY_POSITION_GERMAN_GRID",
    9  -> "FIT_DISPLAY_POSITION_ICELANDIC_GRID",
    10 -> "FIT_DISPLAY_POSITION_INDONESIAN_EQUATORIAL",
    11 -> "FIT_DISPLAY_POSITION_INDONESIAN_IRIAN",
    12 -> "FIT_DISPLAY_POSITION_INDONESIAN_SOUTHERN",
    13 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_0",
    14 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IA",
    15 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IB",
    16 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IIA",
    17 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IIB",
    18 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IIIA",
    19 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IIIB",
    20 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IVA",
    21 -> "FIT_DISPLAY_POSITION_INDIA_ZONE_IVB",
    22 -> "FIT_DISPLAY_POSITION_IRISH_TRANSVERSE",
    23 -> "FIT_DISPLAY_POSITION_IRISH_GRID",
    24 -> "FIT_DISPLAY_POSITION_LORAN",
    25 -> "FIT_DISPLAY_POSITION_MAIDENHEAD_GRID",
    26 -> "FIT_DISPLAY_POSITION_MGRS_GRID",
    27 -> "FIT_DISPLAY_POSITION_NEW_ZEALAND_GRID",
    28 -> "FIT_DISPLAY_POSITION_NEW_ZEALAND_TRANSVERSE",
    29 -> "FIT_DISPLAY_POSITION_QATAR_GRID",
    30 -> "FIT_DISPLAY_POSITION_MODIFIED_SWEDISH_GRID",
    31 -> "FIT_DISPLAY_POSITION_SWEDISH_GRID",
    32 -> "FIT_DISPLAY_POSITION_SOUTH_AFRICAN_GRID",
    33 -> "FIT_DISPLAY_POSITION_SWISS_GRID",
    34 -> "FIT_DISPLAY_POSITION_TAIWAN_GRID",
    35 -> "FIT_DISPLAY_POSITION_UNITED_STATES_GRID",
    36 -> "FIT_DISPLAY_POSITION_UTM_UPS_GRID",
    37 -> "FIT_DISPLAY_POSITION_WEST_MALAYAN",
    38 -> "FIT_DISPLAY_POSITION_BORNEO_RSO",
    39 -> "FIT_DISPLAY_POSITION_ESTONIAN_GRID",
    40 -> "FIT_DISPLAY_POSITION_LATVIAN_GRID",
    41 -> "FIT_DISPLAY_POSITION_SWEDISH_REF_99_GRID"
|>;

$fitDisplayPosition = toNiceCamelCase /@ removePrefix[ $fitDisplayPosition0, "FIT_DISPLAY_POSITION_" ];

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
(* ::Section:: *)
(*Resources*)
$libData := $libData =
    $libData0 /. e_EvaluateInPlace :> RuleCondition @ First @ e;

(* !Excluded
Libraries built using
[GitHub Actions](https://github.com/rhennigan/ResourceFunctions/actions/runs/3500782621).
Source code can be found
[here.](https://github.com/rhennigan/ResourceFunctions/tree/52ac1d6f1f59c2f7ed8400691540e88528a31b07/Definitions/FITImport/Source)
*)
$libData0 = <|
    "Linux-x86-64"   -> EvaluateInPlace @ ReadByteArray @ FileNameJoin @ { DirectoryName @ $InputFileName, "LibraryResources", "Linux-x86-64"  , "FitnessData.so"    },
    "MacOSX-x86-64"  -> EvaluateInPlace @ ReadByteArray @ FileNameJoin @ { DirectoryName @ $InputFileName, "LibraryResources", "MacOSX-x86-64" , "FitnessData.dylib" },
    "Windows-x86-64" -> EvaluateInPlace @ ReadByteArray @ FileNameJoin @ { DirectoryName @ $InputFileName, "LibraryResources", "Windows-x86-64", "FitnessData.dll"   }
|>;