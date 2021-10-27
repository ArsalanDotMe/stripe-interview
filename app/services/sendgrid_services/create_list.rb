module SendgridServices
  class CreateList < ApplicationService
    include SendgridVars

    def initialize(name)
      @name = name
      @client =
        HTTP.headers('Authorization' => "Bearer #{SENDGRID_API_KEY}",
                     'content-type' => 'application/json').accept(:json)
    end

    def call
      payload = {
        "name": @name
      }

      response =
        @client.post(API_BASE + "/marketing/lists", json: payload)
      body = JSON.parse(response.body)

      unless response.status.created?
        logger.error body
        return OpenStruct.new({
                                success?: false,
                                error: body["errors"]
                              })
      end

      OpenStruct.new({ success?: true, payload: OpenStruct.new({ id: body["id"] }) })
    end
  end
end
