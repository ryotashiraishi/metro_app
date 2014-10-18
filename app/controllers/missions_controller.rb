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
  end
end
