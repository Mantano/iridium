#ifndef __LICENSE_PARSER_H__
#define __LICENSE_PARSER_H__

#include <string>

#include "json11.hpp"

#include "License.h"

namespace lcp
{
    class LicenseParser
    {
    public:
        /**
            Parse json license

            @param jsonLicense License serialized in json
            @return License License object
        */
        License parse(const std::string jsonLicense);

    private:
        /**
            Parse core
            Throws exception if not valid

            @param jsonObject jsonObject containing license
            @param license Deserialized License object
        **/
        void parseCore(const json11::Json jsonObject, License & license);

        /**
            Parse encryption
            Throws exception if not valid

            @param jsonObject jsonObject containing license/encryption
            @param license Deserialized License object
        **/
        void parseEncryption(const json11::Json jsonObject, License & license);

        /**
            Parse encryption.content_key
            Throws exception if not valid

            @param jsonObject jsonObject containing license/encryption/content_key
            @param license Deserialized License object
        **/
        void parseContentKey(const json11::Json jsonObject, License & license);

        /**
            Parse encryption.user_key
            Throws exception if not valid

            @param jsonObject jsonObject containing license/encryption/user_key
            @param license Deserialized License object
        **/
        void parseUserKey(const json11::Json jsonObject, License & license);

        /**
            Parse signature
            Throws exception if not valid

            @param jsonObject jsonObject containing license/signature
            @param license Deserialized License object
        **/
        void parseSignature(const json11::Json jsonObject, License & license);

        /**
            Parse rights
            Throws exception if not valid

            @param jsonObject jsonObject containing license/rights
            @param license Deserialized License object
        **/
        void parseRights(const json11::Json jsonObject, License & license);
    };
}

#endif //__LICENSE_PARSER_H__
