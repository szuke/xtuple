(function () {
  'use strict';
  var forge = require('node-forge');
  var fs = require('fs');
  forge.pki.rsa.generateKeyPair(2048, 65537, null, function (error, keypair) {
    if (error) {
      console.log(error);
      throw error;
    }
    fs.writeFile('public.pem', forge.pki.publicKeyToPem(keypair.publicKey), function (error) {
      if (error) {
        console.log(error);
      }
    });
    fs.writeFile('private.p12', new Buffer(new Buffer(
      forge.asn1.toDer(
        forge.pkcs12.toPkcs12Asn1(keypair.privateKey, null, 'notasecret')
      ).getBytes(),
      'binary'
    ), 'base64'), function (error) {
      if (error) {
        console.log(error);
      }
    });
  });
}());
