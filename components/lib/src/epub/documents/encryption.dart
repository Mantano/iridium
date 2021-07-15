// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:r2_shared_dart/container.dart';
import 'package:r2_shared_dart/publication.dart';
import 'package:xml/xml.dart';

import '../constants.dart';

class EncryptionParser {
  static Future<Map<String, Encryption>> parse(Container container) async {
    try {
      bool exists = await container.existsAt('META-INF/encryption.xml');
      if (!exists) {
        return {};
      }
      var stream = await container.streamAt('META-INF/encryption.xml');
      XmlDocument document = await stream.readXmlDocument();
      Iterable<Product2<String, Encryption>> result = document
          .findElements("EncryptedData", namespace: Namespaces.enc)
          .map((e) => parseEncryptedData(e));
      return {
        for (Product2<String, Encryption> e in result) (e).item1: (e).item2
      };
    } on Exception catch (e) {
      Fimber.d("Can't parse the encryption document", ex: e);
      return {};
    }
  }

  static Product2<String, Encryption> parseEncryptedData(XmlElement node) {
    String resourceURI = node
        .getElement("CipherData", namespace: Namespaces.enc)
        ?.getElement("CipherReference", namespace: Namespaces.enc)
        ?.getAttribute("URI");
    if (resourceURI == null) {
      return null;
    }
    String retrievalMethod = node
        .getElement("KeyInfo", namespace: Namespaces.sig)
        ?.getElement("RetrievalMethod", namespace: Namespaces.sig)
        ?.getAttribute("URI");
    String scheme = (retrievalMethod == "license.lcpl#/encryption/content_key")
        ? Drm.lcp.scheme
        : null;
    String algorithm = node
        .getElement("EncryptionMethod", namespace: Namespaces.enc)
        ?.getAttribute("Algorithm");
    if (algorithm == null) {
      return null;
    }
    XmlElement encryptionProperties =
        node.getElement("EncryptionProperties", namespace: Namespaces.enc);
    Product2<int, String> compression;
    if (encryptionProperties != null) {
      parseEncryptionProperties(encryptionProperties);
    }
    int originalLength = compression?.item1;
    String compressionMethod = compression?.item2;
    String profile;
    /* drm?.license?.encryptionProfile,
                FIXME: This has probably never worked. Profile needs to be filled somewhere, though. */
    Encryption enc = Encryption(
        algorithm: algorithm,
        compression: compressionMethod,
        originalLength: originalLength,
        profile: profile,
        scheme: scheme);
    String uri = Uri.tryParse(resourceURI)?.toString() ?? resourceURI;
    return Product2(uri, enc);
  }

  static Product2<int, String> parseEncryptionProperties(
      XmlElement encryptionProperties) {
    for (XmlElement encryptionProperty in encryptionProperties
        .findElements("EncryptionProperty", namespace: Namespaces.enc)) {
      XmlElement compressionElement = encryptionProperty
          .getElement("Compression", namespace: Namespaces.comp);
      if (compressionElement != null) {
        var result = parseCompressionElement(compressionElement);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  static Product2<int, String> parseCompressionElement(
      XmlElement compressionElement) {
    String originalLengthValue =
        compressionElement.getAttribute("OriginalLength");
    int originalLength = (originalLengthValue != null)
        ? int.tryParse(originalLengthValue)
        : null;
    if (originalLength == null) {
      return null;
    }
    String method = compressionElement.getAttribute("Method");
    if (method == null) {
      return null;
    }
    String compression = (method == "8") ? "deflate" : "none";
    return Product2(originalLength, compression);
  }
}
