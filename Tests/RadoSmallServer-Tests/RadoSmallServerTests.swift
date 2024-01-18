import XCTest
import NIOHTTP1
import NIO
@testable import RadoSmallServer

final class RadoSmallServerTests: XCTestCase {
    
    // Very basic integration test - Needs fixing, because it doesn't work.
    func testGetRequest() throws {
        let serverExpectation = XCTestExpectation(description: "Wait for testing our server")
        
        try RadoSmallServer(path: "/hello", method: .GET, type: .text) {
            serverExpectation.fulfill()
            return "OK".data(using: .utf8)!
        }.start()
                
        let taskExpectation = XCTestExpectation(description: "Wait for sending data task")
        let url = try XCTUnwrap(URL(string: "localhost:17443/hello"))
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        
            do {
                let response = try XCTUnwrap(response)
                let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
                
                XCTAssertEqual(httpResponse.statusCode, 200)
            } catch {
                XCTFail("Cannot unrwap response")
            }
           
            
            taskExpectation.fulfill()
        }.resume()
               
        wait(for: [serverExpectation], timeout: 5.0)
    }
}
