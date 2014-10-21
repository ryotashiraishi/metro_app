class MissionsController < ApplicationController
  def index
  	# TODO: 動的に駅情報を取得する
    target_station = 'TokyoMetro.Ginza.Suehirocho' 

    @train_time = acquire_train_time(target_station)

    @station_name_array = acquire_station_name
    @station_name_hash = acquire_station_name_hash

  end

  def show
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
      station_no: params[:station_no],
      target_place_no: params[:target_place_no],
      mission_no: params[:mission_no]
    }

    # 柳岡APIに目的地情報をリクエストする
    @target_place_detail = get_target_place_info_detail(@data[:station_no], @data[:target_place_no])
  end

  def create
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
    	station_no: params[:station_no],
    	target_place_no: params[:target_place_no],
    	mission_no: params[:mission_no]
    }
 
    # TODO: 行動番号を登録する処理

    # ミッション進行中画面へリダイレクト
    respond_to do |format|
      format.html { 
      	redirect_to missions_progress_path(@data)
      }
    end
  end

  def destroy
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
    	station_no: params[:station_no],
    	mission_no: params[:mission_no]
    }

    # TODO: 進行中のミッションを取りやめる処理が必要
    # TODO: 行動履歴に情報を登録する

    # ミッション進行中画面へリダイレクト
    respond_to do |format|
      format.html { 
      	redirect_to missions_index_path(@data[:station_no])
      }
    end
  end

  def progress
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
    	station_no: params[:station_no],
    	target_place_no: params[:target_place_no],
    	mission_no: params[:mission_no]
    }

  	# TODO: 駅番号から駅名(key)に変換する処理
    target_station = 'TokyoMetro.Ginza.Suehirocho' 

    @train_time = acquire_train_time(target_station)

    @station_name_array = acquire_station_name
    @station_name_hash = acquire_station_name_hash

    # 柳岡APIに目的地情報をリクエストする
    @target_place_detail = get_target_place_info_detail(@data[:station_no], @data[:target_place_no])
  end

  def mission_list_api
    dice_no = params["dice_no"]

    # TODO: 現在の駅の位置にサイコロの目を加算する
    # TODO: 現在の駅の位置を取得する処理が必要
    current_station = "2"
    station_no = current_station.to_i + dice_no.to_i

    @json = get_mission_list(station_no.to_s)
  end
end
