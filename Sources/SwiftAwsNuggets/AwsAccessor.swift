//
//  AwsAccessor.swift
//  AwsExperimentation
//
//  Created by Matthias Jung on 04/03/2025.
//

import Foundation
import AWSClientRuntime
import AWSCognitoIdentity

public struct AwsAccessor {
    var identityId: String?
    var region: String
    var service: String
    var url: URL
    var httpMethod: String
    var parameters = [String: Any]()
    
    public init(identityId: String, region: String, service: String, url: String, httpMethod: String, parameters: [String: Any]) {
        self.identityId = identityId
        self.region = region
        self.service = service
        self.url = URL(string: url)!
        self.httpMethod = httpMethod
        self.parameters = parameters
    }
        
    public func getCredentialsForIdentity() async throws -> Credentials {
        do {
            // Initialize the Cognito Identity client
            let client = try CognitoIdentityClient(region: region)
            
            // Create request input
            let input = GetCredentialsForIdentityInput(identityId: identityId)
            
            // Call AWS API using async/await
            let response = try await client.getCredentialsForIdentity(input: input)
            
            // Extract credentials
            if let credentials = response.credentials {
                print("Access Key: \(credentials.accessKeyId ?? "N/A")")
                print("Secret Key: \(credentials.secretKey ?? "N/A")")
                print("Session Token: \(credentials.sessionToken ?? "N/A")")
                return Credentials(accessKeyId: credentials.accessKeyId, secretAccessKey: credentials.secretKey, sessionToken: credentials.sessionToken)
            } else {
                print("No credentials returned")
            }
        } catch {
            print("Error retrieving credentials: \(error)")
        }
        return Credentials()
    }
    
    public func callAPIGateway(accessKey: String, secretKey: String, sessionToken: String) async -> [String: Any] {
        
        var responseContent: [String: Any] = [:]
        
        var payload = ""
        if !parameters.isEmpty {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                payload = String(data: jsonData, encoding: .utf8)!
            } catch {
                print("Error serializing parameters: \(error)")
                payload = ""
            }
        }
        print("paramter string: "+payload)
        
        let signer = AwsV4Signer(
            accessKey: accessKey,
            secretKey: secretKey,
            sessionToken: sessionToken,
            region: self.region,
            service: self.service,
            httpMethod: self.httpMethod,
            url: self.url,
            payload: payload
        )
        
        let request = signer.signRequest()
        print(request)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                responseContent["statusCode"] = httpResponse.statusCode
                print("Response Code: \(httpResponse.statusCode)")
            }
            
            if let responseBody = String(data: data, encoding: .utf8) {
                responseContent["body"] = responseBody
                print("Response Body: \(responseBody)")
                if let bodyString = responseContent["body"] as? String,
                   let bodyData = bodyString.data(using: .utf8),
                   let body = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
                   let message = body["message"] as? String {
                    responseContent["body"] = body
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return responseContent
    }
}

public struct Credentials {
    public var accessKeyId: String?
    public var secretAccessKey: String?
    public var sessionToken: String?
    
    public func asString() -> String {
        return "accessKeyId: \(self.accessKeyId ?? "<empty>") secretAccessKey: \(self.secretAccessKey ?? "<empty>") sessionToken: \(self.sessionToken ?? "<empty>")"
    }
    
    public func isEmpty() -> Bool {
        return self.accessKeyId == nil && self.secretAccessKey == nil && self.sessionToken == nil
    }
}

enum AwsAccessorError: Error {
    case missingArgument(String)
}
