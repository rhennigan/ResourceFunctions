#define _CRT_SECURE_NO_WARNINGS

#include "fit_import.h"

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
    mint err = 0;
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
    length = count_usable_fit_messages(path, &err);
    if (err) {
        return err;
    }

    dims[0] = length;
    dims[1] = MESSAGE_TENSOR_ROW_WIDTH;
    err = libData->MTensor_new(MType_Integer, 2, dims, &data);
    if (err) {
        return FIT_IMPORT_ERROR_INTERNAL;
    }

    mint pos[2];
    int idx = 0;
    int col = 0;

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
        return FIT_IMPORT_ERROR_OPEN_FILE;
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
                        idx++;
                        write_file_id(libData, data, idx, id);
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
                        write_record(libData, data, idx, record);
                        break;
                    }

                    case FIT_MESG_NUM_EVENT:
                    {
                        const FIT_EVENT_MESG *event = (FIT_EVENT_MESG *) mesg;
                        idx++;
                        write_event(libData, data, idx, event);
                        break;
                    }

                    case FIT_MESG_NUM_DEVICE_INFO:
                    {
                        const FIT_DEVICE_INFO_MESG *device_info = (FIT_DEVICE_INFO_MESG *) mesg;
                        idx++;
                        write_device_info(libData, data, idx, device_info);
                        break;
                    }

                    case FIT_MESG_NUM_SESSION:
                    {
                        const FIT_SESSION_MESG *session = (FIT_SESSION_MESG *) mesg;
                        idx++;
                        write_session(libData, data, idx, session);
                        break;
                    }

                    default:
                    {
                        // idx++;
                        // write_unknown(libData, data, idx, mesg_num, mesg);
                        break;
                    }
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
        // Error decoding file
        fclose(file);
        return FIT_IMPORT_ERROR_CONVERSION;
    }

    if (convert_return == FIT_CONVERT_CONTINUE)
    {
        // Unexpected end of file
        fclose(file);
        return FIT_IMPORT_ERROR_UNEXPECTED_EOF;
    }

    if (convert_return == FIT_CONVERT_DATA_TYPE_NOT_SUPPORTED)
    {
        // File is not FIT
        fclose(file);
        return FIT_IMPORT_ERROR_NOT_FIT_FILE;
    }

    if (convert_return == FIT_CONVERT_PROTOCOL_VERSION_NOT_SUPPORTED)
    {
        // Protocol version not supported
        fclose(file);
        return FIT_IMPORT_ERROR_UNSUPPORTED_PROTOCOL;
    }

    if (convert_return == FIT_CONVERT_END_OF_FILE)
        // File converted successfully

    fclose(file);

    MArgument_setMTensor(Res, data);
    return LIBRARY_NO_ERROR;
}

DLLEXPORT int FITMessageTypes (
    WolframLibraryData libData,
    mint Argc, 
    MArgument *Args, 
    MArgument Res
) {
    mint err = 0;
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
    length = count_fit_messages(path, &err);
    if (err) {
        return err;
    }

    dims[0] = length;
    dims[1] = 1;
    err = libData->MTensor_new(MType_Integer, 2, dims, &data);
    if (err) {
        return FIT_IMPORT_ERROR_INTERNAL;
    }

    mint pos[2];
    int idx = 0;
    int col = 0;

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
        return FIT_IMPORT_ERROR_OPEN_FILE;
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

                idx++;
                pos[0] = idx;
                pos[1] = 1;
                libData->MTensor_setInteger(data, pos, mesg_num);

                break;
                }

                default:
                break;
            }
        } while (convert_return == FIT_CONVERT_MESSAGE_AVAILABLE);
    }

    if (convert_return == FIT_CONVERT_ERROR)
    {
        // Error decoding file
        fclose(file);
        return FIT_IMPORT_ERROR_CONVERSION;
    }

    if (convert_return == FIT_CONVERT_CONTINUE)
    {
        // Unexpected end of file
        fclose(file);
        return FIT_IMPORT_ERROR_UNEXPECTED_EOF;
    }

    if (convert_return == FIT_CONVERT_DATA_TYPE_NOT_SUPPORTED)
    {
        // File is not FIT
        fclose(file);
        return FIT_IMPORT_ERROR_NOT_FIT_FILE;
    }

    if (convert_return == FIT_CONVERT_PROTOCOL_VERSION_NOT_SUPPORTED)
    {
        // Protocol version not supported
        fclose(file);
        return FIT_IMPORT_ERROR_UNSUPPORTED_PROTOCOL;
    }

    if (convert_return == FIT_CONVERT_END_OF_FILE)
        // printf("File converted successfully.\n");

    fclose(file);

    MArgument_setMTensor(Res, data);
    return LIBRARY_NO_ERROR;
}

