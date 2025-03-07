//
//  AwsV4Signer.swift
//  AwsExperimentation
//
//  Created by Matthias Jung on 04/03/2025.
//
import Foundation
import CryptoKit
import AWSClientRuntime

public struct AwsV4Signer {
    
    let signedHeaders = "host;x-amz-content-sha256;x-amz-date;x-amz-security-token"
    
    let accessKey: String
    let secretKey: String
    let sessionToken: String
    let region: String
    let service: String
    let httpMethod: String
    let url: URL
    let payload: String
    let time_now: Date = Date()
        
    public func signRequest() -> URLRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let amzDate = dateFormatter.string(from: time_now)
        
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStamp = dateFormatter.string(from: time_now)
        
        let hashedPayload = sha256(payload.isEmpty ? "" : payload)
        print("hashedPayload: \(hashedPayload)")
        
        //1.create canonical string
        let canonicalRequest = self.canonicalRequest(amzDate: amzDate, hashedPayload: hashedPayload)
        //2. hash the canonical string
        let hashedCanonicalRequest = sha256(canonicalRequest)
        print("Canonical Request:\n\(canonicalRequest)")
        print("hashed Canonical Request = \(hashedCanonicalRequest)")
        //3.create a string to sign
        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"
        let stringToSign = """
        AWS4-HMAC-SHA256
        \(amzDate)
        \(credentialScope)
        \(hashedCanonicalRequest)
        """
        //4.derive a signing key
        let signingKey = getSignatureKey(secretKey: secretKey, dateStamp: dateStamp, regionName: region, serviceName: service)
        //5.calculate the signature of the string-to-sign
        let signature = hmacSHA256(key: signingKey, data: stringToSign).map { String(format: "%02x", $0) }.joined()
        //6.build the authorization header including signature
        let authorizationHeader = "AWS4-HMAC-SHA256 Credential=\(accessKey)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
        
        //7.build the HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue(amzDate, forHTTPHeaderField: "x-amz-date")
        request.addValue(sessionToken, forHTTPHeaderField: "x-amz-security-token")
        request.addValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        //request.addValue("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", forHTTPHeaderField: "x-amz-content-sha256")
        request.addValue(hashedPayload, forHTTPHeaderField: "x-amz-content-sha256")
        request.httpBody = payload.data(using: .utf8)
        
        print("Canonical Request:\n'\(canonicalRequest)'")
        print("Canonical Request2:\n'\(canonicalRequest.replacingOccurrences(of: "\n", with: "\\n"))'")
        print("String to Sign:\n\(stringToSign)")
        print("String to Sign2:\n'\(stringToSign.replacingOccurrences(of: "\n", with: "\\n"))'")
        print("Signature: \(signature)")
        print("Authorization Header: \(authorizationHeader)")
        
        return request
    }

    func canonicalRequest(amzDate: String, hashedPayload: String) -> String {
        let canonicalURI = url.path.isEmpty ? "/" : url.path + "/"
        print("canonical URI \(canonicalURI)")
        let canonicalQueryString = url.query ?? ""

        let canonicalHeaders = "host:\(url.host!)\nx-amz-content-sha256:\(hashedPayload)\nx-amz-date:\(amzDate)\nx-amz-security-token:\(sessionToken)\n"
        
        let canonicalRequest = """
        \(httpMethod)
        \(canonicalURI)
        \(canonicalQueryString)
        \(canonicalHeaders)
        \(signedHeaders)
        \(hashedPayload)
        """
        return canonicalRequest
    }
    
    func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        let retValue = hashed.map { String(format: "%02x", $0) }.joined()
        print("sha256: \(retValue)")
        return retValue
    }
    
    func hmacSHA256(key: Data, data: String) -> Data {
        let keyHMAC = HMAC<SHA256>.authenticationCode(for: Data(data.utf8), using: SymmetricKey(data: key))
        return Data(keyHMAC)
    }
        
    func getSignatureKey(secretKey: String, dateStamp: String, regionName: String, serviceName: String) -> Data {
        let kSecret = "AWS4" + secretKey
        let kDate = hmacSHA256(key: Data(kSecret.utf8), data: dateStamp)
        let kRegion = hmacSHA256(key: kDate, data: regionName)
        let kService = hmacSHA256(key: kRegion, data: serviceName)
        let kSigning = hmacSHA256(key: kService, data: "aws4_request")
        return kSigning
    }
}
