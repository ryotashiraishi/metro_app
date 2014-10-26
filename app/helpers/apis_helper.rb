module ApisHelper
  # ユーザー情報取得API 
  def user_infomations_get(user_info)
    url = AWS_API_ENDPOINT + USER_INFOMATIONS

    key = user_info.keys.first.to_sym

    client = http_client(url)
    param = {key => user_info[key]}

    response = client.get url, param
    parse_result = JSON.parse(response.body).first
  end

  # ユーザー情報登録API 
  def user_infomations_post(user_info)
    url = AWS_API_ENDPOINT + USER_INFOMATIONS

    client = http_client(url)
    param = {
    	user_name: user_info[:name],
    	uid: user_info[:uid]
    }

    response = client.post url, param
    parse_result = JSON.parse(response.body)
  end
end