static void write_file_id(WolframLibraryData libData, MTensor data, int idx, const FIT_FILE_ID_MESG *mesg)
{
    mint pos[2];
    pos[0] = idx;
    pos[1] = 0;
    pos[1]++; libData->MTensor_setInteger(data, pos, FIT_MESG_NUM_FILE_ID);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->serial_number);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->time_created)+2840036400);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->manufacturer);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->product);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->number);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->type);
    for(int i=0; i<FIT_FILE_ID_MESG_PRODUCT_NAME_COUNT; i++)
    {
        pos[1]++; libData->MTensor_setInteger(data, pos, mesg->product_name[i]);
    }
}

static void write_record(WolframLibraryData libData, MTensor data, int idx, const FIT_RECORD_MESG *mesg)
{
    mint pos[2];
    pos[0] = idx;
    pos[1] = 0;

    pos[1]++; libData->MTensor_setInteger(data, pos, FIT_MESG_NUM_RECORD);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->timestamp)+2840036400);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->position_lat);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->position_long);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->distance);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->time_from_course);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_cycles);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->accumulated_power);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->enhanced_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->enhanced_altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->power);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->grade);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->compressed_accumulated_power);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->vertical_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->calories);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->vertical_oscillation);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->stance_time_percent);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->stance_time);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->ball_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->cadence256);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_hemoglobin_conc);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_hemoglobin_conc_min);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_hemoglobin_conc_max);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->saturated_hemoglobin_percent);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->saturated_hemoglobin_percent_min);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->saturated_hemoglobin_percent_max);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->heart_rate);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->cadence);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->resistance);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->cycle_length);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->temperature);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->cycles);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->left_right_balance);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->gps_accuracy);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->activity_type);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->left_torque_effectiveness);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->right_torque_effectiveness);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->left_pedal_smoothness);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->right_pedal_smoothness);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->combined_pedal_smoothness);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->time128);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->stroke_type);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->zone);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->fractional_cadence);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->device_index);

    if (
        (mesg->compressed_speed_distance[0] != FIT_BYTE_INVALID) ||
        (mesg->compressed_speed_distance[1] != FIT_BYTE_INVALID) ||
        (mesg->compressed_speed_distance[2] != FIT_BYTE_INVALID)
        )
    {
        static FIT_UINT32 accumulated_distance16 = 0;
        static FIT_UINT32 last_distance16 = 0;
        FIT_UINT16 speed100;
        FIT_UINT32 distance16;

        speed100 = mesg->compressed_speed_distance[0] | ((mesg->compressed_speed_distance[1] & 0x0F) << 8);
        // printf(", speed = %0.2fm/s", speed100/100.0f);

        distance16 = (mesg->compressed_speed_distance[1] >> 4) | (mesg->compressed_speed_distance[2] << 4);
        accumulated_distance16 += (distance16 - last_distance16) & 0x0FFF;
        last_distance16 = distance16;

        // printf(", distance = %0.3fm", accumulated_distance16/16.0f);
    }
}


