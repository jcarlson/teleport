# frozen_string_literal: true

require "thin"
require "rack"
require "prometheus/middleware/exporter"

module TAC
  SERVER = Rack::Builder.app do
    use Rack::Deflater
    use Prometheus::Middleware::Exporter
    run ->(_) { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
  end
end
