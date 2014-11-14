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
        missions: [{
          mission_title: "旅スタート!",
          status: "",
          status_val: "",
          created_at: trip[:created_at]
          }]
    }
    result << first_action

    current_trip_histories = trip_histories_get(req)
    current_trip_histories = current_trip_histories.reverse

    # 駅ごとにミッションをまとめたハッシュ
    missions = {
      2 => [],
      3 => [],
      4 => [],
      5 => [],
      6 => [],
      7 => [],
      8 => [],
      9 => [],
      10 => []
    }

    # 到着した駅の番号を保持する配列
    arrived_stations = []

    current_trip_histories.each do |history|
      history = history.symbolize_keys
      mission = mission_infomations_get(history).first.symbolize_keys

      action_detail = {
        mission_title: mission[:mission_title],
        status: status_map(history[:status]),
        status_val: history[:status],
        created_at: history[:created_at]
      }
      missions[history[:station_no].to_i] << action_detail
      arrived_stations << history[:station_no].to_i
    end

    arrived_stations.uniq.each do |station_no|
      action = {
        station_name: get_station_name(station_no),
        missions: missions[station_no]
      }

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