static void write_event(WolframLibraryData libData, MTensor data, int idx, const FIT_EVENT_MESG *mesg)
{
    mint pos[2];
    pos[0] = idx;
    pos[1] = 0;
    pos[1]++; libData->MTensor_setInteger(data, pos, FIT_MESG_NUM_EVENT);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->timestamp)+2840036400);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->data);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->data16);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->score);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->opponent_score);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->event);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->event_type);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->event_group);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->front_gear_num);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->front_gear);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->rear_gear_num);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->rear_gear);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->radar_threat_level_max);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->radar_threat_count);
}


static void write_device_info(WolframLibraryData libData, MTensor data, int idx, const FIT_DEVICE_INFO_MESG *mesg)
{
    mint pos[2];
    pos[0] = idx;
    pos[1] = 0;
    pos[1]++; libData->MTensor_setInteger(data, pos, FIT_MESG_NUM_DEVICE_INFO);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->timestamp)+2840036400);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->serial_number);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->cum_operating_time);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->manufacturer);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->product);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->software_version);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->battery_voltage);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->ant_device_number);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->device_index);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->device_type);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->hardware_version);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->battery_status);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->sensor_position);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->ant_transmission_type);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->ant_network);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->source_type);
    for(int i=0; i<FIT_DEVICE_INFO_MESG_PRODUCT_NAME_COUNT; i++)
    {
        pos[1]++; libData->MTensor_setInteger(data, pos, mesg->product_name[i]);
    }
}

void write_session(WolframLibraryData libData, MTensor data, int idx, const FIT_SESSION_MESG *mesg)
{
    mint pos[2];
    pos[0] = idx;
    pos[1] = 0;
    pos[1]++; libData->MTensor_setInteger(data, pos, FIT_MESG_NUM_SESSION);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->timestamp)+2840036400);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->start_time)+2840036400);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->start_position_lat);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->start_position_long);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_elapsed_time);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_timer_time);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_distance);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_cycles);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->nec_lat);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->nec_long);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->swc_lat);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->swc_long);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_stroke_count);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_work);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_moving_time);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->time_in_hr_zone)[0]);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->time_in_speed_zone)[0]);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->time_in_cadence_zone)[0]);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->time_in_power_zone)[0]);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_lap_time);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->enhanced_avg_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->enhanced_max_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->enhanced_avg_altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->enhanced_min_altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->enhanced_max_altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->message_index);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_calories);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_fat_calories);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_power);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_power);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_ascent);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_descent);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->first_lap_index);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->num_laps);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->num_lengths);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->normalized_power);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->training_stress_score);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->intensity_factor);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->left_right_balance);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_stroke_distance);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->pool_length);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->threshold_power);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->num_active_lengths);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_grade);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_pos_grade);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_neg_grade);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_pos_grade);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_neg_grade);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_pos_vertical_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_neg_vertical_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_pos_vertical_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_neg_vertical_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->best_lap_index);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->min_altitude);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->player_score);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->opponent_score);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->stroke_count)[0]);
    pos[1]++; libData->MTensor_setInteger(data, pos, (mesg->zone_count)[0]);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_ball_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_ball_speed);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_vertical_oscillation);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_stance_time_percent);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_stance_time);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_vam);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->event);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->event_type);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->sport);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->sub_sport);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_heart_rate);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_heart_rate);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_cadence);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_cadence);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_training_effect);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->event_group);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->trigger);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->swim_stroke);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->pool_length_unit);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->gps_accuracy);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_temperature);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_temperature);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->min_heart_rate);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->avg_fractional_cadence);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->max_fractional_cadence);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_fractional_cycles);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->sport_index);
    pos[1]++; libData->MTensor_setInteger(data, pos, mesg->total_anaerobic_training_effect);
}


