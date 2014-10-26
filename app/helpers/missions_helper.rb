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

    # TODO: 時刻の取り方をメソッドに切り出したい
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
    result = {}

    prefix = 'odpt.Station:TokyoMetro.Ginza.'

    result = {
        prefix + "Shibuya" => "渋谷",
        prefix + "OmoteSando" => "表参道",
        prefix + "Gaiemmae" => "外苑前",
        prefix + "AoyamaItchome" => "青山一丁目",
        prefix + "AkasakaMitsuke" => "赤坂見附",
        prefix + "TameikeSanno" => "溜池山王",
        prefix + "Toranomon" => "虎ノ門",
        prefix + "Shimbashi" => "新橋",
        prefix + "Ginza" => "銀座",
        prefix + "Kyobashi" => "京橋",
        prefix + "Nihombashi" => "日本橋",
        prefix + "Mitsukoshimae" => "三越前",
        prefix + "Kanda" => "神田",
        prefix + "Suehirocho" => "末広町",
        prefix + "UenoHirokoji" => "上野広小路",
        prefix + "Ueno" => "上野",
        prefix + "Inaricho" => "稲荷町",
        prefix + "Tawaramachi" => "田原町",
        prefix + "Asakusa" => "浅草"
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
	

  # 引数に駅と目的地番号を指定し、詳細情報を取得する
  def get_target_place_info_detail(station_no, target_place_no)
    url = ''

#    client = http_client(url)
#    # TODO: もしかしたらgetのあとにurlが必要かも
#    response = client.get '',
#                 {'station_no' => station_no,
#                  'target_place_no' => target_place_no}
#    parse_result = JSON.parse(response.body)

    # TODO: 柳岡APIと連携するまでテストデータを返す
    detail = {
    	station_no: station_no,
    	target_place_no: target_place_no,
    	name: "XXXで◯◯◯を食べよう",
    	address: "東京都品川区XXXXXXX",
    	tel: "0120-444-444",
    	business_hours: "平日: 10:00-20:00 土日祝日: 店休日",
    	map_url: "http://xxxxxxxxxxxxx",
    	station_exit: "どういった形で値を持とう？？",
    	image_url: "mission/image_4_1.jpg",
    	abustract: "創業何年XXXXXX的な？",
    	pr1: "XXXXX",
    	pr2: "XXXXX",
    	pr3: "XXXXX",
    	created_at: "2014-10-19 15:00:00",
    	updated_at: "2014-10-19 16:00:00",
    	deleted_at: ""
    }

    return detail
  end

  # 現在の駅を取得する
  def get_current_station
    # TODO: 旅履歴取得APIから最新の旅履歴を取得し,駅名を取得する

    station_no = 2
    target_station = get_station_key(station_no)
  end

  # 駅番号に対応する駅キーを返す
  def get_station_key(station_no)
    # 銀座線で固定
    prefix = 'TokyoMetro.Ginza.'

    # 駅のキーを初期化
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

    station_map[station_no]
  end
end
