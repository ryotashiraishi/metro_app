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

  def get_trip_histories(user_no, trip_no)

    result = []
    
    # TODO: trip_info(user_no,trip_no)を基に旅履歴APIから情報を取得する(渋谷から浅草までの道のり)
    trip_action_histories = ["a", "b", "c", "d", "e"]

    trip_action_histories.each_with_index do |action, index|
    # TODO: user_no,trip_no,indexを基に旅履歴APIから情報を取得する(一つの駅での行動履歴)

      trip = {
        user_no: "12345",
        trip_no: (index + 1).to_s,
        station_no: (index + 2).to_s,
        mission_no: (index + 1).to_s,
        do_no: "",
        created_at: "2014/10/10 09:30"
      }

      # TODO: station_noから駅情報を取得する

      # TODO: mission_noからミッション情報を取得する

      # TODO: 取得した情報を整形する
      action = {
        station_name: "駅名" + (index + 1).to_s,
        created_at: "2014/10/10 09:00",
        title: "XXXで◯◯◯しよう",
        image_url: "mission/image_4_" + (index + 1).to_s + ".jpg"
      }

      # 情報を詰める
      result << action
    end

    result
  end

end
