/**
 * @file arstream2_h264_writer.h
 * @brief Parrot Streaming Library - H.264 Writer
 * @date 08/04/2015
 * @author aurelien.barre@parrot.com
 */

#ifndef _ARSTREAM2_H264_WRITER_H_
#define _ARSTREAM2_H264_WRITER_H_

#ifdef __cplusplus
extern "C" {
#endif /* #ifdef __cplusplus */

#include <inttypes.h>
#include <stdio.h>
#include <libARStream2/arstream2_error.h>


/**
 * @brief H.264 Writer instance handle.
 */
typedef void* ARSTREAM2_H264Writer_Handle;


/**
 * @brief H.264 Writer configuration for initialization.
 */
typedef struct
{
    int naluPrefix;                         /**< write a NAL unit start code before each NALU */

} ARSTREAM2_H264Writer_Config_t;


/**
 * @brief Picture timing SEI syntax elements.
 */
typedef struct
{
    unsigned int cpbRemovalDelay;           /**< cpb_removal_delay syntax element */
    unsigned int dpbOutputDelay;            /**< dpb_output_delay syntax element */
    unsigned int picStruct;                 /**< pic_struct syntax element */
    unsigned int ctType;                    /**< ct_type syntax element */
    unsigned int nuitFieldBasedFlag;        /**< nuit_field_based_flag syntax element */
    unsigned int countingType;              /**< counting_type syntax element */
    unsigned int fullTimestampFlag;         /**< full_timestamp_flag syntax element */
    unsigned int discontinuityFlag;         /**< discontinuity_flag syntax element */
    unsigned int cntDroppedFlag;            /**< cnt_dropped_flag syntax element */
    unsigned int nFrames;                   /**< n_frames syntax element */
    unsigned int secondsFlag;               /**< seconds_flag syntax element */
    unsigned int secondsValue;              /**< seconds_value syntax element */
    unsigned int minutesFlag;               /**< minutes_flag syntax element */
    unsigned int minutesValue;              /**< minutes_value syntax element */
    unsigned int hoursFlag;                 /**< hours_flag syntax element */
    unsigned int hoursValue;                /**< hours_value syntax element */
    int timeOffset;                         /**< time_offset syntax element */

} ARSTREAM2_H264Writer_PictureTimingSei_t;


/**
 * @brief Recovery point SEI syntax elements.
 */
typedef struct
{
    unsigned int recoveryFrameCnt;          /**< recovery_frame_cnt syntax element */
    unsigned int exactMatchFlag;            /**< exact_match_flag syntax element */
    unsigned int brokenLinkFlag;            /**< broken_link_flag syntax element */
    unsigned int changingSliceGroupIdc;     /**< changing_slice_group_idc syntax element */

} ARSTREAM2_H264Writer_RecoveryPointSei_t;


/**
 * @brief Initialize an H.264 writer instance.
 *
 * The library allocates the required resources. The user must call ARSTREAM2_H264Writer_Free() to free the resources.
 *
 * @param writerHandle Pointer to the handle used in future calls to the library.
 * @param config The instance configuration.
 *
 * @return ARSTREAM2_OK if no error occurred.
 * @return an eARSTREAM2_ERROR error code if an error occurred.
 */
eARSTREAM2_ERROR ARSTREAM2_H264Writer_Init(ARSTREAM2_H264Writer_Handle* writerHandle, ARSTREAM2_H264Writer_Config_t* config);


/**
 * @brief Free an H.264 writer instance.
 *
 * The library frees the allocated resources.
 *
 * @param writerHandle Instance handle.
 *
 * @return ARSTREAM2_OK if no error occurred.
 * @return an eARSTREAM2_ERROR error code if an error occurred.
 */
eARSTREAM2_ERROR ARSTREAM2_H264Writer_Free(ARSTREAM2_H264Writer_Handle writerHandle);


/**
 * @brief Sets the Writer SPS and PPS context.
 *
 * The function imports SPS and PPS context from an H.264 parser.
 *
 * @param[in] writerHandle Instance handle.
 * @param[in] spsContext SPS context to use (from an H.264 parser)
 * @param[in] ppsContext PPS context to use (from an H.264 parser)
 *
 * @return ARSTREAM2_OK if no error occurred.
 * @return an eARSTREAM2_ERROR error code if an error occurred.
 */
eARSTREAM2_ERROR ARSTREAM2_H264Writer_SetSpsPpsContext(ARSTREAM2_H264Writer_Handle writerHandle, const void *spsContext, const void *ppsContext);


/**
 * @brief Write a SEI NAL unit.
 *
 * The function writes a Supplemental Enhancement Information NAL unit.
 * If recoveryPoint is not NULL, a recovery point SEI message is generated.
 * If userDataUnregisteredCount is not null, one or more user data unregistered messages are generated.
 *
 * @param[in] writerHandle Instance handle.
 * @param[in] pictureTiming Optional picture timing syntax elements
 * @param[in] recoveryPoint Optional recovery point syntax elements
 * @param[in] userDataUnregisteredCount User data count
 * @param[in] pbUserDataUnregistered User data input buffer array
 * @param[in] userDataUnregisteredSize User data input buffer size array
 * @param[in] pbOutputBuf Bitstream output buffer
 * @param[in] outputBufSize Bitstream output buffer size
 * @param[out] outputSize Bitstream output size
 *
 * @return ARSTREAM2_OK if no error occurred.
 * @return an eARSTREAM2_ERROR error code if an error occurred.
 */
eARSTREAM2_ERROR ARSTREAM2_H264Writer_WriteSeiNalu(ARSTREAM2_H264Writer_Handle writerHandle, ARSTREAM2_H264Writer_PictureTimingSei_t *pictureTiming,
                                                   ARSTREAM2_H264Writer_RecoveryPointSei_t *recoveryPoint, unsigned int userDataUnregisteredCount,
                                                   const uint8_t *pbUserDataUnregistered[], unsigned int userDataUnregisteredSize[],
                                                   uint8_t *pbOutputBuf, unsigned int outputBufSize, unsigned int *outputSize);


/**
 * @brief Write a gray I-slice NAL unit.
 *
 * The function writes an entirely gray I-slice NAL unit.
 *
 * @param[in] writerHandle Instance handle.
 * @param[in] firstMbInSlice Slice first macroblock index
 * @param[in] sliceMbCount Slice macroblock count
 * @param[in] sliceContext Slice context to use (from an H.264 parser)
 * @param[in] pbOutputBuf Bitstream output buffer
 * @param[in] outputBufSize Bitstream output buffer size
 * @param[out] outputSize Bitstream output size
 *
 * @return ARSTREAM2_OK if no error occurred.
 * @return an eARSTREAM2_ERROR error code if an error occurred.
 */
eARSTREAM2_ERROR ARSTREAM2_H264Writer_WriteGrayISliceNalu(ARSTREAM2_H264Writer_Handle writerHandle, unsigned int firstMbInSlice, unsigned int sliceMbCount, void *sliceContext, uint8_t *pbOutputBuf, unsigned int outputBufSize, unsigned int *outputSize);


/**
 * @brief Write a skipped P-slice NAL unit.
 *
 * The function writes an entirely skipped P-slice NAL unit.
 *
 * @param[in] writerHandle Instance handle.
 * @param[in] firstMbInSlice Slice first macroblock index
 * @param[in] sliceMbCount Slice macroblock count
 * @param[in] sliceContext Slice context to use (from an H.264 parser)
 * @param[in] pbOutputBuf Bitstream output buffer
 * @param[in] outputBufSize Bitstream output buffer size
 * @param[out] outputSize Bitstream output size
 *
 * @return ARSTREAM2_OK if no error occurred.
 * @return an eARSTREAM2_ERROR error code if an error occurred.
 */
eARSTREAM2_ERROR ARSTREAM2_H264Writer_WriteSkippedPSliceNalu(ARSTREAM2_H264Writer_Handle writerHandle, unsigned int firstMbInSlice, unsigned int sliceMbCount, void *sliceContext, uint8_t *pbOutputBuf, unsigned int outputBufSize, unsigned int *outputSize);


/**
 * @brief Rewrite a non-ref P-slice NAL unit.
 *
 * The function rewrites a P-slice as a non reference P-slice NAL unit.
 *
 * @param[in] writerHandle Instance handle.
 * @param[in] sliceContext Slice context to use (from an H.264 parser)
 * @param[in] pbInputBuf Bitstream input buffer
 * @param[in] inputBufSize Bitstream input size
 * @param[in] pbOutputBuf Bitstream output buffer
 * @param[in] outputBufSize Bitstream output buffer size
 * @param[out] outputSize Bitstream output size
 *
 * @return ARSTREAM2_OK if no error occurred.
 * @return an eARSTREAM2_ERROR error code if an error occurred.
 */
eARSTREAM2_ERROR ARSTREAM2_H264Writer_RewriteNonRefPSliceNalu(ARSTREAM2_H264Writer_Handle writerHandle, void *sliceContext,
                                                              const uint8_t *pbInputBuf, unsigned int inputSize,
                                                              uint8_t *pbOutputBuf, unsigned int outputBufSize, unsigned int *outputSize);


#ifdef __cplusplus
}
#endif /* #ifdef __cplusplus */

#endif /* #ifndef _ARSTREAM2_H264_WRITER_H_ */
