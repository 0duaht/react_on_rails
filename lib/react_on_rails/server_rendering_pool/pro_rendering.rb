# frozen_string_literal: true

require "open-uri"
require "faraday"
require_relative "./ruby_embedded_java_script.rb"

NODE_SERVER = 'http://localhost:3000'.freeze

module ReactOnRails
  module ServerRenderingPool
    # rubocop:disable Metrics/ClassLength
    class ProRendering < RubyEmbeddedJavaScript
      # rubocop:enable Metrics/ClassLength
      class << self
        def create_js_context
          conn = Faraday.new(url: NODE_SERVER) do |builder|
            builder.request  :url_encoded
            builder.response :logger
            builder.adapter  :typhoeus
          end

          conn
        end

        def eval_js(js_code, _render_options)
          @js_context_pool.with do |js_context|
            response = js_context.post(
              '/render',
              { js_code: js_code }.to_json,
              "Content-Type" => "application/json"
            )
            response.body
          end
        end
      end
    end
  end
end
