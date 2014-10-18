class MissionsController < ApplicationController
  def index
  	# TODO: 動的に駅情報を取得する
    target_station = 'TokyoMetro.Ginza.Suehirocho' 

    @train_time = {}
    @train_time = acquire_train_time(target_station)

    @station_name_array = acquire_station_name
    @station_name_hash = acquire_station_name_hash

  end

  def show
  end

  def progress
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
