# encoding: utf-8

class ActionHistoriesController < ApplicationController
  def index
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
      station_no: params[:station_no],
      target_place_no: params[:target_place_no],
      mission_no: params[:mission_no]
    }

    # 旅情報取得APIからすべての旅情報を取得する
    # TODO: 取得時のソート順を更新日の新しい順にする
    @all_trip_info = get_all_trip_info

    # TODO: ユーザーNo, 旅Noから旅履歴情報を取り出す
    @recent_action_history = get_trip_histories(session[:uid], @all_trip_info.first[:trip_no])

  end

  def trip_histories_api
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
      trip_no: params[:trip_no]
    }

    # TODO: ユーザーNo, 旅Noから旅履歴情報を取り出す
    @recent_action_history = get_trip_histories(session[:uid], @data[:trip_no])

    # TODO: 疎通テストのため以下の処理を付加。あとで削除すること
    action = {
    	station_name: "駅名" + @data[:trip_no].to_s,
        created_at: "2014/10/10 09:00",
        title: "XXXで◯◯◯しよう",
        image_url: "mission/image_4_" + 1.to_s + ".jpg"
    }
    @recent_action_history << action
    ####

    render :partial => 'trip_histories_api'
  end

end
