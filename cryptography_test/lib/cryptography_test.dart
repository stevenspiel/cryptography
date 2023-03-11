// Copyright 2023 Gohilla.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Test utilities for cryptographic algorithms.
///
/// Use [testCryptography] to test all algorithms.
///
/// See also:
///   * [testCipher]
///   * [testHashAlgorithm]
///   * [testKeyExchangeAlgorithm]
///   * [testSignatureAlgorithm]
///
/// ## Example
/// ```dart
/// import 'package:cryptography_test/cryptography_test.dart';
///
/// void main() {
///   Cryptography.instance = MyCryptography();
///   testCryptography();
/// }
/// ```
library cryptography_test;

import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:test/scaffolding.dart';

import 'algorithms/aes_cbc.dart';
import 'algorithms/aes_ctr.dart';
import 'algorithms/aes_gcm.dart';
import 'algorithms/blake2b.dart';
import 'algorithms/blake2s.dart';
import 'algorithms/chacha20.dart';
import 'algorithms/ecdsa.dart';
import 'algorithms/ed25519.dart';
import 'algorithms/hkdf.dart';
import 'algorithms/hmac.dart';
import 'algorithms/pbkdf2.dart';
import 'algorithms/rsa_pss.dart';
import 'algorithms/rsa_ssa_pkcs5v15.dart';
import 'algorithms/sha224.dart';
import 'algorithms/sha256.dart';
import 'algorithms/sha384.dart';
import 'algorithms/sha512.dart';
import 'algorithms/x25519.dart';
import 'algorithms/xchacha20.dart';
import 'cipher.dart';
import 'hash.dart';
import 'key_exchange.dart';
import 'signature.dart';

/// Converts a list of bytes to a hexadecimal string.
///
/// Example output:
/// ```text
/// 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff
/// 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff
/// ```
String hexFromBytes(Iterable<int> iterable) {
  final list = iterable.toList();
  final sb = StringBuffer();
  for (var i = 0; i < list.length; i++) {
    if (i > 0) {
      if (i % 16 == 0) {
        sb.write('\n');
      } else {
        sb.write(' ');
      }
    }
    sb.write(list[i].toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

/// Converts a hexadecimal string to a list of bytes.
///
/// Whitespace in the string is ignored.
List<int> hexToBytes(String input) {
  final s = input.replaceAll(' ', '').replaceAll(':', '').replaceAll('\n', '');
  if (s.length % 2 != 0) {
    throw ArgumentError.value(input);
  }
  final result = Uint8List(s.length ~/ 2);
  for (var i = 0; i < s.length; i += 2) {
    var value = int.tryParse(s.substring(i, i + 2), radix: 16);
    if (value == null) {
      throw ArgumentError.value(input, 'input');
    }
    result[i ~/ 2] = value;
  }
  return Uint8List.fromList(result);
}

/// Tests the current or the given [Cryptography].
void testCryptography({Cryptography? cryptography}) {
  if (cryptography != null) {
    group('$cryptography:', () {
      setUpAll(() {
        Cryptography.instance = cryptography;
      });
      testCryptography();
    });
    return;
  }

  // testEcdh();
  testEcdsa();

  // Hash algorithms
  testBlake2s();
  testBlake2b();
  testSha224();
  testSha256();
  testSha384();
  testSha512();

  // Ciphers
  testAesCbc();
  testAesCtr();
  testAesGcm();
  testChacha20();
  testXchacha20();

  // Key exchange algorithms
  // testEcdh();
  testX25519();

  // Signature algorithms
  testEcdsa();
  testEd25519();
  testRsaPss();
  testRsaSsaPkcs5v1();

  // Other
  testHmac();
  testHkdf();
  testPbkdf2();
}
