#ifndef __LICENSE_CANONICALIZER_H__
#define __LICENSE_CANONICALIZER_H__

#include <string>
#include "License.h"

namespace lcp
{
    class LicenseCanonicalizer
    {
    public:
        /**
            Canonicalize json license

            @param string json data
            @return string Canonical version of json license
        */
        std::string canonicalize(const std::string& jsonLicense);
    };
}

#endif //__LICENSE_CANONICALIZER_H__
