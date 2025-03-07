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
    let identityId = "eu-west-3:dc31782e-b253-c861-91a9-c7fbe3ed5a59"
    let region = "eu-west-3"
    let service = "execute-api"
    let url = URL(string: "https://2oeget5egh.execute-api.eu-west-3.amazonaws.com/Test/recommendation/")!
    var httpMethod = "GET"
    var parameters = [String: Any]()
    
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
    var accessKeyId: String?
    var secretAccessKey: String?
    var sessionToken: String?
    
    func asString() -> String {
        return "accessKeyId: \(self.accessKeyId ?? "<empty>") secretAccessKey: \(self.secretAccessKey ?? "<empty>") sessionToken: \(self.sessionToken ?? "<empty>")"
    }
    
    func isEmpty() -> Bool {
        return self.accessKeyId == nil && self.secretAccessKey == nil && self.sessionToken == nil
    }
}