void write_unknown(WolframLibraryData libData, MTensor data, int idx, int mesgNum, const FIT_UINT8 *mesg)
{
    mint pos[2];
    pos[0] = idx;
    pos[1] = 0;
    pos[1]++; libData->MTensor_setInteger(data, pos, mesgNum);
    for (int i = 0; i < MESSAGE_TENSOR_ROW_WIDTH; i++)
    {
        pos[1]++; 
        libData->MTensor_setInteger(data, pos, mesg[i]);
    }
}


static int count_usable_fit_messages(char* input, mint *err)
{
   FILE *file;
   FIT_UINT8 buf[8];
   FIT_CONVERT_RETURN convert_return = FIT_CONVERT_CONTINUE;
   FIT_UINT32 buf_size;
   int mesg_count = 0;
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
      *err = FIT_IMPORT_ERROR_OPEN_FILE;
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
                  case FIT_MESG_NUM_FILE_ID:
                  {
                     mesg_count++;
                     break;
                  }
                  case FIT_MESG_NUM_RECORD:
                  {
                     mesg_count++;
                     break;
                  }
                  case FIT_MESG_NUM_EVENT:
                  {
                     mesg_count++;
                     break;
                  }
                  case FIT_MESG_NUM_DEVICE_INFO:
                  {
                     mesg_count++;
                     break;
                  }
                  case FIT_MESG_NUM_SESSION:
                  {
                     mesg_count++;
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

   if (convert_return == FIT_CONVERT_ERROR)
    {
        // Error decoding file
        fclose(file);
        *err = FIT_IMPORT_ERROR_CONVERSION;
        return 0;
    }

    if (convert_return == FIT_CONVERT_CONTINUE)
    {
        // Unexpected end of file
        fclose(file);
        *err = FIT_IMPORT_ERROR_UNEXPECTED_EOF;
        return 0;
    }

    if (convert_return == FIT_CONVERT_DATA_TYPE_NOT_SUPPORTED)
    {
        // File is not FIT
        fclose(file);
        *err = FIT_IMPORT_ERROR_NOT_FIT_FILE;
        return 0;
    }

    if (convert_return == FIT_CONVERT_PROTOCOL_VERSION_NOT_SUPPORTED)
    {
        // Protocol version not supported
        fclose(file);
        *err = FIT_IMPORT_ERROR_UNSUPPORTED_PROTOCOL;
        return 0;
    }

   fclose(file);

   return mesg_count;
}


static int count_fit_messages(char* input, mint* err)
{
   FILE *file;
   FIT_UINT8 buf[8];
   FIT_CONVERT_RETURN convert_return = FIT_CONVERT_CONTINUE;
   FIT_UINT32 buf_size;
   int mesg_count = 0;
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
      *err = FIT_IMPORT_ERROR_OPEN_FILE;
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

               mesg_count++;
               break;
            }

            default:
               break;
         }
      } while (convert_return == FIT_CONVERT_MESSAGE_AVAILABLE);
   }

   if (convert_return == FIT_CONVERT_ERROR)
    {
        // Error decoding file
        fclose(file);
        *err = FIT_IMPORT_ERROR_CONVERSION;
        return 0;
    }

    if (convert_return == FIT_CONVERT_CONTINUE)
    {
        // Unexpected end of file
        fclose(file);
        *err = FIT_IMPORT_ERROR_UNEXPECTED_EOF;
        return 0;
    }

    if (convert_return == FIT_CONVERT_DATA_TYPE_NOT_SUPPORTED)
    {
        // File is not FIT
        fclose(file);
        *err = FIT_IMPORT_ERROR_NOT_FIT_FILE;
        return 0;
    }

    if (convert_return == FIT_CONVERT_PROTOCOL_VERSION_NOT_SUPPORTED)
    {
        // Protocol version not supported
        fclose(file);
        *err = FIT_IMPORT_ERROR_UNSUPPORTED_PROTOCOL;
        return 0;
    }

   fclose(file);

   return mesg_count;
}