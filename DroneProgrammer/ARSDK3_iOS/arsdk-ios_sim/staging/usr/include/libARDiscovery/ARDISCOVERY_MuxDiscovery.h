/*
    Copyright (C) 2016 Parrot SA

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

#ifndef _ARDISCOVERY_MUX_DISCOVERY_H_
#define _ARDISCOVERY_MUX_DISCOVERY_H_

/* Forward declarations */
struct mux_ctx;
struct MuxDiscoveryCtx;
struct MuxConnectionCtx;

typedef void (*device_added_cb_t)(const char *name, uint32_t type, const char *id, void *userdata);
typedef void (*device_removed_cb_t)(const char *name, uint32_t type, const char *id, void *userdata);
typedef void (*device_conn_resp_cb_t)(uint32_t status, const char* json, void *userdata);
typedef void (*eof_cb_t)(void *userdata);

struct MuxDiscoveryCtx* ARDiscovery_MuxDiscovery_new(
	struct mux_ctx *muxctx,
	device_added_cb_t device_added_cb,
	device_removed_cb_t device_removed_cb,
	eof_cb_t eof_cb,
	void* userdata);

void ARDiscovery_MuxDiscovery_dispose(struct MuxDiscoveryCtx *ctx);

struct MuxConnectionCtx* ARDiscovery_MuxConnection_new(
	struct mux_ctx *muxctx,
	device_conn_resp_cb_t device_conn_resp_cb,
	void *userdata);

int ARDiscovery_MuxConnection_sendConnReq(struct MuxConnectionCtx* ctx,
		const char* controllerName, const char* controllerType,
		const char* deviceId, const char* json);

void ARDiscovery_MuxConnection_dispose(struct MuxConnectionCtx *ctx);


#endif /** _ARDISCOVERY_MUX_DISCOVERY_H_ */
