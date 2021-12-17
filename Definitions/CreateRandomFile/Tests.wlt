(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Single argument*)

VerificationTest[
    file = CreateRandomFile[ 50 ],
    _File? FileExistsQ,
    SameTest -> MatchQ
]

VerificationTest[
    DeleteFile @ file,
    Null
]

VerificationTest[
    file = CreateRandomFile[ Automatic, 50 ],
    _File? FileExistsQ,
    SameTest -> MatchQ
]

VerificationTest[
    DeleteFile @ file,
    Null
]


(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Two arguments*)
VerificationTest[
    file = FileNameJoin @ { $TemporaryDirectory, CreateUUID[ ] },
    _String? StringQ,
    SameTest -> MatchQ
]

VerificationTest[
    FileByteCount @ CreateRandomFile[ file, 50 ],
    50
]

VerificationTest[
    DeleteFile @ file,
    Null
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Scope*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*File*)
VerificationTest[
    file = File @ FileNameJoin @ { $TemporaryDirectory, CreateUUID[ ] },
    File[ _String? StringQ ],
    SameTest -> MatchQ
]

VerificationTest[
    CreateRandomFile[ file, 50 ],
    f_File /; FileByteCount[ f ] === 50,
    SameTest -> MatchQ
]

VerificationTest[ DeleteFile @ file, Null ]

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*CloudObject*)
VerificationTest[
    co = CloudObject[ ],
    HoldPattern @ CloudObject[ _String? StringQ ],
    SameTest -> MatchQ
]

VerificationTest[
    CreateRandomFile[ co, 50 ],
    obj_CloudObject /; FileByteCount[ obj ] === 50,
    SameTest -> MatchQ
]

VerificationTest[ DeleteObject @ co, Null ]

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*LocalObject*)
VerificationTest[
    lo = LocalObject[ ],
    HoldPattern @ LocalObject[ _String? StringQ ],
    SameTest -> MatchQ
]

VerificationTest[
    CreateRandomFile[ lo, 50 ],
    obj_LocalObject /; FileByteCount[ obj ] === 50,
    SameTest -> MatchQ
]

VerificationTest[ DeleteObject @ lo, Null ]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Options*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*CreateIntermediateDirectories*)

VerificationTest[
    DirectoryQ[ dir = CreateDirectory[ ] ]
]

VerificationTest[
    FileByteCount @ CreateRandomFile[
        FileNameJoin @ { dir, "path", "to", "file" },
        50,
        CreateIntermediateDirectories -> True
    ],
    50
]

VerificationTest[
    CreateRandomFile[
        FileNameJoin @ { dir, "other", "path", "to", "file" },
        50,
        CreateIntermediateDirectories -> False
    ],
    Failure[ "CreateRandomFile::fdnfnd", _Association ],
    { CreateRandomFile::fdnfnd },
    SameTest -> MatchQ
]

VerificationTest[
    DeleteDirectory[ dir, DeleteContents -> True ],
    Null
]

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*OverwriteTarget*)

VerificationTest[
    FileExistsQ[ file = CreateFile[ ] ]
]

VerificationTest[
    CreateRandomFile[ file, 50, OverwriteTarget -> False ],
    Failure[ "CreateRandomFile::filex", _Association ],
    { CreateRandomFile::filex },
    SameTest -> MatchQ
]

VerificationTest[
    CreateRandomFile[ file, 50, OverwriteTarget -> True ],
    _File? FileExistsQ,
    SameTest -> MatchQ
]

VerificationTest[
    DeleteFile @ file,
    Null
]


(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    CreateRandomFile[ ],
    Failure[ "CreateRandomFile::argt", _Association ],
    { CreateRandomFile::argt },
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]
