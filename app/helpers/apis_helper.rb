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

  # 旅情報取得API
  def trip_infomations_get(req)
    url = AWS_API_ENDPOINT + TRIP_INFOMATIONS

    client = http_client(url)
    param = {
    	user_no: req[:user_no],
    	trip_no: req[:trip_no]
    }

    response = client.get url, param
    parse_result = JSON.parse(response.body)
  end

  # 旅情報登録API
  def trip_infomations_post(req)
    url = AWS_API_ENDPOINT + TRIP_INFOMATIONS

    client = http_client(url)
    param = {
    	user_no: req[:user_no]
    }

    response = client.post url, param
    parse_result = JSON.parse(response.body)
  end

  # 旅履歴取得API
  def trip_histories_get(req)
    url = AWS_API_ENDPOINT + TRIP_HISTORIES

    client = http_client(url)
    param = {
    	user_no: req[:user_no],
    	mission_no: req[:mission_no],
    	do_no: req[:do_no]
    }

    response = client.get url, param
    parse_result = JSON.parse(response.body)
  end

  # 旅履歴登録API
  def trip_histories_post(req)
    url = AWS_API_ENDPOINT + TRIP_HISTORIES

    client = http_client(url)
    param = {
    	user_no: req[:user_no],
    	trip_no: req[:trip_no],
    	station_no: req[:station_no],
    	mission_no: req[:mission_no]
    }

    response = client.post url, param
    parse_result = JSON.parse(response.body)
  end

  # 旅履歴更新API
  def trip_histories_put(req)
    url = AWS_API_ENDPOINT + TRIP_HISTORIES

    client = http_client(url)
    param = {
    	user_no: req[:user_no],
    	trip_no: req[:trip_no],
    	station_no: req[:station_no],
    	mission_no: req[:mission_no],
    	do_no: req[:do_no],
    	status: req[:status]
    }

    response = client.put url, param
    parse_result = JSON.parse(response.body)
  end

  # ミッション情報取得API
  def mission_infomations_get(req)
    url = AWS_API_ENDPOINT + MISSION_INFOMATIONS

    client = http_client(url)
    param = {
    	station_no: req[:station_no],
        mission_no: req[:mission_no]
    }

    response = client.get url, param
    parse_result = JSON.parse(response.body)
  end
end
