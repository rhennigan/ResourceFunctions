(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/FITImport/Tests.wlt:4,1-9,2"
]

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    FITImport[ "ExampleData/BikeRide.fit" ],
    _Dataset,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-1@@Definitions/FITImport/Tests.wlt:18,1-23,2"
]

VerificationTest[
    session = FITImport[ "ExampleData/BikeRide.fit", "Session" ],
    _Dataset,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-2@@Definitions/FITImport/Tests.wlt:25,1-30,2"
]

VerificationTest[
    session1 = session[ 1 ],
    _Dataset,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-3@@Definitions/FITImport/Tests.wlt:32,1-37,2"
]

VerificationTest[
    Normal @ session1,
    KeyValuePattern @ {
        "AverageCadence"                          -> _Quantity,
        "AverageHeartRate"                        -> _Quantity,
        "AverageLeftPowerPhaseEnd"                -> _Quantity,
        "AverageLeftPowerPhasePeakEnd"            -> _Quantity,
        "AverageLeftPowerPhasePeakStart"          -> _Quantity,
        "AverageLeftPowerPhaseStart"              -> _Quantity,
        "AveragePower"                            -> _Quantity,
        "AverageRightPowerPhaseEnd"               -> _Quantity,
        "AverageRightPowerPhasePeakEnd"           -> _Quantity,
        "AverageRightPowerPhasePeakStart"         -> _Quantity,
        "AverageRightPowerPhaseStart"             -> _Quantity,
        "AverageSpeed"                            -> _Quantity,
        "AverageTemperature"                      -> _Quantity,
        "AverageVAM"                              -> _Quantity,
        "Event"                                   -> _String,
        "EventType"                               -> _String,
        "FirstLapIndex"                           -> _Integer,
        "GeoBoundingBox"                          -> { _GeoPosition, _GeoPosition },
        "IntensityFactor"                         -> _Real,
        "LeftRightBalance"                        -> { Quantity[ _, "Percent" ], Quantity[ _, "Percent" ] },
        "MaxCadence"                              -> _Quantity,
        "MaxHeartRate"                            -> _Quantity,
        "MaxPower"                                -> _Quantity,
        "MaxSpeed"                                -> _Quantity,
        "MaxTemperature"                          -> _Quantity,
        "NormalizedPower"                         -> _Quantity,
        "NumberOfLaps"                            -> _Quantity,
        "Sport"                                   -> _String,
        "StartPosition"                           -> _GeoPosition,
        "StartTime"                               -> _DateObject,
        "SubSport"                                -> _String,
        "ThresholdPower"                          -> _Quantity,
        "Timestamp"                               -> _DateObject,
        "TotalAerobicTrainingEffect"              -> _Real,
        "TotalAerobicTrainingEffectDescription"   -> _String,
        "TotalAnaerobicTrainingEffect"            -> _Real,
        "TotalAnaerobicTrainingEffectDescription" -> _String,
        "TotalAscent"                             -> _Quantity,
        "TotalCalories"                           -> _Quantity,
        "TotalCycles"                             -> _Quantity,
        "TotalDescent"                            -> _Quantity,
        "TotalDistance"                           -> _Quantity,
        "TotalElapsedTime"                        -> _Quantity,
        "TotalTimerTime"                          -> _Quantity,
        "TotalWork"                               -> _Quantity,
        "TrainingStressScore"                     -> _Real,
        "Trigger"                                 -> _String
    },
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-4@@Definitions/FITImport/Tests.wlt:39,1-92,2"
]

VerificationTest[
    pos = FITImport[ "ExampleData/BikeRide.fit", "GeoPosition" ],
    _TemporalData,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-5@@Definitions/FITImport/Tests.wlt:94,1-99,2"
]

VerificationTest[
    Values @ pos,
    { __GeoPosition },
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-6@@Definitions/FITImport/Tests.wlt:101,1-106,2"
]

VerificationTest[
    DateListPlot @ FITImport[ "ExampleData/BikeHillClimb.fit", "Altitude" ],
    _Graphics,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-7@@Definitions/FITImport/Tests.wlt:108,1-113,2"
]

VerificationTest[
    FITImport[ "ExampleData/IndoorIntervals.fit", "PowerZonePlot" ],
    _Legended,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-8@@Definitions/FITImport/Tests.wlt:115,1-120,2"
]

VerificationTest[
    FITImport[ "ExampleData/BikeLaps.fit", "AveragePowerPhasePlot" ],
    _Graphics,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-9@@Definitions/FITImport/Tests.wlt:122,1-127,2"
]

VerificationTest[
    FITImport[ "ExampleData/BikeLaps.fit", "CriticalPowerCurvePlot" ],
    _Graphics,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-10@@Definitions/FITImport/Tests.wlt:129,1-134,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)
