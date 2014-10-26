class ApisController < ApplicationController
  def trip_infomations_post
  	user_no = params[:user_no]

    url = AWS_API_ENDPOINT + TRIP_INFOMATIONS

    client = http_client(url)
    param = {user_no: user_no}

    response = client.post url, param
    parse_result = JSON.parse(response.body)

    render :json => parse_result
  end
end
