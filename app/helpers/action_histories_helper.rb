# encoding: utf-8

module ActionHistoriesHelper

  # すべての旅情報を取得する
  def get_all_trip_info
    result = []

    # TODO: 旅情報取得APIを叩いてすべての旅情報を取得する
    trip1 = {
      user_no: "12345",
      trip_no: "1",
      created_at: "2014/10/10 10:00:00"
    }

    trip2 = {
      user_no: "12345",
      trip_no: "2",
      created_at: "2014/10/10 15:00:00"
    }

    trip3 = {
      user_no: "12345",
      trip_no: "3",
      created_at: "2014/10/13 12:00:00"
    }

    result << trip1
    result << trip2
    result << trip3

    result
  end

  # 履歴表示用にデータを整形する
  def get_trip_histories(user_no, trip_no)
    result = []

    # 旅履歴APIから情報を取得する(渋谷から浅草までの道のり)
    req = {
      user_no: user_no,
      trip_no: trip_no
    }
    # スタート駅(渋谷)の情報を追加する
    trip = trip_infomations_get(req).first
    trip = trip.symbolize_keys if !trip.nil?
    first_action = {
        station_name: get_station_name(FIRST_TRAIN_NO),
        created_at: trip[:created_at],
        title: "旅スタート!",
        status: ""
    }
    result << first_action

    current_trip_histories = trip_histories_get(req)
    current_trip_histories = current_trip_histories.reverse

    current_trip_histories.each do |history|
      history = history.symbolize_keys

      # mission_noからミッション情報を取得する
      mission = mission_infomations_get(history).first.symbolize_keys
      mission_title = mission[:target_place_info].symbolize_keys[:name]

      # 取得した情報を整形する
      action = {
        station_name: get_station_name(history[:station_no].to_i),
        created_at: history[:created_at],
        title: mission_title,
        status: status_map(history[:status]),
      }

      # 情報を詰める
      result << action
    end

    result
  end

  # ステータスの名称を保持するハッシュ
  def status_map(status)
    status_map = {
      "1" => "進行中",
      "2" => "完了",
      "3" => "取消"
    }
    status_map[status]
  end
end
