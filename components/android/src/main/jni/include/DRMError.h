#ifndef __DRM_ERROR_H__
#define __DRM_ERROR_H__

#include <string>

namespace lcp
{
    enum class DRMErrorCode {
        // No error
        NONE = 0,

        /**
            WARNING ERRORS > 10
        **/

        // License is out of date (check start and end date)
        LICENSE_OUT_OF_DATE = 11,

        /**
            CRITICAL ERRORS > 100
        **/

        // Certificate has been revoked in the CRL
        CERTIFICATE_REVOKED = 101,

        // Certificate has not been signed by CA
        CERTIFICATE_SIGNATURE_INVALID = 102,

        // License has been issued by an expired certificate
        LICENSE_SIGNATURE_DATE_INVALID = 111,

        // License signature does not match
        LICENSE_SIGNATURE_INVALID = 112,

        // The drm context is invalid
        CONTEXT_INVALID = 121,

        // Unable to decrypt encrypted content key from user key
        CONTENT_KEY_DECRYPT_ERROR = 131,

        // User key check invalid
        USER_KEY_CHECK_INVALID = 141,

        // Unable to decrypt encrypted content from content key
        CONTENT_DECRYPT_ERROR = 151
    };

    class DRMError {
    public:
        DRMError(DRMErrorCode code):
            m_code(code)
        {}

        DRMErrorCode getCode() { return m_code; }
    private:
        DRMErrorCode m_code;
    };
}

#endif //__DRM_ERROR_H__
