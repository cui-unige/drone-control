/**
 * @file arstream2_stream_stats.h
 * @brief Parrot Streaming Library - Stream Stats
 * @date 10/17/2016
 * @author aurelien.barre@parrot.com
 */

#ifndef _ARSTREAM2_STREAM_STATS_H_
#define _ARSTREAM2_STREAM_STATS_H_

#ifdef __cplusplus
extern "C" {
#endif /* #ifdef __cplusplus */

#include <inttypes.h>
#include <libARStream2/arstream2_error.h>


/**
 * @brief Maximum number of NAL units importance levels
 */
#define ARSTREAM2_STREAM_SENDER_MAX_IMPORTANCE_LEVELS          (4)


/**
 * @brief Maximum number of NAL units priority levels
 */
#define ARSTREAM2_STREAM_SENDER_MAX_PRIORITY_LEVELS            (5)


/**
 * @brief Macroblock status.
 */
typedef enum
{
    ARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS_UNKNOWN = 0,        /**< The macroblock status is unknown */
    ARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS_VALID_ISLICE,       /**< The macroblock is valid and contained in an I-slice */
    ARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS_VALID_PSLICE,       /**< The macroblock is valid and contained in a P-slice */
    ARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS_MISSING_CONCEALED,  /**< The macroblock is missing and concealed */
    ARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS_MISSING,            /**< The macroblock is missing and not concealed */
    ARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS_ERROR_PROPAGATION,  /**< The macroblock is valid but within an error propagation */
    ARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS_MAX,

} eARSTREAM2_STREAM_STATS_MACROBLOCK_STATUS;


/**
 * @brief RTP stats data
 */
typedef struct
{
    int8_t rssi;                                    /**< RSSI (0 if unknown) */

    /* Sender stats */
    struct
    {
        uint64_t timestamp;                         /**< Sender stats timestamp (0 if unavailable) */
        uint32_t sentPacketCount;                   /**< Total sent packet counter */
        uint32_t droppedPacketCount;                /**< Total dropped packet counter (dropped on the sender side) */
        uint64_t sentByteIntegral;                  /**< Total sent bytes integral value */
        uint64_t sentByteIntegralSq;                /**< Total sent bytes squared integral value */
        uint64_t droppedByteIntegral;               /**< Total dropped bytes integral value (dropped on the sender side) */
        uint64_t droppedByteIntegralSq;             /**< Total dropped bytes squared integral value (dropped on the sender side) */
        uint64_t inputToSentTimeIntegral;           /**< Input to sent time integral value (microseconds) */
        uint64_t inputToSentTimeIntegralSq;         /**< Input to sent time squared integral value (microseconds^2) */
        uint64_t inputToDroppedTimeIntegral;        /**< Input to dropped time integral value (microseconds) */
        uint64_t inputToDroppedTimeIntegralSq;      /**< Input to dropped time squared integral value (microseconds^2) */

    } senderStats;

    /* Sender report (see RFC3550) */
    struct
    {
        uint64_t timestamp;                         /**< Sender report timestamp (0 if unavailable) */
        uint32_t lastInterval;                      /**< Time interval between the last two sender reports in microseconds */
        uint32_t intervalPacketCount;               /**< Sent packets count over the last sender report interval */
        uint32_t intervalByteCount;                 /**< Sent bytes count over the last sender report interval */

    } senderReport;

    /* Receiver report (see RFC3550) */
    struct
    {
        uint64_t timestamp;                         /**< Receiver report timestamp (0 if unavailable) */
        uint32_t roundTripDelay;                    /**< Round-trip delay in microseconds */
        uint32_t interarrivalJitter;                /**< Interarrival jitter in microseconds */
        uint32_t receiverLostCount;                 /**< Cumulated lost packets count on the receiver side */
        uint32_t receiverFractionLost;              /**< Fraction of packets lost on the receiver side since the last report */
        uint32_t receiverExtHighestSeqNum;          /**< Extended highest sequence number received */

    } receiverReport;

    /* Loss report (see RFC3611) */
    struct
    {
        uint64_t timestamp;                         /**< Loss report timestamp (0 if unavailable) */
        uint16_t startSeqNum;                       /**< Current report start RTP sequence number */
        uint16_t endSeqNum;                         /**< Current report last RTP sequence number */
        uint32_t *receivedFlag;                     /**< Loss report bit-field (big-endian, 1 bit per packet, total bit count is endSeqNum-startSeqNum+1) */

    } lossReport;

    /* De-jitter buffer metrics (see RFC7005) */
    struct
    {
        uint64_t timestamp;                         /**< De-jitter buffer metrics report timestamp (0 if unavailable) */
        uint32_t djbNominal;                        /**< De-jitter buffer nominal delay (microseconds) */
        uint32_t djbMax;                            /**< De-jitter buffer maximum delay (microseconds) */
        uint32_t djbHighWatermark;                  /**< Highest value of the de-jitter buffer nominal delay (microseconds) */
        uint32_t djbLowWatermark;                   /**< Lowest value of the de-jitter buffer nominal delay (microseconds) */

    } djbMetricsReport;

    /* Clock delta */
    struct
    {
        int64_t peerClockDelta;                     /**< Peer clock delta in microseconds */
        uint32_t roundTripDelay;                    /**< Round-trip delay in microseconds (from the clock delta computation) */
        uint32_t peer2meDelay;                      /**< Peer-to-me delay in microseconds (from the clock delta computation) */
        uint32_t me2peerDelay;                      /**< Me-to-peer delay in microseconds (from the clock delta computation) */

    } clockDelta;

} ARSTREAM2_StreamStats_RtpStats_t;


/**
 * @brief Video stats data
 */
typedef struct
{
    uint64_t timestamp;                             /**< Timestamp associated with the stats */
    int8_t rssi;                                    /**< RSSI */
    uint32_t totalFrameCount;                       /**< Total frame counter */
    uint32_t outputFrameCount;                      /**< Output frame counter */
    uint32_t erroredOutputFrameCount;               /**< Errored output frame counter (included in outputFrameCount) */
    uint32_t missedFrameCount;                      /**< Missed frame counter */
    uint32_t discardedFrameCount;                   /**< Discarded frame counter (included in missedFrameCount) */
    uint64_t timestampDeltaIntegral;                /**< Frame timestamp delta integral value */
    uint64_t timestampDeltaIntegralSq;              /**< Frame timestamp delta squared integral value */
    uint64_t timingErrorIntegral;                   /**< Frame timing error integral value */
    uint64_t timingErrorIntegralSq;                 /**< Frame timing error squared integral value */
    uint64_t estimatedLatencyIntegral;              /**< Frame estimated latency integral value */
    uint64_t estimatedLatencyIntegralSq;            /**< Frame estimated latency squared integral value */
    uint32_t erroredSecondCount;                    /**< Errored second counter */
    uint32_t mbStatusClassCount;                    /**< Number of macroblock status classes */
    uint32_t mbStatusZoneCount;                     /**< Number of picture zones (vertical divisions of the frame) */
    uint32_t *erroredSecondCountByZone;             /**< Errored second counters for each picture zone - erroredSecondCountByZone[mbStatusZoneCount] array */
    uint32_t *macroblockStatus;                     /**< Macroblock status counters for each picture zone - macroblockStatus[mbStatusClassCount][mbStatusZoneCount] array */

} ARSTREAM2_StreamStats_VideoStats_t;


#ifdef __cplusplus
}
#endif /* #ifdef __cplusplus */

#endif /* _ARSTREAM2_STREAM_STATS_H_ */
