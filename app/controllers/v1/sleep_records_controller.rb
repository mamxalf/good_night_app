class V1::SleepRecordsController < ApplicationController
  include DryMatcherHandler

  def initialize
    super
    @user_clock_in = Container["use_cases.user_clock_in"]
  end

  def clock_in
    result = @user_clock_in.call(params.require(:sleep_record).permit(:user_id).to_h)
    handle_result(result) do |response|
      render json: {
        data: response,
        message: "Successfully clocked in",
        status: "success"
      }, status: :created
    end
  end
end
