#ifndef __DRM_CONTEXT_H__
#define __DRM_CONTEXT_H__

#include <string>

namespace lcp
{
    class DRMContext {
    public:
        DRMContext(
            const std::string & hashedPassphrase,
            const std::string & encryptedContentKey,
            const std::string & token,
            const std::string & profile
        );

        /**
            Encrypted content key in hex

            This encrypted content key can be decode with user key
        **/
        std::string encryptedContentKey;


        /**
            Hashed passphrase in hex used to generate the user key
        **/
        std::string hashedPassphrase;

        /**
            Token that certifies the validity of this DRM context
        **/
        std::string token;
        std::string profile;
    };
}

#endif //__DRM_CONTEXT_H__
