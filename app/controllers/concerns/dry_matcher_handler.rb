require "dry/matcher/result_matcher"

module DryMatcherHandler
  extend ActiveSupport::Concern

  def handle_result(result, &block)
    Dry::Matcher::ResultMatcher.call(result) do |matcher|
      matcher.success do |response|
        if block_given?
          yield(response, matcher)
        else
          render json: { data: response, status: "success", message: "Success" }, status: :ok
        end
      end

      matcher.failure do |error|
        render json: { message: error, status: "error", data: nil }, status: determine_error_status(error)
      end
    end
  end

  private

  def determine_error_status(error)
    case error
    when String
      error.include?("not found") ? :not_found : :unprocessable_entity
    else
      :unprocessable_entity
    end
  end
end
