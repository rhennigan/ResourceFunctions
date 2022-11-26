#include "WolframLibrary.h"
#include "stdio.h"
#include "string.h"
#include "fit_convert.h"

#define MESSAGE_TENSOR_ROW_WIDTH 102

#define FIT_IMPORT_ERROR_CONVERSION            8
#define FIT_IMPORT_ERROR_UNEXPECTED_EOF        9
#define FIT_IMPORT_ERROR_NOT_FIT_FILE         10
#define FIT_IMPORT_ERROR_UNSUPPORTED_PROTOCOL 11
#define FIT_IMPORT_ERROR_INTERNAL             12
#define FIT_IMPORT_ERROR_OPEN_FILE            13

#define DONE                             1685024357
#define FIT_MESG_NUM_MESSAGE_INFORMATION 1768842863

#define WLTimestamp(t) ((t) + 2840036400)

#define SetInteger(libData, data, pos, x) \
    pos[1]++; \
    libData->MTensor_setInteger(data, pos, x)

#define SetIntegerSequence(libData, data, pos, x, n) \
    for(int i=0; i<n; i++) { \
        pos[1]++; \
        libData->MTensor_setInteger(data, pos, x[i]); \
    }

static int count_fit_messages(        char* input, mint* err );
static int count_usable_fit_messages( char* input, mint* err );

static void write_file_id(          WolframLibraryData libData, MTensor data, int idx, const FIT_FILE_ID_MESG           *mesg);
static void write_user_profile(     WolframLibraryData libData, MTensor data, int idx, const FIT_USER_PROFILE_MESG      *mesg);
static void write_activity(         WolframLibraryData libData, MTensor data, int idx, const FIT_ACTIVITY_MESG          *mesg);
static void write_lap(              WolframLibraryData libData, MTensor data, int idx, const FIT_LAP_MESG               *mesg);
static void write_record(           WolframLibraryData libData, MTensor data, int idx, const FIT_RECORD_MESG            *mesg);
static void write_event(            WolframLibraryData libData, MTensor data, int idx, const FIT_EVENT_MESG             *mesg);
static void write_device_info(      WolframLibraryData libData, MTensor data, int idx, const FIT_DEVICE_INFO_MESG       *mesg);
static void write_session(          WolframLibraryData libData, MTensor data, int idx, const FIT_SESSION_MESG           *mesg);
static void write_device_settings(  WolframLibraryData libData, MTensor data, int idx, const FIT_DEVICE_SETTINGS_MESG   *mesg);
static void write_zones_target(     WolframLibraryData libData, MTensor data, int idx, const FIT_ZONES_TARGET_MESG      *mesg);
static void write_file_creator(     WolframLibraryData libData, MTensor data, int idx, const FIT_FILE_CREATOR_MESG      *mesg);
static void write_sport(            WolframLibraryData libData, MTensor data, int idx, const FIT_SPORT_MESG             *mesg);
static void write_developer_data_id(WolframLibraryData libData, MTensor data, int idx, const FIT_DEVELOPER_DATA_ID_MESG *mesg);

static void write_unknown( WolframLibraryData libData, MTensor data, int idx, int mesgNum, const FIT_UINT8 *mesg );
