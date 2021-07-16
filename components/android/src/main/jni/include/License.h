#ifndef __LICENSE_H__
#define __LICENSE_H__

#include <string>

namespace lcp
{
    class License {
        class UserKey {
        public:
            // The value of the License `id` field,
            // encrypted using the User Key
            // Encoded in base64
            std::string keyCheck;

            // Algorithm used to generate the User Key from the User Passphrase
            std::string algorithm;

            std::string textHint; // Text hint to retrieve user passphrase
        };

        class ContentKey {
        public:
            // The value of the encrypted content key
            std::string encryptedValue;

            // Algorithm used to generate the Content Key from the User Passphrase
            std::string algorithm;
        };

        class Encryption {
        public:
            Encryption():
            userKey(UserKey())
            {}
            std::string profile; // Profile of encryption
            ContentKey contentKey; // Content key info
            UserKey userKey; // User key info
        };

        class Signature {
        public:
            Signature() {}
            std::string algorithm; //Algorithm used to calculate the signature
            std::string certificate; // X509 Provider Certificate
            std::string value; // Value of signature
        };

        class Rights {
        public:
            Rights() {}
            std::string start; // Start date of license - ISO 8601
            std::string end; // End date of license - ISO 8601
        };


    public:
        License():
            encryption(Encryption()),
            signature(Signature()),
            rights(Rights())
        {}

        std::string jsonLicense;
        std::string id; // Unique identifier for the License
        std::string issued; // Date when the license was first issued - ISO 8601
        std::string updated; // Date when the license was last updated - ISO 8601
        std::string provider; // Unique identifier for the Provider
        Encryption encryption; // Encryption info
        Signature signature; // Signature info
        Rights rights; // Rights info
    };


}

#endif //__LICENSE_H__
