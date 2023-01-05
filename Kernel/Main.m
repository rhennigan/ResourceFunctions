(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package header*)
Package[ "RH`ResourceFunctions`" ]

PackageExport[ "$BuildableNames"            ]
PackageExport[ "$ResourceFunctionDirectory" ]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$BuildableNames*)
$BuildableNames :=
    Enclose @ Module[ { dir, dirs },
        dir = ConfirmBy[ $ResourceFunctionDirectory, DirectoryQ ];
        dirs = Select[ FileNames[ All, dir ], DirectoryQ ];
        Select[ FileBaseName /@ dirs, validNameQ ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validNameQ*)
validNameQ[ "TEMPLATE"  ] := False;
validNameQ[ name_String ] := Internal`SymbolNameQ @ name;
validNameQ[ ___         ] := False;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$ResourceFunctionDirectory*)
$ResourceFunctionDirectory :=
    Enclose @ Module[ { paclet },

        paclet = ConfirmBy[ PacletObject[ "RH_ResourceFunctions" ],
                            PacletObjectQ
                 ];

        $ResourceFunctionDirectory =
            ConfirmBy[
                paclet[ "AssetLocation", "Definitions" ],
                DirectoryQ
            ]
    ];

