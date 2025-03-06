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

@Test("test sha256") func testSha256() async throws {
    let accessKey = "ASIA5YMLYF2ZBKKPQBBI"
    let secretKey = "DDud7NGvw2eEONlXij/ck5aj+KEQmWVrNCcDHL9R"
    let sessionToken = "IQoJb3JpZ2luX2VjELr//////////wEaCWV1LXdlc3QtMyJHMEUCIQDMo00X9zj5inO5dzFqEG0eUqopqwtBjb3lD9tA/L9LDwIgdoVo1700Aup3y8WInUwgNUbzrzA97dy07OPU5IluXiIq0QUI8v//////////ARAAGgw5NDU3MjI3NjQ5NzgiDNJqsURdAenVGNAiEiqlBYzy9iRgJ6WKxxcaW/7o5JozNG1g72/XbTFGuA4X3M8Wyeo74FOKSyGS05B+N0BwHlPZCRdUj7hrGD07zrOoPQ9EryZ+awzBXZWxE6AI08icPd8aR7Osbi54MOO/dwUVws+4i4uUhMeyMesE6RI8/K01vrCxOTvDUp3+rZnxvnAWIoZMuvSA+8t6okuGKLjmk5bXb2nxI5/mVwWZq/y9HGXqUUHcYi95uau1rYdyzJQgSauKaTsrYh4vhUOqrJgeEmkG396ivJynHpUMBDbF3mwHANjv3IPpzy4BF5OJk3l3ov1gASpdBZO9CvfWqLDMcEFiTuFcXDwVzqJQrvRAn3B6x8FqFksxpBrZispS0mjip96EwGG/S/QCDmbHD9LX6oxnup5oCJleDZK4phWafQJ3rIfdEL53bszidf1OcAkzxSTrpHl9SFQaPrfFCoQacUj+kVg1nYG377MZDQOU0bLca6Xcp/DZN2YVRHi//G8bhwnYBz8r6ZAjLMpswZgb/vCWr1NvnwPakmtx1OpdqvEoxxj15RxdaJpHc/LL7P68MyB7Pn8kRLrHNQCejHHDIlzpcWTtg2uiBSoQ97qbHvsYub+vbNsvBlw81ccr6WIQqOFzf+ldsoc9sBRHz4VT/S7rjE+0LV5Id4uQnC57KgM6W9VCVSVIcuwKPohfff8y5yhGKa1MREwZZZN8zgVjKJOz0LvtPxaj+UiNeELfEGznJvx/b5iyX1g5LEAlegHEgrOscC33pFhy/B+yQ/IVuzRFvYhPKGRaHjK1hqPlVamSzSbm06yDJ8YAzqa4mUeNrD9EmMlEbj9JMJ1dFZ1yGfNwHGBLEXJf+wAMx/oWdUzvLvYK7x+LawVFrTA9PBtppvXR/XXv5ChqkVcUWwkvMIqc+0+QMJPsnL4GOt4CHoYISPMLCT7G1VqYvvXp9ktt+Ep/FF2gj8dy6lJYAdpNw3K0HChYbT1T60TaMAd2FRh2uRnXY7J/+RqCIBzgkxozdSKDnFTd/CKF3TV+c/+agoVTSQK7f8mOhoNDThWYU3g/ltRspVn5Lbpb5T5JbjrC0twagkNrLSJm7fHzpCvdBoJWeKh5aTs3l/qpLwKG6MOrgylkQcSVLjFMIZni75UOHFVdFRRKDQ6DhJNTUFQwhaF3h86zn4Di2cJthVxMefcfA/49LXL4HxnbpVCH8D3wQeskW2Rs905NFjPfceLtJ/1EvYyIpKkEaANwU+La+tso1iyLMt6Oe2X0tkReo5STLVY/fG+fPKFW7SMu6xteLXB0lB5EiDJ/zND8B4Khc2abVi5Cc9ACKV/9ktOEsRENvAOX1MN3PQh1/dhkN7ouU2KuKyq2eZF3YzpTFPocbIfqCeoLkfRtYnwbgzQ="
    
    let identityId = "eu-west-3:dc31782e-b253-c861-91a9-c7fbe3ed5a59"
    let region = "eu-west-3"
    let service = "execute-api"
    let url = URL(string: "https://2oeget5egh.execute-api.eu-west-3.amazonaws.com/Test/recommendation/")!
    
    let signer = AwsV4Signer(accessKey: accessKey, secretKey: secretKey, sessionToken: sessionToken, region: region, service: service, httpMethod: "GET", url: url, payload: "")
    let amzDate = "20250304T171915Z"
    let canReq = signer.canonicalRequest(amzDate: amzDate, hashedPayload:"") //"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    print(canReq)
    let response = signer.sha256(canReq)
    print("sha256 -> \(response)")
    #expect(response == "d2f441c8d0987f15ab3bd88e05b450d1e5e85c4670d60147a7cb5f74539b8dba")
}
