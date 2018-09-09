/*
  Copyright (C) 2015 Parrot SA

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
 * @file ARSTREAM_Filter.h
 * @brief Stream readerfilter pass
 * @date 11/27/2015
 * @author nicolas.brulez@parrot.com
 */

#ifndef _ARSTREAM_FILTER_H_
#define _ARSTREAM_FILTER_H_

/*
 * System Headers
 */
#include <inttypes.h>

/*
 * ARSDK Headers
 */

/*
 * Macros
 */

/*
 * Types
 */


/**
 * @brief ARStream filter interface.
 * Filters can be passed to ARStream Readers (to be applied on
 * received frames, before being passed to the application) or
 * ARStream Senders (to be applied before sending the frame on the
 * network)
 *
 * Members:
 * - uint8_t* getBuffer (void *context, int size)
 *   -> returns the address of a free buffer of at least size bytes
 * - int getOutputSize (void *context, int inputSize)
 *   -> returns the size of the output for an input of inputSize bytes
 * - int filterBuffer (void *context,
 *                     uint8_t *input, int inSize,
 *                     uint8_t *output, int outSize)
 *   -> filters the input buffer (filled by inSize bytes of data), and
 *      puts the result in output (max outSize bytes of data). returns
 *      the actual number of bytes written in output.
 * - void releaseBuffer(void *context, uint8_t *buffer)
 -   -> called by ARStream to release the buffer. this call means that
 *      ARStream will never access this buffer again, and that it is
 *      safe to dispose it (or to return it from a subsequent call to
 *      getBuffer)
 * - void *context
 *   -> Implementation private data, given as the first argument to all
 *      other functions.
 */
typedef struct {
    uint8_t* (*getBuffer)(void *context, int size);
    int (*getOutputSize)(void *context, int inputSize);
    int (*filterBuffer)(void *context,
                        uint8_t *input, int inSize,
                        uint8_t *output, int outSize);
    void (*releaseBuffer)(void *context, uint8_t *buffer);
    void *context;
} ARSTREAM_Filter_t;

/*
 * Functions declarations
 */


#endif /* _ARSTREAM_FILTER_H_ */
