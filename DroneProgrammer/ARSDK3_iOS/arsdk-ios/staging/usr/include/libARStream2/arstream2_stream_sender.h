/**
 * @file arstream2_stream_sender.h
 * @brief Parrot Streaming Library - Stream Sender
 * @date 08/03/2016
 * @author aurelien.barre@parrot.com
 */

#ifndef _ARSTREAM2_STREAM_SENDER_H_
#define _ARSTREAM2_STREAM_SENDER_H_

#ifdef __cplusplus
extern "C" {
#endif /* #ifdef __cplusplus */

#include <inttypes.h>
#include <libARStream2/arstream2_error.h>
#include <libARStream2/arstream2_stream_stats.h>
#include <libARStream2/arstream2_stream_metadata.h>
#include <libARSAL/ARSAL_Socket.h>


/**
 * @brief Default server-side stream port
 */
#define ARSTREAM2_STREAM_SENDER_DEFAULT_SERVER_STREAM_PORT     (5004)


/**
 * @brief Default server-side control port
 */
#define ARSTREAM2_STREAM_SENDER_DEFAULT_SERVER_CONTROL_PORT    (5005)


/**
 * @brief Default H.264 NAL unit FIFO size
 */
#define ARSTREAM2_STREAM_SENDER_DEFAULT_NALU_FIFO_SIZE         (1024)


/**
 * @brief Maximum number of NAL units importance levels
 */
#define ARSTREAM2_STREAM_SENDER_MAX_IMPORTANCE_LEVELS          (4)


/**
 * @brief Maximum number of NAL units priority levels
 */
#define ARSTREAM2_STREAM_SENDER_MAX_PRIORITY_LEVELS            (5)


/**
 * @brief ARSTREAM2 StreamSender instance handle.
 */
typedef struct ARSTREAM2_StreamSender_s *ARSTREAM2_StreamSender_Handle;


/**
 * @brief Callback status values
 */
typedef enum
{
    ARSTREAM2_STREAM_SENDER_STATUS_SENT = 0,   /**< Access unit or NAL unit was sent */
    ARSTREAM2_STREAM_SENDER_STATUS_CANCELLED,  /**< Access unit or NAL unit was cancelled (not sent or partly sent) */
    ARSTREAM2_STREAM_SENDER_STATUS_MAX,

} eARSTREAM2_STREAM_SENDER_STATUS;


/**
 * @brief Sender monitoring data
 */
typedef struct ARSTREAM2_StreamSender_MonitoringData_t
{
    uint64_t startTimestamp;                /**< Monitoring start timestamp in microseconds */
    uint32_t timeInterval;                  /**< Monitoring time interval in microseconds */
    uint32_t acqToNetworkTimeMin;           /**< Minimum acquisition to network time during timeInterval in microseconds */
    uint32_t acqToNetworkTimeMax;           /**< Maximum acquisition to network time during timeInterval in microseconds */
    uint32_t acqToNetworkTimeMean;          /**< Mean acquisition to network time during timeInterval in microseconds */
    uint32_t acqToNetworkTimeJitter;        /**< Acquisition to network time jitter during timeInterval in microseconds */
    uint32_t networkTimeMin;                /**< Minimum network time during timeInterval in microseconds */
    uint32_t networkTimeMax;                /**< Maximum network time during timeInterval in microseconds */
    uint32_t networkTimeMean;               /**< Mean network time during timeInterval in microseconds */
    uint32_t networkTimeJitter;             /**< Network time jitter during timeInterval in microseconds */
    uint32_t bytesSent;                     /**< Bytes sent during timeInterval */
    uint32_t packetsSent;                   /**< Packets sent during timeInterval */
    uint32_t packetSizeMin;                 /**< Minimum packet size during timeInterval */
    uint32_t packetSizeMax;                 /**< Maximum packet size during timeInterval */
    uint32_t packetSizeMean;                /**< Mean packet size during timeInterval */
    uint32_t packetSizeStdDev;              /**< Packet size standard deviation during timeInterval */
    uint32_t bytesDropped;                  /**< Bytes dropped during timeInterval */
    uint32_t packetsDropped;                /**< Packets dropped during timeInterval */

} ARSTREAM2_StreamSender_MonitoringData_t;


/**
 * @brief Callback function for access units
 * This callback function is called when buffers associated with an access unit are no longer used by the sender.
 * This occurs when packets corresponding to an access unit have all been sent or dropped.
 *
 * @param[in] status Why the call is made
 * @param[in] auUserPtr Access unit user pointer associated with the NAL units submitted to the sender
 * @param[in] userPtr Global access unit callback user pointer
 */
typedef void (*ARSTREAM2_StreamSender_AuCallback_t) (eARSTREAM2_STREAM_SENDER_STATUS status, void *auUserPtr, void *userPtr);


/**
 * @brief Callback function for NAL units
 * This callback function is called when a buffer associated with a NAL unit is no longer used by the sender.
 * This occurs when packets corresponding to a NAL unit have all been sent or dropped.
 *
 * @param[in] status Why the call is made
 * @param[in] naluUserPtr NAL unit user pointer associated with the NAL unit submitted to the sender
 * @param[in] userPtr Global NAL unit callback user pointer
 */
typedef void (*ARSTREAM2_StreamSender_NaluCallback_t) (eARSTREAM2_STREAM_SENDER_STATUS status, void *naluUserPtr, void *userPtr);


/**
 * @brief Callback function for RTP stats
 * This callback function is called when an RTCP receiver report has been received.
 *
 * @param[in] rtpStats Pointer to the RTP stats data
 * @param[in] userPtr Global receiver report callback user pointer
 */
typedef void (*ARSTREAM2_StreamSender_RtpStatsCallback_t) (const ARSTREAM2_StreamStats_RtpStats_t *rtpStats, void *userPtr);


/**
 * @brief Callback function for video stats
 * This callback function is called when video stats have been received.
 *
 * @param[in] videoStats Pointer to the video stats data
 * @param[in] userPtr Global receiver report callback user pointer
 */
typedef void (*ARSTREAM2_StreamSender_VideoStatsCallback_t) (const ARSTREAM2_StreamStats_VideoStats_t *videoStats, void *userPtr);


/**
 * @brief Callback function for disconnection
 * This callback function is called when the stream socket is no longer connected.
 * The sender thread continues running and the callback function may be called multiple times.
 *
 * @note It is the application's responsibility to stop a sender using ARSTREAM2_StreamSender_Stop() and ARSTREAM2_StreamSender_Delete()
 *
 * @param[in] userPtr Global receiver report callback user pointer
 */
typedef void (*ARSTREAM2_StreamSender_DisconnectionCallback_t) (void *userPtr);


/**
 * @brief StreamSender configuration parameters
 */
typedef struct ARSTREAM2_StreamSender_Config_t
{
    const char *canonicalName;                      /**< RTP participant canonical name (CNAME SDES item) */
    const char *friendlyName;                       /**< RTP participant friendly name (NAME SDES item) (optional, can be NULL) */
    const char *applicationName;                    /**< RTP participant application name (TOOL SDES item) (optional, can be NULL) */
    const char *clientAddr;                         /**< Client address */
    const char *mcastAddr;                          /**< Multicast send address (optional, NULL for no multicast) */
    const char *mcastIfaceAddr;                     /**< Multicast output interface address (required if mcastAddr is not NULL) */
    int serverStreamPort;                           /**< Server stream port, @see ARSTREAM2_STREAM_SENDER_DEFAULT_SERVER_STREAM_PORT */
    int serverControlPort;                          /**< Server control port, @see ARSTREAM2_STREAM_SENDER_DEFAULT_SERVER_CONTROL_PORT */
    int clientStreamPort;                           /**< Client stream port */
    int clientControlPort;                          /**< Client control port */
    eARSAL_SOCKET_CLASS_SELECTOR classSelector;     /**< Type of Service class selector */
    int streamSocketBufferSize;                     /**< Send buffer size for the stream socket (optional, can be 0) */
    ARSTREAM2_StreamSender_AuCallback_t auCallback;       /**< Access unit callback function (optional, can be NULL) */
    void *auCallbackUserPtr;                        /**< Access unit callback function user pointer (optional, can be NULL) */
    ARSTREAM2_StreamSender_NaluCallback_t naluCallback;   /**< NAL unit callback function (optional, can be NULL) */
    void *naluCallbackUserPtr;                      /**< NAL unit callback function user pointer (optional, can be NULL) */
    ARSTREAM2_StreamSender_RtpStatsCallback_t rtpStatsCallback;   /**< RTP stats reception callback function (optional, can be NULL) */
    void *rtpStatsCallbackUserPtr;                  /**< RTP stats reception callback function user pointer (optional, can be NULL) */
    ARSTREAM2_StreamSender_VideoStatsCallback_t videoStatsCallback;   /**< Video stats reception callback function (optional, can be NULL) */
    void *videoStatsCallbackUserPtr;                /**< Video stats reception callback function user pointer (optional, can be NULL) */
    ARSTREAM2_StreamSender_DisconnectionCallback_t disconnectionCallback;   /**< Disconnection callback function (optional, can be NULL) */
    void *disconnectionCallbackUserPtr;             /**< Disconnection callback function user pointer (optional, can be NULL) */
    int naluFifoSize;                               /**< NAL unit FIFO size, @see ARSTREAM2_STREAM_SENDER_DEFAULT_NALU_FIFO_SIZE */
    int maxPacketSize;                              /**< Maximum network packet size in bytes (example: the interface MTU) */
    int targetPacketSize;                           /**< Target network packet size in bytes */
    int maxBitrate;                                 /**< Maximum streaming bitrate in bit/s (optional, can be 0) */
    int maxLatencyMs;                               /**< Maximum acceptable total latency in milliseconds (optional, can be 0) */
    int maxNetworkLatencyMs[ARSTREAM2_STREAM_SENDER_MAX_IMPORTANCE_LEVELS];  /**< Maximum acceptable network latency in milliseconds for each NALU importance level */
    int useRtpHeaderExtensions;                     /**< Boolean-like (0-1) flag: if active insert access unit metadata as RTP header extensions */
    const char *debugPath;                          /**< Optional path for writing debug files (optional, can be NULL) */

} ARSTREAM2_StreamSender_Config_t;


/**
 * @brief StreamSender dynamic configuration parameters
 */
typedef struct ARSTREAM2_StreamSender_DynamicConfig_t
{
    int targetPacketSize;                           /**< Target network packet size in bytes */
    int streamSocketBufferSize;                     /**< Send buffer size for the stream socket (optional, can be 0) */
    int maxBitrate;                                 /**< Maximum streaming bitrate in bit/s (optional, can be 0) */
    int maxLatencyMs;                               /**< Maximum acceptable total latency in milliseconds (optional, can be 0) */
    int maxNetworkLatencyMs[ARSTREAM2_STREAM_SENDER_MAX_IMPORTANCE_LEVELS];  /**< Maximum acceptable network latency in milliseconds for each NALU importance level */

} ARSTREAM2_StreamSender_DynamicConfig_t;


/**
 * @brief StreamSender NAL unit descriptor
 */
typedef struct ARSTREAM2_StreamSender_H264NaluDesc_t
{
    uint8_t *naluBuffer;                            /**< Pointer to the NAL unit buffer */
    uint32_t naluSize;                              /**< Size of the NAL unit in bytes */
    uint8_t *auMetadata;                            /**< Pointer to the optional access unit metadata buffer */
    uint32_t auMetadataSize;                        /**< Size of the optional access unit metadata in bytes */
    uint64_t auTimestamp;                           /**< Access unit timastamp in microseconds. All NAL units of an access unit must share the same timestamp */
    uint32_t isLastNaluInAu;                        /**< Boolean-like flag (0/1). If active, tells the sender that the NAL unit is the last of the access unit */
    uint32_t seqNumForcedDiscontinuity;             /**< Force an added discontinuity in RTP sequence number before the NAL unit */
    uint32_t importance;                            /**< Importance indication (low numbers are more important, valid range: 0..ARSTREAM2_STREAM_SENDER_MAX_IMPORTANCE_LEVELS-1) */
    uint32_t priority;                              /**< Priority indication (low numbers are more important, valid range: 0..ARSTREAM2_STREAM_SENDER_MAX_PRIORITY_LEVELS-1) */
    void *auUserPtr;                                /**< Access unit user pointer that will be passed to the access unit callback function (optional, can be NULL) */
    void *naluUserPtr;                              /**< NAL unit user pointer that will be passed to the NAL unit callback function (optional, can be NULL) */

} ARSTREAM2_StreamSender_H264NaluDesc_t;


/**
 * @brief Creates a new StreamSender
 * @warning This function allocates memory. The sender must be deleted by a call to ARSTREAM2_StreamSender_Delete()
 *
 * @param[in] config Pointer to a configuration parameters structure
 * @param[out] error Optionnal pointer to an eARSTREAM2_ERROR to hold any error information
 *
 * @return A pointer to the new ARSTREAM2_StreamSender_t, or NULL if an error occured
 *
 * @see ARSTREAM2_StreamSender_Stop()
 * @see ARSTREAM2_StreamSender_Delete()
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_Init(ARSTREAM2_StreamSender_Handle *streamSenderHandle,
                                             const ARSTREAM2_StreamSender_Config_t *config);


/**
 * @brief Stops a running StreamSender
 * @warning Once stopped, a sender cannot be restarted
 *
 * @param[in] sender The sender instance
 *
 * @note Calling this function multiple times has no effect
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_Stop(ARSTREAM2_StreamSender_Handle streamSenderHandle);


/**
 * @brief Deletes an StreamSender
 * @warning This function should NOT be called on a running sender
 *
 * @param sender Pointer to the ARSTREAM2_StreamSender_t* to delete
 *
 * @return ARSTREAM2_OK if the sender was deleted
 * @return ARSTREAM2_ERROR_BUSY if the sender is still busy and can not be stopped now (probably because ARSTREAM2_StreamSender_Stop() has not been called yet)
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if sender does not point to a valid ARSTREAM2_StreamSender_t
 *
 * @note The function uses a double pointer, so it can set *sender to NULL after freeing it
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_Free(ARSTREAM2_StreamSender_Handle *streamSenderHandle);


/**
 * @brief Sends a new NAL unit
 * @warning The NAL unit buffer must remain available for the sender until the NAL unit or access unit callback functions are called.
 *
 * @param[in] sender The sender instance
 * @param[in] nalu Pointer to a NAL unit descriptor
 * @param[in] inputTime Optional input timestamp in microseconds
 *
 * @return ARSTREAM2_OK if no error happened
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the sender, nalu or naluBuffer pointers are invalid, or if naluSize or auTimestamp is zero
 * @return ARSTREAM2_ERROR_QUEUE_FULL if the NAL unit FIFO is full
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_SendNewNalu(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                    const ARSTREAM2_StreamSender_H264NaluDesc_t *nalu,
                                                    uint64_t inputTime);


/**
 * @brief Sends multiple new NAL units
 * @warning The NAL unit buffers must remain available for the sender until the NAL unit or access unit callback functions are called.
 *
 * @param[in] sender The sender instance
 * @param[in] nalu Pointer to a NAL unit descriptor array
 * @param[in] naluCount Number of NAL units in the array
 * @param[in] inputTime Optional input timestamp in microseconds
 *
 * @return ARSTREAM2_OK if no error happened
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the sender, nalu or naluBuffer pointers are invalid, or if a naluSize or auTimestamp is zero
 * @return ARSTREAM2_ERROR_QUEUE_FULL if the NAL unit FIFO is full
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_SendNNewNalu(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                     const ARSTREAM2_StreamSender_H264NaluDesc_t *nalu,
                                                     int naluCount, uint64_t inputTime);


/**
 * @brief Flush all currently queued NAL units
 *
 * @param[in] sender The sender instance
 *
 * @return ARSTREAM2_OK if no error occured.
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the sender is invalid.
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_FlushNaluQueue(ARSTREAM2_StreamSender_Handle streamSenderHandle);


/**
 * @brief Runs the main loop of the StreamSender
 * @warning This function never returns until ARSTREAM2_StreamSender_Stop() is called. Thus, it should be called on its own thread.
 * @post Stop the Sender by calling ARSTREAM2_StreamSender_Stop() before joining the thread calling this function.
 *
 * @param[in] ARSTREAM2_StreamSender_t_Param A valid (ARSTREAM2_StreamSender_t *) casted as a (void *)
 */
void* ARSTREAM2_StreamSender_RunThread(void *streamSenderHandle);


/**
 * @brief Get the current dynamic configuration parameters
 *
 * @param[in] sender The sender instance
 * @param[out] config Pointer to a dynamic config structure to fill
 *
 * @return ARSTREAM2_OK if no error happened
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the sender or config pointers are invalid
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_GetDynamicConfig(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                         ARSTREAM2_StreamSender_DynamicConfig_t *config);


/**
 * @brief Set the current dynamic configuration parameters
 *
 * @param[in] sender The sender instance
 * @param[in] config Pointer to a dynamic config structure
 *
 * @return ARSTREAM2_OK if no error happened
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the sender or config pointers are invalid
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_SetDynamicConfig(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                         const ARSTREAM2_StreamSender_DynamicConfig_t *config);


/**
 * @brief Get the untimed metadata
 *
 * @param streamSenderHandle Instance handle.
 * @param[out] metadata Current untimed metadata structure
 * @param[out] sendInterval Pointer to the minimum send interval in microseconds (optional, can be NULL)
 *
 * @return ARSTREAM2_OK if no error happened
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the streamSenderHandle or metadata pointer are invalid
 * @return ARSTREAM2_ERROR_NOT_FOUND it the item has not been found
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_GetUntimedMetadata(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                           ARSTREAM2_Stream_UntimedMetadata_t *metadata, uint32_t *sendInterval);


/**
 * @brief Set the untimed metadata
 *
 * @param streamSenderHandle Instance handle.
 * @param[in] metadata Current untimed metadata structure
 * @param[in] sendInterval Minimum send interval in microseconds (0 means default)
 *
 * @return ARSTREAM2_OK if no error happened
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the streamSenderHandle or metadata pointer are invalid
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_SetUntimedMetadata(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                           const ARSTREAM2_Stream_UntimedMetadata_t *metadata, uint32_t sendInterval);


/**
 * @brief Get the peer untimed metadata
 *
 * @param streamSenderHandle Instance handle.
 * @param[out] metadata Current peer untimed metadata structure
 *
 * @return ARSTREAM2_OK if no error happened
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the streamSenderHandle or metadata pointer are invalid
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_GetPeerUntimedMetadata(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                               ARSTREAM2_Stream_UntimedMetadata_t *metadata);


/**
 * @brief Get the stream monitoring
 * The monitoring data is computed form the time startTime and back timeIntervalUs microseconds at most.
 * If startTime is 0 the start time is the current time.
 * If monitoring data is not available up to timeIntervalUs, the monitoring is computed on less time
 * and the real interval is output to monitoringData->timeInterval.
 * Pointers to monitoring parameters that are not required can be left NULL.
 *
 * @param[in] sender The sender instance
 * @param[in] startTime Monitoring start time in microseconds (0 means current time)
 * @param[in] timeIntervalUs Monitoring time interval (back from startTime) in microseconds
 * @param[out] monitoringData Pointer to a monitoring data structure to fill
 *
 * @return ARSTREAM2_OK if no error occured.
 * @return ARSTREAM2_ERROR_BAD_PARAMETERS if the sender is invalid or if timeIntervalUs is 0.
 */
eARSTREAM2_ERROR ARSTREAM2_StreamSender_GetMonitoring(ARSTREAM2_StreamSender_Handle streamSenderHandle,
                                                      uint64_t startTime, uint32_t timeIntervalUs,
                                                      ARSTREAM2_StreamSender_MonitoringData_t *monitoringData);


#ifdef __cplusplus
}
#endif /* #ifdef __cplusplus */

#endif /* _ARSTREAM2_STREAM_SENDER_H_ */
