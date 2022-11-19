#define _CRT_SECURE_NO_WARNINGS

#include "WolframLibrary.h"
#include "stdio.h"
#include "string.h"
#include "fit_convert.h"

static int count_fit_records(char* input);


DLLEXPORT mint WolframLibrary_getVersion() {
    return WolframLibraryVersion;
}

DLLEXPORT int WolframLibrary_initialize(WolframLibraryData libData) {
    return 0;
}

DLLEXPORT void WolframLibrary_uninitialize(WolframLibraryData libData) {
    return;
}

DLLEXPORT int constantzero(
    WolframLibraryData libData,
    mint Argc, 
    MArgument *Args, 
    MArgument Res
) {
    MArgument_setInteger(Res, 0);
    return LIBRARY_NO_ERROR;
}

DLLEXPORT int FITImport(
    WolframLibraryData libData,
    mint Argc, 
    MArgument *Args, 
    MArgument Res
) {
    mint err;
    char *path;
    int length;
    MTensor data;
    mint dims[2];
    FILE *file;
    FIT_UINT8 buf[8];
    FIT_CONVERT_RETURN convert_return = FIT_CONVERT_CONTINUE;
    FIT_UINT32 buf_size;
    FIT_UINT32 mesg_index = 0;

    path = MArgument_getUTF8String(Args[0]);
    length = count_fit_records(path);
    if (!length) {
        return LIBRARY_FUNCTION_ERROR;
    }

    dims[0] = length;
    dims[1] = 46;
    err = libData->MTensor_new(MType_Integer, 2, dims, &data);
    if (err) {
        return err;
    }

    mint pos[2];
    int idx = 0;

    #if defined(FIT_CONVERT_MULTI_THREAD)
        FIT_CONVERT_STATE state;
    #endif

    // printf("Testing file conversion using %s file...\n", path);

    #if defined(FIT_CONVERT_MULTI_THREAD)
        FitConvert_Init(&state, FIT_TRUE);
    #else
        FitConvert_Init(FIT_TRUE);
    #endif

    if((file = fopen(path, "rb")) == NULL)
    {
        // printf("Error opening file %s.\n", path);
        return FIT_FALSE;
    }

    while(!feof(file) && (convert_return == FIT_CONVERT_CONTINUE))
    {
        for(buf_size=0;(buf_size < sizeof(buf)) && !feof(file); buf_size++)
        {
            buf[buf_size] = (FIT_UINT8)getc(file);
        }

        do
        {
            #if defined(FIT_CONVERT_MULTI_THREAD)
                convert_return = FitConvert_Read(&state, buf, buf_size);
            #else
                convert_return = FitConvert_Read(buf, buf_size);
            #endif

            switch (convert_return)
            {
                case FIT_CONVERT_MESSAGE_AVAILABLE:
                {
                #if defined(FIT_CONVERT_MULTI_THREAD)
                    const FIT_UINT8 *mesg = FitConvert_GetMessageData(&state);
                    FIT_UINT16 mesg_num = FitConvert_GetMessageNumber(&state);
                #else
                    const FIT_UINT8 *mesg = FitConvert_GetMessageData();
                    FIT_UINT16 mesg_num = FitConvert_GetMessageNumber();
                #endif

                mesg_index++;
                // printf("Mesg %d (%d) - ", mesg_index++, mesg_num);

                switch(mesg_num)
                {
                    case FIT_MESG_NUM_FILE_ID:
                    {
                        const FIT_FILE_ID_MESG *id = (FIT_FILE_ID_MESG *) mesg;
                        // printf("File ID: type=%u, number=%u\n", id->type, id->number);
                        break;
                    }

                    case FIT_MESG_NUM_USER_PROFILE:
                    {
                        const FIT_USER_PROFILE_MESG *user_profile = (FIT_USER_PROFILE_MESG *) mesg;
                        // printf("User Profile: weight=%0.1fkg\n", user_profile->weight / 10.0f);
                        break;
                    }

                    case FIT_MESG_NUM_ACTIVITY:
                    {
                        const FIT_ACTIVITY_MESG *activity = (FIT_ACTIVITY_MESG *) mesg;
                        // printf("Activity: timestamp=%u, type=%u, event=%u, event_type=%u, num_sessions=%u\n", activity->timestamp, activity->type, activity->event, activity->event_type, activity->num_sessions);
                        {
                            FIT_ACTIVITY_MESG old_mesg;
                            old_mesg.num_sessions = 1;
                            #if defined(FIT_CONVERT_MULTI_THREAD)
                            FitConvert_RestoreFields(&state, &old_mesg);
                            #else
                            FitConvert_RestoreFields(&old_mesg);
                            #endif
                            // printf("Restored num_sessions=1 - Activity: timestamp=%u, type=%u, event=%u, event_type=%u, num_sessions=%u\n", activity->timestamp, activity->type, activity->event, activity->event_type, activity->num_sessions);
                        }
                        break;
                    }

                    case FIT_MESG_NUM_SESSION:
                    {
                        const FIT_SESSION_MESG *session = (FIT_SESSION_MESG *) mesg;
                        // printf("Session: timestamp=%u\n", session->timestamp);
                        break;
                    }

                    case FIT_MESG_NUM_LAP:
                    {
                        const FIT_LAP_MESG *lap = (FIT_LAP_MESG *) mesg;
                        // printf("Lap: timestamp=%u\n", lap->timestamp);
                        break;
                    }

                    case FIT_MESG_NUM_RECORD:
                    {
                        const FIT_RECORD_MESG *record = (FIT_RECORD_MESG *) mesg;

                        idx++;
                        pos[0] = idx;
                        pos[1] = 1; libData->MTensor_setInteger(data, pos, (record->timestamp)+2840036400);
                        pos[1] = 2; libData->MTensor_setInteger(data, pos, record->position_lat);
                        pos[1] = 3; libData->MTensor_setInteger(data, pos, record->position_long);
                        pos[1] = 4; libData->MTensor_setInteger(data, pos, record->distance);
                        pos[1] = 5; libData->MTensor_setInteger(data, pos, record->time_from_course);
                        pos[1] = 6; libData->MTensor_setInteger(data, pos, record->total_cycles);
                        pos[1] = 7; libData->MTensor_setInteger(data, pos, record->accumulated_power);
                        pos[1] = 8; libData->MTensor_setInteger(data, pos, record->enhanced_speed);
                        pos[1] = 9; libData->MTensor_setInteger(data, pos, record->enhanced_altitude);
                        pos[1] = 10; libData->MTensor_setInteger(data, pos, record->altitude);
                        pos[1] = 11; libData->MTensor_setInteger(data, pos, record->speed);
                        pos[1] = 12; libData->MTensor_setInteger(data, pos, record->power);
                        // TODO: compute grade manually using distance/altitude if missing from the file?
                        pos[1] = 13; libData->MTensor_setInteger(data, pos, record->grade);
                        pos[1] = 14; libData->MTensor_setInteger(data, pos, record->compressed_accumulated_power);
                        pos[1] = 15; libData->MTensor_setInteger(data, pos, record->vertical_speed);
                        pos[1] = 16; libData->MTensor_setInteger(data, pos, record->calories);
                        pos[1] = 17; libData->MTensor_setInteger(data, pos, record->vertical_oscillation);
                        pos[1] = 18; libData->MTensor_setInteger(data, pos, record->stance_time_percent);
                        pos[1] = 19; libData->MTensor_setInteger(data, pos, record->stance_time);
                        pos[1] = 20; libData->MTensor_setInteger(data, pos, record->ball_speed);
                        pos[1] = 21; libData->MTensor_setInteger(data, pos, record->cadence256);
                        pos[1] = 22; libData->MTensor_setInteger(data, pos, record->total_hemoglobin_conc);
                        pos[1] = 23; libData->MTensor_setInteger(data, pos, record->total_hemoglobin_conc_min);
                        pos[1] = 24; libData->MTensor_setInteger(data, pos, record->total_hemoglobin_conc_max);
                        pos[1] = 25; libData->MTensor_setInteger(data, pos, record->saturated_hemoglobin_percent);
                        pos[1] = 26; libData->MTensor_setInteger(data, pos, record->saturated_hemoglobin_percent_min);
                        pos[1] = 27; libData->MTensor_setInteger(data, pos, record->saturated_hemoglobin_percent_max);
                        pos[1] = 28; libData->MTensor_setInteger(data, pos, record->heart_rate);
                        pos[1] = 29; libData->MTensor_setInteger(data, pos, record->cadence);
                        pos[1] = 30; libData->MTensor_setInteger(data, pos, record->resistance);
                        pos[1] = 31; libData->MTensor_setInteger(data, pos, record->cycle_length);
                        pos[1] = 32; libData->MTensor_setInteger(data, pos, record->temperature);
                        pos[1] = 33; libData->MTensor_setInteger(data, pos, record->cycles);
                        pos[1] = 34; libData->MTensor_setInteger(data, pos, record->left_right_balance);
                        pos[1] = 35; libData->MTensor_setInteger(data, pos, record->gps_accuracy);
                        pos[1] = 36; libData->MTensor_setInteger(data, pos, record->activity_type);
                        pos[1] = 37; libData->MTensor_setInteger(data, pos, record->left_torque_effectiveness);
                        pos[1] = 38; libData->MTensor_setInteger(data, pos, record->right_torque_effectiveness);
                        pos[1] = 39; libData->MTensor_setInteger(data, pos, record->left_pedal_smoothness);
                        pos[1] = 40; libData->MTensor_setInteger(data, pos, record->right_pedal_smoothness);
                        pos[1] = 41; libData->MTensor_setInteger(data, pos, record->combined_pedal_smoothness);
                        pos[1] = 42; libData->MTensor_setInteger(data, pos, record->time128);
                        pos[1] = 43; libData->MTensor_setInteger(data, pos, record->stroke_type);
                        pos[1] = 44; libData->MTensor_setInteger(data, pos, record->zone);
                        pos[1] = 45; libData->MTensor_setInteger(data, pos, record->fractional_cadence);
                        pos[1] = 46; libData->MTensor_setInteger(data, pos, record->device_index);

                        if (
                            (record->compressed_speed_distance[0] != FIT_BYTE_INVALID) ||
                            (record->compressed_speed_distance[1] != FIT_BYTE_INVALID) ||
                            (record->compressed_speed_distance[2] != FIT_BYTE_INVALID)
                            )
                        {
                            static FIT_UINT32 accumulated_distance16 = 0;
                            static FIT_UINT32 last_distance16 = 0;
                            FIT_UINT16 speed100;
                            FIT_UINT32 distance16;

                            speed100 = record->compressed_speed_distance[0] | ((record->compressed_speed_distance[1] & 0x0F) << 8);
                            // printf(", speed = %0.2fm/s", speed100/100.0f);

                            distance16 = (record->compressed_speed_distance[1] >> 4) | (record->compressed_speed_distance[2] << 4);
                            accumulated_distance16 += (distance16 - last_distance16) & 0x0FFF;
                            last_distance16 = distance16;

                            // printf(", distance = %0.3fm", accumulated_distance16/16.0f);
                        }

                        printf("\n");
                        break;
                    }

                    case FIT_MESG_NUM_EVENT:
                    {
                        const FIT_EVENT_MESG *event = (FIT_EVENT_MESG *) mesg;
                        // printf("Event: timestamp=%u\n", event->timestamp);
                        break;
                    }

                    case FIT_MESG_NUM_DEVICE_INFO:
                    {
                        const FIT_DEVICE_INFO_MESG *device_info = (FIT_DEVICE_INFO_MESG *) mesg;
                        // printf("Device Info: timestamp=%u\n", device_info->timestamp);
                        break;
                    }

                    default:
                        printf("Unknown\n");
                        break;
                }
                break;
                }

                default:
                break;
            }
        } while (convert_return == FIT_CONVERT_MESSAGE_AVAILABLE);
    }

    if (convert_return == FIT_CONVERT_ERROR)
    {
        // printf("Error decoding file.\n");
        fclose(file);
        return 1;
    }

    if (convert_return == FIT_CONVERT_CONTINUE)
    {
        // printf("Unexpected end of file.\n");
        fclose(file);
        return 1;
    }

    if (convert_return == FIT_CONVERT_DATA_TYPE_NOT_SUPPORTED)
    {
        // printf("File is not FIT.\n");
        fclose(file);
        return 1;
    }

    if (convert_return == FIT_CONVERT_PROTOCOL_VERSION_NOT_SUPPORTED)
    {
        // printf("Protocol version not supported.\n");
        fclose(file);
        return 1;
    }

    if (convert_return == FIT_CONVERT_END_OF_FILE)
        // printf("File converted successfully.\n");

    fclose(file);

    MArgument_setMTensor(Res, data);
    return LIBRARY_NO_ERROR;
}


