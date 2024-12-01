class V1::SleepRecordsController < ApplicationController
  include DryMatcherHandler

  def initialize
    super
    @user_fetch_sleep_record = Container["use_cases.user_fetch_sleep_record"]
    @user_clock_in = Container["use_cases.user_clock_in"]
    @user_clock_out = Container["use_cases.user_clock_out"]
  end

  def index
    result = @user_fetch_sleep_record.call(params.permit(:user_id, :sort_by, :sort_direction).to_h)
    handle_result(result) do |response|
      render json: {
        data: response,
        message: "Successfully fetched sleep records",
        status: "success"
      }, status: :ok
    end
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

  def clock_out
    result = @user_clock_out.call(params.require(:sleep_record).permit(:user_id).to_h)
    handle_result(result) do |response|
      render json: {
        data: response,
        message: "Successfully clocked out",
        status: "success"
      }, status: :created
    end
  end
end
