/*
    Copyright (C) 2014 Parrot SA

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the 
      distribution.
    * Neither the name of Parrot nor the names
      of its contributors may be used to endorse or promote products
      derived from this software without specific prior written
      permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
*/
/**
 * @file ARUTILS_Ftp.h
 * @brief libARUtils Ftp header file.
 * @date 19/12/2013
 * @author david.flattin.ext@parrot.com
 **/

#ifndef _ARUTILS_FTP_H_
#define _ARUTILS_FTP_H_

#include <inttypes.h>
#include <libARSAL/ARSAL_Sem.h>
#include "libARUtils/ARUTILS_Error.h"
//#include <libmux.h>

/**
 * @brief Ftp anonymous user name
 */
#define ARUTILS_FTP_ANONYMOUS        "anonymous"

/**
 * @brief Ftp max url string size
 */
#define ARUTILS_FTP_MAX_URL_SIZE      512

/**
 * @brief Ftp max file name path string size
 */
#define ARUTILS_FTP_MAX_PATH_SIZE     256

/**
 * @brief Ftp max list line string size
 */
#define ARUTILS_FTP_MAX_LIST_LINE_SIZE     512

/**
 * @brief Ftp Resume enum
 * @see ARUTILS_Ftp_Get
 */
typedef enum
{
    FTP_RESUME_FALSE = 0,
    FTP_RESUME_TRUE,

} eARUTILS_FTP_RESUME;

/**
 * @brief Progress callback of the Ftp download
 * @param arg The pointer of the user custom argument
 * @param percent The percent size of the media file already downloaded
 * @see ARUTILS_Ftp_Get ()
 */
typedef void (*ARUTILS_Ftp_ProgressCallback_t)(void* arg, float percent);

/**
 * @brief File list iterator function
 * @param list The file list
 * @param nextItem The the next file
 * @param prefix The file prefix to match
 * @param isDirectory The file type requested: 1 directory or 0 file
 * @param indexItem The beginning of the line item if address is not null
 * @param itemLen The length of the line item if address is not null
 * @param lineData The buffer that will receive the result
 * @param lineDataLen The size of the buffer that will receive the result
 * @retval On success, returns the file name of the found item, Otherwise, it returns null
 * @see ARUTILS_Ftp_List ()
 */
const char * ARUTILS_Ftp_List_GetNextItem(const char *list, const char **nextItem, const char *prefix, int isDirectory, const char **indexItem, int *itemLen, char *lineData, size_t lineDataLen);

/**
 * @brief File size accessor function from a file of a File list
 * @param line The line of the File list where to search file size
 * @param lineSize The size of the given line
 * @param size The addresse of the pointer to the file size to return
 * @retval On success, returns the addresse found size string, Otherwise, it returns null
 * @see ARUTILS_Ftp_List_GetNextItem ()
 */
const char * ARUTILS_Ftp_List_GetItemSize(const char *line, int lineSize, double *size);


#endif /* _ARUTILS_FTP_H_ */
