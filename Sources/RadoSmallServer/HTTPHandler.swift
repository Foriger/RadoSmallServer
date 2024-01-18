import NIO
import NIOHTTP1
import Foundation

public enum HTTPResponseType {
    case text
    case json
}

class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    var path: String
    var method: HTTPMethod
    var type: HTTPResponseType
    var handler: () -> Data

    init(path: String, method: HTTPMethod, type: HTTPResponseType, handler: @escaping () -> Data) {
        self.path = path
        self.method = method
        self.type = type
        self.handler = handler
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = self.unwrapInboundIn(data)

        guard case .head = part else {
            return
        }

        var returnError = true

        if case let .head(requestInfo) = part {
            if requestInfo.method == method && requestInfo.uri == path {
                returnError = false
            }
        }

        if returnError {
            let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .notFound, headers: HTTPHeaders())
            context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
            _ = context.writeAndFlush(self.wrapOutboundOut(.end(HTTPHeaders())))
        } else {
            let data = handler()

            var headers = HTTPHeaders()
            var contentType = ""
            switch type {
            case .text:
                contentType = "text/plain"
            case .json:
                contentType = "application/json"
            }

            headers.add(name: "Content-Type", value: contentType)
            headers.add(name: "Content-Length", value: "\(data.count)")

            let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
            context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)

            var buffer = context.channel.allocator.buffer(capacity: 0)
            switch type {
            case .text:
                if let responseString = String(data: data, encoding: .utf8) {
                    buffer.writeString(responseString)
                }
            case .json:
                buffer.writeBytes(data)
            }
            let body = HTTPServerResponsePart.body(.byteBuffer(buffer))
            context.write(self.wrapOutboundOut(body), promise: nil)
            _ = context.writeAndFlush(self.wrapOutboundOut(.end(headers)))
        }
    }
}
