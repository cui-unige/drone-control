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
#ifndef _ARDISCOVERY_DISCOVERY_H_
#define _ARDISCOVERY_DISCOVERY_H_
#include <inttypes.h>

#define ARDISCOVERY_SERVICE_NET_DEVICE_DOMAIN   "local"
#define ARDISCOVERY_SERVICE_NET_DEVICE_FORMAT   "_arsdk-%04x._udp"
#define ARDISCOVERY_SERVICE_NET_RSSI_SIGNAL_KEY "rssi_signal"

/**
 * Enum characterizing every Parrot's product and categorizing them
 */
typedef enum
{
    ARDISCOVERY_PRODUCT_ARDRONE = 0,                                    ///< Bebop Drone product
    ARDISCOVERY_PRODUCT_JS,                                             ///< JUMPING SUMO product
    ARDISCOVERY_PRODUCT_SKYCONTROLLER,                                  ///< Sky controller product
    ARDISCOVERY_PRODUCT_JS_EVO_LIGHT,                                   ///< Jumping Sumo EVO Light product
    ARDISCOVERY_PRODUCT_JS_EVO_RACE,                                    ///< Jumping Sumo EVO Race product
    ARDISCOVERY_PRODUCT_BEBOP_2,                                        ///< Bebop drone 2.0 product
    ARDISCOVERY_PRODUCT_POWER_UP,                                       ///< Power up product
    ARDISCOVERY_PRODUCT_EVINRUDE,                                       ///< Evinrude product
    ARDISCOVERY_PRODUCT_UNKNOWNPRODUCT_4,                                          ///< Unknownproduct_4 product
    ARDISCOVERY_PRODUCT_SKYCONTROLLER_NG,                               ///< Sky controller product (2.0 & newer versions)
    ARDISCOVERY_PRODUCT_UNKNOWNPRODUCT_5,                                        ///< Unknownproduct_5 product
    ARDISCOVERY_PRODUCT_CHIMERA,                                        ///< Chimera product

    ARDISCOVERY_PRODUCT_MINIDRONE,                                      ///< DELOS product
    ARDISCOVERY_PRODUCT_MINIDRONE_EVO_LIGHT,                            ///< Delos EVO Light product
    ARDISCOVERY_PRODUCT_MINIDRONE_EVO_BRICK,                            ///< Delos EVO Brick product
    ARDISCOVERY_PRODUCT_MINIDRONE_EVO_HYDROFOIL,                        ///< Delos EVO Hydrofoil product
    ARDISCOVERY_PRODUCT_MINIDRONE_DELOS3,                               ///< Delos3 product
    ARDISCOVERY_PRODUCT_MINIDRONE_WINGX,                                ///< WingX product

    ARDISCOVERY_PRODUCT_SKYCONTROLLER_2,                                ///< Sky controller 2 product
    ARDISCOVERY_PRODUCT_SKYCONTROLLER_2P,                               ///< Sky controller 2P product

    ARDISCOVERY_PRODUCT_TINOS,                                          ///< Tinos product
    ARDISCOVERY_PRODUCT_SEQUOIA,                                        ///< Sequoia product
    ARDISCOVERY_PRODUCT_MAX                                             ///< Max of products
} eARDISCOVERY_PRODUCT;

typedef enum
{
    ARDISCOVERY_NETWORK_TYPE_UNKNOWN = 0, ///< unknown network
    ARDISCOVERY_NETWORK_TYPE_NET, ///< IP (e.g. wifi) network
    ARDISCOVERY_NETWORK_TYPE_BLE, ///< BLE network
    ARDISCOVERY_NETWORK_TYPE_USBMUX, ///< libmux over USB network
} eARDISCOVERY_NETWORK_TYPE;

/**
 * Enum characterizing every Parrot's product family
 */
typedef enum
{
    ARDISCOVERY_PRODUCT_FAMILY_ARDRONE,       ///< AR DRONE product family
    ARDISCOVERY_PRODUCT_FAMILY_JS,            ///< JUMPING SUMO product family
    ARDISCOVERY_PRODUCT_FAMILY_SKYCONTROLLER, ///< SKY CONTROLLER product family
    ARDISCOVERY_PRODUCT_FAMILY_MINIDRONE,     ///< DELOS product
    ARDISCOVERY_PRODUCT_FAMILY_POWER_UP,      ///< Power Up product family
    ARDISCOVERY_PRODUCT_FAMILY_FIXED_WING,    ///< Fixed wing product family
    ARDISCOVERY_PRODUCT_FAMILY_GAMEPAD,       ///< Gamepad product family
    ARDISCOVERY_PRODUCT_FAMILY_CAMERA,        ///< Camera product family
    ARDISCOVERY_PRODUCT_FAMILY_MAX            ///< Max of product familys
} eARDISCOVERY_PRODUCT_FAMILY;

/**
 * @brief Converts from product enumerator to product ID
 * This function is the only one knowing the correspondence
 * between the product enumerator and the products' IDs.
 * @param product The product's enumerator
 * @return The corresponding product ID
 */
uint16_t ARDISCOVERY_getProductID(eARDISCOVERY_PRODUCT product);

/**
 * @brief Converts from product enumerator to product name
 * This function is the only one knowing the correspondence
 * between the product enumerator and the products name.
 * @param product The product's enumerator
 * @return The corresponding product name
 */
const char* ARDISCOVERY_getProductName(eARDISCOVERY_PRODUCT product);

/**
 * @brief Converts from product enumerator to product path name
 * This function is the only one knowing the correspondence
 * between the product enumerator and the products path name.
 * @param product The product's enumerator
 * @param buffer The application buffer that will receive the product path name
 * @param length The length of the application buffer that will receive the product path name
 * @return The corresponding product path name
 */
void ARDISCOVERY_getProductPathName(eARDISCOVERY_PRODUCT product, char *buffer, int length);

/**
 * @brief Converts from product name to product enumerator
 * This function is the only one knowing the correspondence
 * between the products name and the product enumerator.
 * @param name The product's name
 * @return The corresponding product enumerator
 */
eARDISCOVERY_PRODUCT ARDISCOVERY_getProductFromName(const char *name);

/**
 * @brief Converts from product path name to product enumerator
 * This function is the only one knowing the correspondance
 * between the products name and the product enumerator.
 * @param name The product's name
 * @return The corresponding product enumerator
 */
eARDISCOVERY_PRODUCT ARDISCOVERY_getProductFromPathName(const char *name);

/**
 * @brief Converts from product ID to product enumerator
 * This function is the only one knowing the correspondence
 * between the products IDs and the product enumerator.
 * @param productID the productID of the product
 * @return The corresponding product enumerator
 */
eARDISCOVERY_PRODUCT ARDISCOVERY_getProductFromProductID(uint16_t productID);

/**
 * @brief Get family of product
 * This function is the only one knowing the correspondence between product
 * and family.
 * @param product The product's enumerator
 * @return The corresponding product family enumerator value
 */
eARDISCOVERY_PRODUCT_FAMILY ARDISCOVERY_getProductFamily(eARDISCOVERY_PRODUCT product);

#endif // _ARDISCOVERY_DISCOVERY_H_
