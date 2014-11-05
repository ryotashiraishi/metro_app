# encoding: utf-8
class ActionHistoriesController < ApplicationController
  before_action :set_current_user, only: [:index, :trip_histories_api]

  def index
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
      station_no: params[:station_no],
      target_place_no: params[:target_place_no],
      mission_no: params[:mission_no]
    }

    # 旅情報を取得する
    trips = trip_infomations_get(user_no: @user[:user_no])
    current_trip = current_trip(@user[:user_no])

    # 最新の旅履歴情報を取得し、表示用に整形する
    @recent_action_history = get_trip_histories(@user[:user_no], current_trip[:trip_no])

    # 旅情報を表示用に整形する
    @all_trip_info = []
    trips.each do |trip|
      @all_trip_info << trip.symbolize_keys
    end

    # アップロードした写真を取得する
    req = {
      user_no: @user[:user_no],
      trip_no: current_trip[:trip_no]
    }
    @upload_photos = []
    photo_list = trip_photos_get(req)
    photo_list.each do |photo|
      photo = photo.symbolize_keys
      # TODO: photo_contentを削除せず、get_image()メソッドでcontent部分を取得する?
      # send_dataはしない
      # photo.delete(:photo_content)
      @upload_photos << photo
    end

  end

  # 旅を取りやめる
  def destroy

    # 進行中の旅を完了にする
    ## 最新の旅情報を取得する
    trip = current_trip(params[:user_no])

    param = {
      user_no: trip[:user_no],
      trip_no: trip[:trip_no],
      status: 2
    }
    trip_infomations_put(param)

    # 進行中のミッションを完了にする
    ## 最新の旅履歴情報を取得する
    trip_history = current_trip_history(params[:user_no], trip[:trip_no])

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
    # パラメータを取得する
    @data = {
      trip_no: params[:trip_no]
    }

    # 旅履歴情報を取り出す
    @recent_action_history = get_trip_histories(@user[:user_no], @data[:trip_no])

    req = {
      user_no: @user[:user_no],
      trip_no: @data[:trip_no]
    }
    @upload_photos = []
    photo_list = trip_photos_get(req)
    photo_list.each do |photo|
      photo = photo.symbolize_keys
      # TODO: photo_contentを削除せず、get_image()メソッドでcontent部分を取得する?
      # send_dataはしない
      # photo.delete(:photo_content)
      @upload_photos << photo
    end
    render :partial => 'trip_histories_api'
  end

    private

    # ユーザー情報を取得する
    def set_current_user
      # ユーザー情報の取得
      @user = user_infomations_get(uid: session[:uid]).symbolize_keys
    end

end
