#include "WolframLibrary.h"
#include "stdio.h"
#include "string.h"
#include "fit_convert.h"

#define MESSAGE_TENSOR_ROW_WIDTH 91

#define FIT_IMPORT_ERROR_CONVERSION            8
#define FIT_IMPORT_ERROR_UNEXPECTED_EOF        9
#define FIT_IMPORT_ERROR_NOT_FIT_FILE         10
#define FIT_IMPORT_ERROR_UNSUPPORTED_PROTOCOL 11
#define FIT_IMPORT_ERROR_INTERNAL             12
#define FIT_IMPORT_ERROR_OPEN_FILE            13

static int count_fit_messages(        char* input, mint* err );
static int count_usable_fit_messages( char* input, mint* err );

static void write_file_id(     WolframLibraryData libData, MTensor data, int idx, const FIT_FILE_ID_MESG     *mesg);
static void write_record(      WolframLibraryData libData, MTensor data, int idx, const FIT_RECORD_MESG      *mesg);
static void write_event(       WolframLibraryData libData, MTensor data, int idx, const FIT_EVENT_MESG       *mesg);
static void write_device_info( WolframLibraryData libData, MTensor data, int idx, const FIT_DEVICE_INFO_MESG *mesg);
static void write_session(     WolframLibraryData libData, MTensor data, int idx, const FIT_SESSION_MESG     *mesg);
