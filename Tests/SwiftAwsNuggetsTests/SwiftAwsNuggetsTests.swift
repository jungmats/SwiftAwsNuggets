import Testing
import Foundation
@testable import SwiftAwsNuggets

@Test("test if testing works") func testTest()  {
    #expect(true)
}

@Test("get credentials") func testGetCredentials() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let aws = AwsAccessor()
    let cred = try await aws.getCredentialsForIdentity()
    print(cred)
    #expect(cred.isEmpty() == false)
    #expect(cred.accessKeyId != nil && cred.accessKeyId!.isEmpty == false)
    #expect(cred.secretAccessKey != nil && cred.secretAccessKey!.isEmpty == false)
    #expect(cred.sessionToken != nil && cred.sessionToken!.isEmpty == false)
}

@Test("call lambda") func testCallLambda() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let aws = AwsAccessor(httpMethod: "POST", parameters: ["param1": 1, "param2": 2, "from": "swift"])
    let cred = try await aws.getCredentialsForIdentity()
    print("--- credentials retrieved")
    let response = await aws.callAPIGateway(accessKey: cred.accessKeyId!, secretKey: cred.secretAccessKey!, sessionToken: cred.sessionToken!)
    print("full response: \(response)")
    print("response['body']: \(response["body"])")
    //#expect(response["body"]["message"] as? String == "Hello from Lambda!")
    #expect((response["body"] as? [String: Any])?["message"] as? String == "Hello from Lambda in Python!")
}

@Test("json string generation") func testGenerateJsonParam() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let params: [String: Any] = ["param1": "value1", "param2": 42]
    print (params)
    let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
    let jsonString = String(data: jsonData, encoding: .utf8)
    print(jsonString!)
    #expect(true)
}