static int count_fit_records(char* input)
{
   FILE *file;
   FIT_UINT8 buf[8];
   FIT_CONVERT_RETURN convert_return = FIT_CONVERT_CONTINUE;
   FIT_UINT32 buf_size;
   int record_count = 0;
   #if defined(FIT_CONVERT_MULTI_THREAD)
      FIT_CONVERT_STATE state;
   #endif

   #if defined(FIT_CONVERT_MULTI_THREAD)
      FitConvert_Init(&state, FIT_TRUE);
   #else
      FitConvert_Init(FIT_TRUE);
   #endif

   if((file = fopen(input, "rb")) == NULL)
   {
      return 0;
   }

   while(!feof(file) && (convert_return == FIT_CONVERT_CONTINUE))
   {
      for(buf_size=0;(buf_size < sizeof(buf)) && !feof(file); buf_size++)
      {
         buf[buf_size] = (FIT_UINT8)getc(file);
      }

      do
      {
         #if defined(FIT_CONVERT_MULTI_THREAD)
            convert_return = FitConvert_Read(&state, buf, buf_size);
         #else
            convert_return = FitConvert_Read(buf, buf_size);
         #endif

         switch (convert_return)
         {
            case FIT_CONVERT_MESSAGE_AVAILABLE:
            {
               #if defined(FIT_CONVERT_MULTI_THREAD)
                  const FIT_UINT8 *mesg = FitConvert_GetMessageData(&state);
                  FIT_UINT16 mesg_num = FitConvert_GetMessageNumber(&state);
               #else
                  const FIT_UINT8 *mesg = FitConvert_GetMessageData();
                  FIT_UINT16 mesg_num = FitConvert_GetMessageNumber();
               #endif

               switch(mesg_num)
               {
                  case FIT_MESG_NUM_RECORD:
                  {
                     record_count++;
                     break;
                  }
                  default:
                    break;
               }
               break;
            }

            default:
               break;
         }
      } while (convert_return == FIT_CONVERT_MESSAGE_AVAILABLE);
   }

   fclose(file);

   return record_count;
}