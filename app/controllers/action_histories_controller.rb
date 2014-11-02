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

  # 旅を取りやめる
  def destroy

    # 進行中の旅を完了にする
    ## 最新の旅情報を取得する
    trip = trip_infomations_get(user_no: params[:user_no]).first
    trip = trip.symbolize_keys if !trip.nil?
    param = {
      user_no: trip[:user_no],
      trip_no: trip[:trip_no],
      status: 2
    }
    trip_infomations_put(param)

    # 進行中のミッションを完了にする
    ## 最新の旅履歴情報を取得する
    trip_history = trip_histories_get(user_no: params[:user_no], trip_no: trip[:trip_no]).first
    trip_history = trip_history.symbolize_keys if !trip_history.nil?
    param = {
      user_no: trip_history[:user_no],
      trip_no: trip_history[:trip_no],
      station_no: trip_history[:station_no],
      mission_no: trip_history[:mission_no],
      do_no: trip_history[:do_no],
      status: 2
    }
    trip_histories_put(param)

    data = {
      user_no: params[:user_no],
      trip_no: params[:trip_no]
    }

    # ミッション進行中画面へリダイレクト
    respond_to do |format|
      format.html { 
        redirect_to action_histories_index_path(data)
      }
    end
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
