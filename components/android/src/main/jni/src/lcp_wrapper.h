#ifndef BOOKARI_FOR_FLUTTER_LCP_WRAPPER_H
#define BOOKARI_FOR_FLUTTER_LCP_WRAPPER_H

#include <string>
#include "DRMContext.h"

using namespace lcp;

#ifdef __cplusplus
extern "C" {
#endif

typedef struct StrList{
    char **list;
    int64_t size;
}StrList;

typedef struct Uint8Array{
    uint8_t *list;
    int64_t size;
    int errorCode;
}Uint8Array;

typedef struct DrmContextStruct{
    char *hashedPassphrase;
    char *encryptedContentKey;
    char *token;
    char *profile;
    int errorCode;
}DrmContextStruct;

struct DrmContextStruct  lcpWrapperCreateContext(char* jsonLicense,
                                                 char* hashedPassphrase,
                                                 char* pemCrl);

char *lcpWrapperFindOneValidPassphrase(char* jsonLicense,
                                       int64_t listPtrAddr);

Uint8Array lcpWrapperNativeDecrypt(int64_t drmContextPtrAddr,
                                   int64_t encryptedDataPtrAddr);

#ifdef __cplusplus
}
#endif

#endif //BOOKARI_FOR_FLUTTER_LCP_WRAPPER_H
