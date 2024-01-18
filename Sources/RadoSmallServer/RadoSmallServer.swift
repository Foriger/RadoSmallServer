import NIOHTTP1
import NIO
import Foundation

public struct RadoSmallServer {

    var path: String
    var method: HTTPMethod
    var type: HTTPResponseType
    var handler: () -> Data
    var host = "127.0.0.1"
    var port = 17443

    public init(path: String, method: HTTPMethod, type: HTTPResponseType, host: String = "127.0.0.1", port: Int = 17443, handler: @escaping () -> Data) {
        self.path = path
        self.method = method
        self.type = type
        self.handler = handler
        self.host = host
        self.port = port
    }
    
    public func start() throws {
        let loopGroup =
        MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        let reuseAddrOpt = ChannelOptions.socket(
            SocketOptionLevel(SOL_SOCKET),
            SO_REUSEADDR
        )

        let bootstrap = ServerBootstrap(group: loopGroup)
            .childChannelInitializer({ channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap { _ in
                    channel.pipeline.addHandler(
                        HTTPHandler(path: path, method: method, type: type, handler: handler)
                    )
                }
            })
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(reuseAddrOpt, value: 1)
            .childChannelOption(ChannelOptions.socket(
                IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(reuseAddrOpt, value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead,
                                value: 1)

        let serverChannel = try bootstrap.bind(host: host, port: port).wait()
        print("Server running on:", serverChannel.localAddress!)

        try serverChannel.closeFuture.wait()
    }
}
