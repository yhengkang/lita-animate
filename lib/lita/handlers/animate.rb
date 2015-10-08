module Lita
  module Handlers
    class Animate < Handler
      URL = "https://ajax.googleapis.com/ajax/services/search/images"

      route(/(?:animate|gif|anim)(?:\s+me)? (.+)/i, :fetch, command: true, help: {
        "animate QUERY" => "animate everything"
      })

      def self.default_config(handler_config)
        handler_config.safe_search = :active
      end

      def fetch(response)
        query = response.matches[0][0]

        http_response = http.get(
          URL,
          v: "1.0",
          q: query + " animated",
          safe: safe_value,
          rsz: 8,
          as_filetype: "gif"
        )

        data = MultiJson.load(http_response.body)

        if data["responseStatus"] == 200
          choice = data["responseData"]["results"].sample
          response.reply "#{choice["unescapedUrl"]}"
        else
          reason = data["responseDetails"] || "unknown error"
          Lita.logger.warn(
            "Couldn't get image from Google: #{reason}"
          )
        end
      end

      private

      def safe_value
        safe = Lita.config.handlers.animate.safe_search || "active"
        safe = safe.to_s.downcase
        safe = "active" unless ["active", "moderate", "off"].include?(safe)
        safe
      end
    end

    Lita.register_handler(Animate)
  end
end
