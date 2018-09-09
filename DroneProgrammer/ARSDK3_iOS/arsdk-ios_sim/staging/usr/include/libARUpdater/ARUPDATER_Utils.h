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
//
//  ARUPDATER_Utils.h
//  ARUpdaterCLibProject
//
//  Created by Djavan Bertrand on 27/05/2014.
//
//

#ifndef _ARUPDATER_UTILS_H_
#define _ARUPDATER_UTILS_H_

#include <stdint.h>

typedef enum
{
	ARUPDATER_PLF_TYPE_ALPHA = 0,	/* alpha or unknown version */
	ARUPDATER_PLF_TYPE_BETA,	/* beta version */
	ARUPDATER_PLF_TYPE_RC,		/* release candidate version */
	ARUPDATER_PLF_TYPE_PROD,	/* production version */
} eARUPDATER_PLF_TYPE;

typedef struct {
	eARUPDATER_PLF_TYPE type;	/* version type */
	uint32_t ver;			/* version */
	uint32_t edit;			/* edition */
	uint32_t ext;			/* extension*/
	uint32_t patch;			/* patch level */
} ARUPDATER_PlfVersion;

/**
 * @brief read the version of a given plf file
 * @param[in] plfFilePath : file path of the plf file
 * @param[out] version : pointer on the version structure
 * @param[out] str : string pointer of version filled by function
 * @param[out] size : string buffer size
 * @return ARUPDATER_OK if operation went well, the description of the error otherwise
 */
eARUPDATER_ERROR ARUPDATER_Utils_ReadPlfVersion(const char *plfFilePath, ARUPDATER_PlfVersion *version);

/**
 * @brief convert PlfVersion to representative string
 * @param[in] v : plf version
 * @param[out] buf : pointer on the string
 * @param[in] size : string size
 * @return ARUPDATER_OK if operation went well, the description of the error otherwise
 */
eARUPDATER_ERROR ARUPDATER_Utils_PlfVersionToString(const ARUPDATER_PlfVersion *v, char *buf, size_t size);

/**
 * @brief read the version of a given plf file
 * @param[in] str : string plf version
 * @param[out] version : pointer on the version structure
 * @return ARUPDATER_OK if operation went well, the description of the error otherwise
 */
eARUPDATER_ERROR ARUPDATER_Utils_PlfVersionFromString(const char *str, ARUPDATER_PlfVersion *v);

/**
 * @brief Compare 2 plf versions
 * @param[in] v1 : plf version 1
 * @param[in] v2 : plf version 2
 * @return It returns an integer less than 0 if v1 is lower than v2, 0 if versions are equal,
 * greater than zero if ver1 is greater than v2
 */
int ARUPDATER_Utils_PlfVersionCompare(const ARUPDATER_PlfVersion *v1, const ARUPDATER_PlfVersion *v2);

/**
 * @brief Extract a U_UNIFXILE regular file from a PLF file
 *
 * Example: a U_UNIXFILE section (regular file) with path "data/foo/config.txt" should be extracted
 * by providing the last path component ("config.txt") as parameter @unixFileName.
 *
 * @param[in] plfFileName : PLF file path
 * @param[in] outFolder : Directory path in which the file will be extracted
 * @param[in] unixFileName : The name of the file we want to extract; also the name of the file written in outFolder
 * @return ARUPDATER_OK if operation went well, the description of the error otherwise
 */
eARUPDATER_ERROR ARUPDATER_Utils_ExtractUnixFileFromPlf(const char *plfFileName, const char *outFolder, const char *unixFileName);

#endif /* _ARUPDATER_UTILS_H_ */
