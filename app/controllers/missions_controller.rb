class MissionsController < ApplicationController
  def index
  	# TODO: 動的に駅情報を取得する
#    target_station = 'TokyoMetro.Ginza.Shibuya' 
    target_station = 'TokyoMetro.Ginza.Suehirocho' 

    @train_time = {}
    @train_time = acquire_train_time(target_station)

  end

  def show
  end

  def progress
  end
end
