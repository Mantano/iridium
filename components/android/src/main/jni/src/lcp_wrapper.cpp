#include "util.hpp"
#include <iostream>
#include <string>
#include "lcp_wrapper.h"
#include "DRMContext.h"
#include "DRMError.h"
#include "DRMService.h"

using namespace lcp;

struct DrmContextStruct lcpWrapperCreateContext(char* jsonLicense,
                                                char* hashedPassphrase,
                                                char* pemCrl) {
    auto drmService = DRMService();
    DRMContext *drmContext;
    struct DrmContextStruct drmContextStruct;
    drmContextStruct.hashedPassphrase = "";
    drmContextStruct.encryptedContentKey = "";
    drmContextStruct.token = "";
    drmContextStruct.profile = "";
    drmContextStruct.errorCode = 0;

    try {
        auto error = drmService.createContext(
                jsonLicense,
                hashedPassphrase,
                pemCrl,
                drmContext
        );

        //LOGD("lcpWrapperCreateContext, hashedPassphrase: %s", drmContext->hashedPassphrase.c_str());
        //LOGD("lcpWrapperCreateContext, encryptedContentKey: %s", drmContext->encryptedContentKey.c_str());
        drmContextStruct.hashedPassphrase = strdup(drmContext->hashedPassphrase.c_str());
        drmContextStruct.encryptedContentKey = strdup(drmContext->encryptedContentKey.c_str());
        if (drmContext->token.length() > 0) {
            //LOGD("lcpWrapperCreateContext, token: %s", drmContext->token.c_str());
            drmContextStruct.token = strdup(drmContext->token.c_str());
        }
        drmContextStruct.errorCode = (int) error.getCode();
    } catch (const std::exception& ex) {
         // Unknown error
         drmContextStruct.errorCode = 500;
    }
    //LOGD("lcpWrapperCreateContext, errorCode: %d", drmContextStruct.errorCode);
    return drmContextStruct;
}

char *lcpWrapperFindOneValidPassphrase(char * cJsonLicense,
                                       int64_t listPtrAddr) {
    StrList *hashedPassphrases = (struct StrList *) listPtrAddr;

   std::vector<std::string> hashedPassphraseCollection;

    for(int i = 0; i != hashedPassphrases->size; i++) {
         hashedPassphraseCollection.push_back(std::string(hashedPassphrases->list[i]));
    }
    std::string jsonLicense(cJsonLicense);
    //LOGD("lcpWrapperFindOneValidPassphrase, jsonLicense: %s", jsonLicense.c_str());

    // Search for a passphrase that matches the user key check
    auto drmService = DRMService();
    std::string *foundHashedPassphrase;

    try {
        foundHashedPassphrase = drmService.findOneValidPassphrase(
                jsonLicense,
                hashedPassphraseCollection
        );
        //LOGD("lcpWrapperFindOneValidPassphrase, foundHashedPassphrase is null: %d", (foundHashedPassphrase == nullptr));
        if (foundHashedPassphrase != nullptr) {
            const char * foundHashedPassphrase_c_str = foundHashedPassphrase->c_str();
            //LOGD("lcpWrapperFindOneValidPassphrase, result: %s", foundHashedPassphrase_c_str);
            return strdup(foundHashedPassphrase_c_str);
        }
    } catch (const std::exception& ex) {
        // Unknown error
    }
    return nullptr;
}

Uint8Array lcpWrapperNativeDecrypt(int64_t drmContextPtrAddr,
                                   int64_t encryptedDataPtrAddr) {
    DrmContextStruct *drmContextStruct = (struct DrmContextStruct *) drmContextPtrAddr;
    Uint8Array *encryptedDataStruct = (struct Uint8Array *) encryptedDataPtrAddr;

    std::string hashedPassphrase(drmContextStruct->hashedPassphrase);
    std::string encryptedContentKey(drmContextStruct->encryptedContentKey);
    std::string token(drmContextStruct->token);
    std::string profile(drmContextStruct->profile);
    // Get token
    auto drmContext = DRMContext(
            hashedPassphrase,
            encryptedContentKey,
            token,
            profile
    );

    int64_t encryptedDataSize = encryptedDataStruct->size;
    std::vector<uint8_t> encryptedData(encryptedDataSize);
    for (int i = 0; i < encryptedDataSize; i++) {
        encryptedData[i] = encryptedDataStruct->list[i];
    }

     // Decrypt data
    auto drmService = DRMService();
    std::vector<uint8_t> *decryptedData;
    struct Uint8Array decryptedDataStruct;
    int errorCode = 0;

    try {
        auto error = drmService.decrypt(
                drmContext,
                encryptedData,
                decryptedData
        );
        errorCode = (int) error.getCode();
        decryptedDataStruct.size = decryptedData->size();
        decryptedDataStruct.list = decryptedData->data();
    } catch (const std::exception& ex) {
        // Unknown error
        errorCode = 500;
    }
    decryptedDataStruct.errorCode = errorCode;
    // Free pointer
    delete decryptedData;

    return decryptedDataStruct;
}
