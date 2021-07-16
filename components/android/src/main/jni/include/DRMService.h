#ifndef __DRM_SERVICE_H__
#define __DRM_SERVICE_H__

#include "DRMContext.h"
#include "DRMError.h"
#include "LicenseParser.h"
#include "LicenseCanonicalizer.h"

namespace lcp
{
    class DRMService {
    public:
        DRMService();

        /**
            Test all hashed passphrases againts license.encryption.user_key.key_check

            @param jsonLicense json string of license
            @param hashedPassphraseCollection List of hashed  passphrase
            @return HashedPassphrase that can decrypt key_check otherwise null
        **/
        std::string * findOneValidPassphrase(
            const std::string & jsonLicense,
            const std::vector<std::string> & hashedPassphraseCollection
        );

        /**
            Create DRM context

            @param jsonLicense json string of license
            @param hashedPassphrase Hashed representation of passphrase
            @param crl Content Revocation List in PEM format
            @param context Newly created DRM context if no error found
            @return DRMerror object
        **/
        DRMError createContext(
            const std::string & jsonLicense,
            const std::string & hashedPassphrase,
            const std::string & pemCrl,
            DRMContext *& drmContext
        );

        /**
            Decrypt data using DRM context

            @param context DRM context
            @param encryptedData Encrypted data
            @param decryptedData Decrypted data if no error found
            @return DRMerror object
        **/
        DRMError decrypt(
            const DRMContext & drmContext,
            const std::vector<uint8_t> & encryptedData,
            std::vector<uint8_t> *& decryptedData
        );

    private:
        LicenseParser m_licenseParser;
        LicenseCanonicalizer m_licenseCanonicalizer;
    };
}

#endif //__DRM_SERVICE_H__
