# encoding: utf-8

module MissionsHelper
  # 東京メトロAPI, 柳岡APIへリクエストするクライアント
  def http_client(url)
    client = Faraday.new(:url => url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    return client
  end

  # 上りと下りの時刻表を取得する
  def acquire_train_time(station)
    result = Hash.new

    now_time = Time.now.in_time_zone('Tokyo') 
    hour_minute = now_time.strftime("%H:%M") 
    day = now_time.strftime("%w")  # 0-6 日曜が0

    client = http_client(DATAPOINTS_URL)

    response = client.get DATAPOINTS_URL,
                 {'rdf:type' => 'odpt:StationTimetable',
                  'odpt:station' => 'odpt.Station:' + station,
                  'acl:consumerKey' => ACCESS_TOKEN} 
    parse_result = JSON.parse(response.body)

    days = "odpt:weekdays"
    
    # TODO: 平日と土日祝日の判定が必要
    # 平日: odpt:weekdays
    # 土日: odpt:saturdays
    # 祝日: odpt:holidays

    case day
    when "0", "6" then
      days = "odpt:saturdays"
    when "holidays" then
      days = "odpt:holidays"
    end

    if station == 'TokyoMetro.Ginza.Shibuya'
      # 0 渋谷方面
      up_time_array = []
      parse_result[0][days].each do |hash|
        time_table = hash["odpt:departureTime"]

        if hour_minute < time_table
          up_time_array << time_table
          break if up_time_array.size == 3
        end
      end

      down_time_array = []
      3.times do 
        down_time_array << '--:--'
      end
    elsif station == 'TokyoMetro.Ginza.Asakusa'
      # 1 浅草方面
      down_time_array = []
      parse_result[0][days].each do |hash|
        time_table = hash["odpt:departureTime"]

        if hour_minute < time_table
          down_time_array << time_table
          break if down_time_array.size == 3
        end
      end

      up_time_array = []
      3.times do 
        up_time_array << '--:--'
      end
    else
      # 0 渋谷方面
      up_time_array = []
      parse_result[0][days].each do |hash|
        time_table = hash["odpt:departureTime"]

        if hour_minute < time_table
          up_time_array << time_table
          break if up_time_array.size == 3
        end
      end
      # 1 浅草方面
      down_time_array = []
      parse_result[1][days].each do |hash|
        time_table = hash["odpt:departureTime"]

        if hour_minute < time_table
          down_time_array << time_table
          break if down_time_array.size == 3
        end
      end
    end

    result = {
      up: up_time_array,
      down: down_time_array
    }
  end

  # 駅名の一覧を取得
  def acquire_station_name
    client = http_client(DATAPOINTS_URL)

    target_railway = '銀座'
    response = client.get DATAPOINTS_URL,
                 {'rdf:type' => 'odpt:Railway',
                  'dc:title' => target_railway,
                  'acl:consumerKey' => ACCESS_TOKEN} 
    result = JSON.parse(response.body)[0]["odpt:stationOrder"]
  end

  # 駅名を保持するハッシュを生成する
  def acquire_station_name_hash
    prefix = 'odpt.Station:TokyoMetro.Ginza.'

    result = {
        prefix + "Shibuya" => { name: "渋谷", enable: true, no: '01' },
        prefix + "OmoteSando" => { name: "表参道", enable: true, no: '02' },
        prefix + "Gaiemmae" => { name: "外苑前", enable: false, no: '03' },
        prefix + "AoyamaItchome" => { name: "青山一丁目", enable: true, no: '04' },
        prefix + "AkasakaMitsuke" => { name: "赤坂見附", enable: false, no: '05' },
        prefix + "TameikeSanno" => { name: "溜池山王", enable: false, no: '06' },
        prefix + "Toranomon" => { name: "虎ノ門", enable: true, no: '07' },
        prefix + "Shimbashi" => { name: "新橋", enable: false, no: '08' },
        prefix + "Ginza" => { name: "銀座", enable: true, no: '09' },
        prefix + "Kyobashi" => { name: "京橋", enable: false, no: '10' },
        prefix + "Nihombashi" => { name: "日本橋", enable: true, no: '11' },
        prefix + "Mitsukoshimae" => { name: "三越前", enable: false, no: '12' },
        prefix + "Kanda" => { name: "神田", enable: false, no: '13' },
        prefix + "Suehirocho" => { name: "末広町", enable: true, no: '14' },
        prefix + "UenoHirokoji" => { name: "上野広小路", enable: true, no: '15' },
        prefix + "Ueno" => { name: "上野", enable: false, no: '16' },
        prefix + "Inaricho" => { name: "稲荷町", enable: true, no: '17' },
        prefix + "Tawaramachi" => { name: "田原町", enable: false, no: '18' },
        prefix + "Asakusa" => { name: "浅草", enable: true, no: '19' }
    }
  end

  # 引数に指定した駅のミッションの一覧を取得する
  def get_mission_list(station_no)

    parse_result = mission_infomations_get(station_no: station_no)

    result = []
    parse_result.each do | mission |
      # キーをシンボルに変換
      # TODO: 第二階層目以降は変換されない
      result << mission.symbolize_keys
    end

    result
  end

  # 現在の駅番号を取得する
  def current_station
    current_trip = current_trip(current_user[:user_no])

    if current_trip.present? && current_trip[:status] == PROGRESS
      req = {
        user_no: current_user[:user_no],
        trip_no: current_trip[:trip_no]
      }
      current_trip_histories = current_trip_history(current_user[:user_no], current_trip[:trip_no])
      station_no = (current_trip_histories[:station_no].to_i if !current_trip_histories.nil?) || FIRST_TRAIN_NO 
    else
      station_no = FIRST_TRAIN_NO 
    end
  end

  # 直前の駅番号を取得する
  def before_station
    current_trip = current_trip(current_user[:user_no])

    req = {
      user_no: current_user[:user_no],
      trip_no: current_trip[:trip_no]
    }
    # 旅履歴から2番目の履歴を取得する
    before_trip_history = trip_histories_get(req)[1]

    if before_trip_history.present? 
      station_no = before_trip_history.symbolize_keys[:station_no].to_i 
    else
      station_no = FIRST_TRAIN_NO 
    end
  end

  # 最新の旅情報を取得する
  def current_trip(user_no)
    current_trip = trip_infomations_get(user_no: user_no).first
    current_trip = current_trip.symbolize_keys if !current_trip.nil?
  end

  # 最新の旅履歴情報を取得する
  def current_trip_history(user_no, trip_no)
    req = {
      user_no: user_no,
      trip_no: trip_no
    }
    current_trip_histories = trip_histories_get(req).first
    current_trip_histories = current_trip_histories.symbolize_keys if !current_trip_histories.nil?
  end

  # 駅番号に対応する駅キーを返す
  def get_station_key(station_no)
    # 銀座線で固定
    prefix = 'TokyoMetro.Ginza.'

    # 駅のキーを初期化
    station_map = {
        1 => prefix + "Shibuya",
        2 => prefix + "OmoteSando",
        3 => prefix + "AoyamaItchome",
        4 => prefix + "Toranomon",
        5 => prefix + "Ginza",
        6 => prefix + "Nihombashi",
        7 => prefix + "Suehirocho",
        8 => prefix + "UenoHirokoji",
        9 => prefix + "Inaricho",
        10 => prefix + "Asakusa"
    }
=begin
    station_map = {
        1 => prefix + "Shibuya",
        2 => prefix + "OmoteSando",
        3 => prefix + "Gaiemmae",
        4 => prefix + "AoyamaItchome",
        5 => prefix + "AkasakaMitsuke",
        6 => prefix + "TameikeSanno",
        7 => prefix + "Toranomon",
        8 => prefix + "Shimbashi",
        9 => prefix + "Ginza",
        10 => prefix + "Kyobashi",
        11 => prefix + "Nihombashi",
        12 => prefix + "Mitsukoshimae",
        13 => prefix + "Kanda",
        14 => prefix + "Suehirocho",
        15 => prefix + "UenoHirokoji",
        16 => prefix + "Ueno",
        17 => prefix + "Inaricho",
        18 => prefix + "Tawaramachi",
        19 => prefix + "Asakusa"
    }
=end

    station_map[station_no.to_i]
  end

  # 駅番号に対応する駅名を返す
  def get_station_name(station_no)
    nameMap = {
        1 => "渋谷",
        2 => "表参道",
        3 => "青山一丁目",
        4 => "虎ノ門",
        5 => "銀座",
        6 => "日本橋",
        7 => "末広町",
        8 => "上野広小路",
        9 => "稲荷町",
        10 => "浅草"
    }
=begin
    nameMap = {
        1 => "渋谷",
        2 => "表参道",
        3 => "外苑前",
        4 => "青山一丁目",
        5 => "赤坂見附",
        6 => "溜池山王",
        7 => "虎ノ門",
        8 => "新橋",
        9 => "銀座",
        10 => "京橋",
        11 => "日本橋",
        12 => "三越前",
        13 => "神田",
        14 => "末広町",
        15 => "上野広小路",
        16 => "上野",
        17 => "稲荷町",
        18 => "田原町",
        19 => "浅草"
    }
=end
    nameMap[station_no]
  end
end