VerificationTest[
    devices = FITImport[ "ExampleData/BikeHillClimb.fit", "DeviceInformation" ],
    _Dataset,
    SameTest -> MatchQ,
    TestID   -> "Scope-1@@Definitions/FITImport/Tests.wlt:139,1-144,2"
]

VerificationTest[
    FirstCase[ Normal @ devices, KeyValuePattern @ { "ProductName" -> "Edge830" } ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "Scope-2@@Definitions/FITImport/Tests.wlt:146,1-151,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Options*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*FunctionalThresholdPower*)
VerificationTest[
    oldFTP = PersistentSymbol[ "FITImport/FunctionalThresholdPower" ];
    If[ ! MissingQ @ oldFTP,
        Unset @ PersistentSymbol[ "FITImport/FunctionalThresholdPower" ]
    ],
    Null,
    SameTest -> MatchQ,
    TestID -> "Options/FunctionalThresholdPower-1@@Definitions/FITImport/Tests.wlt:160,1-168,2"
]

VerificationTest[
    FITImport[ "ExampleData/ZwiftRide.fit", "PowerZone" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "Options-FunctionalThresholdPower-2@@Definitions/FITImport/Tests.wlt:170,1-175,2"
]

VerificationTest[
    FITImport[
        "ExampleData/ZwiftRide.fit",
        "PowerZone",
        "FunctionalThresholdPower" -> Quantity[ 250, "Watts" ]
    ],
    _TemporalData,
    SameTest -> MatchQ,
    TestID   -> "Options-FunctionalThresholdPower-3@@Definitions/FITImport/Tests.wlt:177,1-186,2"
]

VerificationTest[
    FITImport[ "ExampleData/ZwiftRide.fit", "PowerZonePlot" ],
    _Graphics,
    { FITImport::NoFTPValue },
    SameTest -> MatchQ,
    TestID   -> "Options-FunctionalThresholdPower-4@@Definitions/FITImport/Tests.wlt:188,1-194,2"
]

VerificationTest[
    PersistentSymbol[ "FITImport/FunctionalThresholdPower" ] = Quantity[ 250, "Watts" ],
    _Quantity,
    SameTest -> MatchQ,
    TestID   -> "Options-FunctionalThresholdPower-5@@Definitions/FITImport/Tests.wlt:196,1-201,2"
]

VerificationTest[
    FITImport[ "ExampleData/ZwiftRide.fit", "PowerZone" ],
    _TemporalData,
    SameTest -> MatchQ,
    TestID   -> "Options-FunctionalThresholdPower-6@@Definitions/FITImport/Tests.wlt:203,1-208,2"
]

VerificationTest[
    If[ ! MissingQ @ oldFTP,
        PersistentSymbol[ "FITImport/FunctionalThresholdPower" ] = oldFTP;
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "Options-FunctionalThresholdPower-7@@Definitions/FITImport/Tests.wlt:210,1-217,2"
]

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*MaxHeartRate*)
VerificationTest[
    oldMaxHR = PersistentSymbol[ "FITImport/MaxHeartRate" ];
    If[ ! MissingQ @ oldMaxHR,
        Unset @ PersistentSymbol[ "FITImport/MaxHeartRate" ]
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "Options-MaxHeartRate-1@@Definitions/FITImport/Tests.wlt:222,1-230,2"
]

VerificationTest[
    FITImport[ "ExampleData/ZwiftRide.fit", "HeartRateZone" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "Options-MaxHeartRate-2@@Definitions/FITImport/Tests.wlt:232,1-237,2"
]

VerificationTest[
    FITImport[
        "ExampleData/ZwiftRide.fit",
        "HeartRateZone",
        "MaxHeartRate" -> 190
    ],
    _TemporalData,
    SameTest -> MatchQ,
    TestID   -> "Options-MaxHeartRate-3@@Definitions/FITImport/Tests.wlt:239,1-248,2"
]

VerificationTest[
    PersistentSymbol[ "FITImport/MaxHeartRate" ] = Quantity[ 190, "BPM" ],
    _Quantity,
    SameTest -> MatchQ,
    TestID   -> "Options-MaxHeartRate-4@@Definitions/FITImport/Tests.wlt:250,1-255,2"
]

VerificationTest[
    FITImport[ "ExampleData/ZwiftRide.fit", "HeartRateZone" ],
    _TemporalData,
    SameTest -> MatchQ,
    TestID   -> "Options-MaxHeartRate-5@@Definitions/FITImport/Tests.wlt:257,1-262,2"
]

VerificationTest[
    If[ ! MissingQ @ oldMaxHR,
        PersistentSymbol[ "FITImport/MaxHeartRate" ] = oldMaxHR;
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "Options-MaxHeartRate-6@@Definitions/FITImport/Tests.wlt:264,1-271,2"
]

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*UnitSystem*)
VerificationTest[
    FITImport[ "ExampleData/BikeHillClimb.fit", "Altitude", UnitSystem -> "Imperial" ][ "LastValue" ],
    Quantity[ _, "Feet" ],
    SameTest -> MatchQ,
    TestID   -> "Options-UnitSystem-1@@Definitions/FITImport/Tests.wlt:276,1-281,2"
]

VerificationTest[
    FITImport[ "ExampleData/BikeHillClimb.fit", "Altitude", UnitSystem -> "Metric" ][ "LastValue" ],
    Quantity[ _, "Meters" ],
    SameTest -> MatchQ,
    TestID   -> "Options-UnitSystem-2@@Definitions/FITImport/Tests.wlt:283,1-288,2"
]

VerificationTest[
    Block[ { $UnitSystem = "Imperial" },
        FITImport[ "ExampleData/BikeHillClimb.fit", "Altitude" ][ "LastValue" ]
    ],
    Quantity[ _, "Feet" ],
    SameTest -> MatchQ,
    TestID   -> "Options-UnitSystem-3@@Definitions/FITImport/Tests.wlt:290,1-297,2"
]

VerificationTest[
    Block[ { $UnitSystem = "Metric" },
        FITImport[ "ExampleData/BikeHillClimb.fit", "Altitude" ][ "LastValue" ]
    ],
    Quantity[ _, "Meters" ],
    SameTest -> MatchQ,
    TestID   -> "Options-UnitSystem-4@@Definitions/FITImport/Tests.wlt:299,1-306,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Errors*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Applications*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Properties and Relations*)
VerificationTest[
    FITImport[ "ExampleData/BikeRide.fit", "MessageCounts" ],
    KeyValuePattern[ "Record" -> 11376 ],
    SameTest -> MatchQ,
    TestID   -> "PropertiesAndRelations-1@@Definitions/FITImport/Tests.wlt:320,1-325,2"
]

VerificationTest[
    Total @ Select[
        FITImport[ "ExampleData/BikeRide.fit", "MessageInformation" ],
        #Supported &
    ][ All, "Count" ],
    Length @ FITImport[ "ExampleData/BikeRide.fit", "RawData" ],
    SameTest -> MatchQ,
    TestID   -> "PropertiesAndRelations-2@@Definitions/FITImport/Tests.wlt:327,1-335,2"
]

VerificationTest[
    FITImport[ "ExampleData/Walk.fit", "Session" ][ 1 ][ "AverageCadence" ],
    Quantity[ _, "Steps"/"Minutes" ],
    SameTest -> MatchQ,
    TestID   -> "PropertiesAndRelations-3@@Definitions/FITImport/Tests.wlt:337,1-342,2"
]

VerificationTest[
    FITImport[ "ExampleData/BikeRide.fit", "Session" ][ 1 ][ "AverageCadence" ],
    Quantity[ _, "Revolutions"/"Minutes" ],
    SameTest -> MatchQ,
    TestID   -> "PropertiesAndRelations-4@@Definitions/FITImport/Tests.wlt:344,1-349,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Possible Issues*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Neat Examples*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Example Data*)
VerificationTest[
    $exampleDir = DirectoryName @ FindFile[ "ExampleData/BikeRide.fit" ],
    _? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "ExampleData-1@@Definitions/FITImport/Tests.wlt:363,1-368,2"
]

VerificationTest[
    StringStartsQ[ $exampleDir, $UserBaseDirectory ],
    True,
    SameTest -> MatchQ,
    TestID   -> "ExampleData-2@@Definitions/FITImport/Tests.wlt:370,1-375,2"
]

VerificationTest[
    $exampleFiles = FileNames[ "*.fit", $exampleDir ],
    { Repeated[ _String, { 5, Infinity } ] },
    SameTest -> MatchQ,
    TestID   -> "ExampleData-3@@Definitions/FITImport/Tests.wlt:377,1-382,2"
]

VerificationTest[
    MemberQ[ $Path, AbsoluteFileName @ DirectoryName @ $exampleDir ],
    True,
    SameTest -> MatchQ,
    TestID   -> "ExampleData-4@@Definitions/FITImport/Tests.wlt:384,1-389,2"
]

VerificationTest[
    (FITImport @ FileNameTake[ #, -2 ] &) /@ $exampleFiles,
    { __Dataset },
    SameTest -> MatchQ,
    TestID   -> "ExampleData-5@@Definitions/FITImport/Tests.wlt:391,1-396,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID   -> "Cleanup@@Definitions/FITImport/Tests.wlt:406,1-411,2"
]
