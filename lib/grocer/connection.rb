require 'grocer'
require 'grocer/ssl_connection'

module Grocer
  class Connection
    attr_reader :certificate, :passphrase, :gateway, :port, :retries

    def initialize(options = {})
      @certificate = options.fetch(:certificate) { nil }
      @passphrase = options.fetch(:passphrase) { nil }
      @gateway = options.fetch(:gateway) { fail NoGatewayError }
      @port = options.fetch(:port) { fail NoPortError }
    end

    def read(size = nil, buf = nil)
      with_connection do
        ssl.read(size, buf)
      end
    end

    ##
    # Before writing to the socket we use read_nonblock to check for incoming
    # data. The happy case is that there is no data, however, because of the
    # way read_nonblock works, it raises IO:WaitReadable. If we are rescuing
    # IO::WaitReadable we can safely write to the socket. Otherwise, we destroy
    # the connection and raise an error based on the data read from the socket.
    def write(content)
      with_connection do
        begin
          error = ssl.read_nonblock(8)
        rescue IO::WaitReadable
          ssl.write(content)
        else
          destroy_connection
          raise ErrorResponse.new(error)
        end
      end
    end

    def connect
      ssl.connect unless ssl.connected?
    end

    private

    def ssl
      @ssl_connection ||= build_connection
    end

    def build_connection
      Grocer::SSLConnection.new(certificate: certificate,
                                passphrase: passphrase,
                                gateway: gateway,
                                port: port)
    end

    def destroy_connection
      return unless @ssl_connection

      @ssl_connection.disconnect rescue nil
      @ssl_connection = nil
    end

    def with_connection
      begin
        connect
        yield
      rescue OpenSSL::SSL::SSLError => exception
        if exception.message =~ /certificate expired/i
          exception.extend(CertificateExpiredError)
        end
        raise exception
      end
    end
  end
end
