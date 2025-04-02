//
//  AwsIdentityCreator.swift
//  SwiftAwsNuggets
//
//  Created by Matthias Jung on 02/04/2025.
//

//This class

import Foundation
import AWSClientRuntime
import AWSCognitoIdentity

public struct AwsIdentityHelper {
    
    static public func createCognitoIdentity(identityPoolId: String, region: String) async throws -> String {
        do {
            // Initialize the Cognito Identity client
            let client = try CognitoIdentityClient(region: region)
            
            // Create request input
            let input = GetIdInput(identityPoolId: identityPoolId)
            
            // Call AWS API using async/await
            let response = try await client.getId(input: input)
            
            // Extract, set and return the identity ID
            if let identityId = response.identityId {
                print("Created Identity ID: \(identityId)")
                return identityId
            } else {
                throw NSError(domain: "AwsAccessor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create identity. No identity ID returned."])
            }
        } catch {
            print("Error creating Cognito identity: \(error)")
            throw error
        }
    }

}
