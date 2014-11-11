class MissionsController < ApplicationController
  before_action :set_current_user, only: [:index, :progress, :destroy, :create, :complete, :upload, :mission_list_api]
  before_action :set_current_info, only: [:index, :progress]

  def index
    # 最新の旅情報を取得し、ステータス値を渡す
    current_trip = current_trip(@user[:user_no])
    @progress_trip = current_trip.symbolize_keys[:status] if !current_trip.nil?

    # 進行中のミッションがある場合は進行中画面へリダイレクトする
    ## 最新のミッション情報を取得する
    trip_history = current_trip_history(@user[:user_no], current_trip[:trip_no])

    if trip_history.present? && trip_history[:status].to_s == "1" 
      # 目的地情報を表示するため必要なパラメータを取得する
      @data = {
        station_no: trip_history[:station_no],
        mission_no: trip_history[:mission_no]
      }
      respond_to do |format|
        format.html { 
          redirect_to missions_progress_path(@data)
        }
      end
    end

    # 既に駅番号が決まっている場合はミッションの一覧を表示する
    if session[:station_no].present?
      # パラメータの駅番号のミッションの一覧を取得する
      @json = get_mission_list(session[:station_no].to_s)
      @next_station_info = { 
        station_no: session[:station_no],
        station_name: get_station_name(session[:station_no].to_i)
      }
    end
  end

  def show
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
      station_no: params[:station_no],
      mission_no: params[:mission_no]
    }

    # AWS APIにミッション(目的地)情報をリクエストする
    @mission_info = mission_infomations_get(@data).first.symbolize_keys
    @target_place_detail = @mission_info[:target_place_info].symbolize_keys

    # 一時的に駅番号を記録する
    session[:station_no] = @data[:station_no]
  end

  def create
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
    	station_no: params[:station_no],
    	target_place_no: params[:target_place_no],
    	mission_no: params[:mission_no]
    }

    # 旅履歴を登録する処理
    ## 最新の旅情報の取得
    trip = current_trip(@user[:user_no])
    ## リクエストパラメータの設定
    req = {
      user_no: @user[:user_no],
      trip_no: trip[:trip_no],
      station_no: @data[:station_no],
      mission_no: @data[:mission_no]
    }

    trip_histories_post(req)

    # 一時的に記録した駅番号を破棄する
    session[:station_no] = nil

    # ミッション進行中画面へリダイレクト
    respond_to do |format|
      format.html { 
      	redirect_to missions_progress_path(@data)
      }
    end
  end

  # ミッションを取りやめる
  def destroy
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
    	station_no: params[:station_no],
    	mission_no: params[:mission_no]
    }

    # 最新の旅情報を取得する
    current_trip = current_trip(@user[:user_no])

    # 最新の旅履歴を取得する
    current_trip_history = current_trip_history(@user[:user_no], current_trip[:trip_no])

    current_trip_history[:status] = "3"

    trip_histories_put(current_trip_history)

    # 一時的に駅番号を記録する
    session[:station_no] = @data[:station_no]

    # トップ画面へリダイレクト
    respond_to do |format|
      format.html { 
      	redirect_to missions_index_path(station_no: @data[:station_no])
      }
    end
  end

  def progress
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
    	station_no: params[:station_no],
    	mission_no: params[:mission_no]
    }

    # ミッション情報取得APIから目的地情報を取得する
    @mission_info = mission_infomations_get(@data).first.symbolize_keys
    @target_place_detail = @mission_info[:target_place_info].symbolize_keys

    current_trip = current_trip(@user[:user_no])

    req = {
      user_no: @user[:user_no],
      trip_no: current_trip[:trip_no]
    }
    this_trip_history = trip_histories_get(req)

    current_trip_history = this_trip_history.first.symbolize_keys
    @current_trip_info = {
      user_no: @user[:user_no],
      trip_no: current_trip[:trip_no],
      do_no: current_trip_history[:do_no]
    }

    # 時刻表を設定する
    before_trip_history = this_trip_history[1]
    before_station_no = (before_trip_history.symbolize_keys[:station_no] if !before_trip_history.nil?) || FIRST_TRAIN_NO

    target_station_key = get_station_key(before_station_no.to_i)
    @train_time = acquire_train_time(target_station_key)
  end

  def complete
    # 目的地情報を表示するため必要なパラメータを取得する
    @data = {
    	station_no: params[:station_no],
    	target_place_no: params[:target_place_no],
    	mission_no: params[:mission_no]
    } 

    # 旅履歴を完了で更新する処理
    ## 最新の旅情報の取得
    trip = current_trip(@user[:user_no])
    ## 最新の旅履歴情報の取得
    param = {
      user_no: @user[:user_no],
      trip_no: trip[:trip_no]
    }

    trip_history = current_trip_history(@user[:user_no], trip[:trip_no])
    ## リクエストパラメータの設定
    req = {
      user_no: @user[:user_no],
      trip_no: trip[:trip_no],
      station_no: @data[:station_no],
      mission_no: @data[:mission_no],
      do_no: trip_history[:do_no],
      status: 2
    }
    trip_histories_put(req)

    # 浅草のミッションだったら旅も終了させて旅履歴画面にリダイレクト
    if @data[:station_no].to_i == LAST_TRAIN_NO
      req = {
        user_no: trip[:user_no],
        trip_no: trip[:trip_no],
        status: 2
      }
      trip_infomations_put(req)

      # セッション情報を初期化
      session[:station_no] = nil

      # 旅履歴画面へリダイレクト
      respond_to do |format|
        format.html { 
          redirect_to action_histories_index_path(param)
        }
      end
      return
    end

    # トップ画面へリダイレクト
    respond_to do |format|
      format.html { 
      	redirect_to missions_index_path(station_no: @data[:station_no])
      }
    end
  end

  def capture
    # バイナリデータ取得
    binary = params[:photo_content].read
    encoded_binary = CGI.escape(Base64.encode64(binary))

    @upload_photo = {
      photo_name: params[:photo_content].content_type,
      photo_content: encoded_binary
    }
    @data = {
      user_no: params[:user_no],
      trip_no: params[:trip_no],
      do_no: params[:do_no],
      station_no: params[:station_no],
      mission_no: params[:mission_no]
    }
  end

  def upload
    # TODO: ファイル名とファイルタイプを別にして保存すること
    # ファイル名を年月日時分秒
    # nowtime = Time.now
    #photo_name = nowtime.strftime("%Y%H%M%S")

    req = {
      user_no: params[:user_no],
      trip_no: params[:trip_no],
      do_no: params[:do_no],
      photo_name: params[:photo_name],
      photo_content: params[:photo_content]
    }
    trip_photos_post(req)

    data = {
      station_no: params[:station_no],
      mission_no: params[:mission_no]
    }

    # ミッション進行中画面へリダイレクト
    respond_to do |format|
      format.html { 
        redirect_to missions_progress_path(data)
      }
    end
  end

  def mission_list_api
    dice_no = params["dice_no"]

    # 現在の駅の位置にサイコロの目を加算する
    station_no = current_station + dice_no.to_i

    # 浅草駅を超えた数字になったら強制的に駅番号を9(終着)にする
    if station_no > LAST_TRAIN_NO
      station_no = LAST_TRAIN_NO 
    end

    @json = get_mission_list(station_no.to_s)
  end

  def trip_infomations_api
    user_no = params[:user_no]

    # 新規旅情報の取得
    new_trip = trip_infomations_post(user_no: user_no)

    render :json => new_trip
  end

    private

    # ユーザー情報を取得する
    def set_current_user
      # ユーザー情報の取得
      @user = user_infomations_get(uid: session[:uid]).symbolize_keys
    end

    # 現在の位置(駅)や進行中のミッション番号を設定する
    def set_current_info

      current_trip = current_trip(@user[:user_no])
      current_trip_history = current_trip_history(@user[:user_no], current_trip[:trip_no])

      if current_trip_history.present? && current_trip_history[:status].to_i == 1
        # ミッションが進行中の場合
        # 現在の駅番号を取得する
        @current_station_info = {
          station_no: before_station,
          station_name: get_station_name(before_station)
        }
        # 目的地の駅番号を取得する
        @next_station_info = {
          station_no: current_station,
          station_name: get_station_name(current_station)
        }
      else
        # ミッションが進行中以外の場合
        # 現在の駅番号を取得する
        @current_station_info = {
          station_no: current_station,
          station_name: get_station_name(current_station)
        }
        # 目的地の駅番号を取得する
        @next_station_info = nil
      end

      @station_name_array = acquire_station_name
      @station_name_hash = acquire_station_name_hash
    end
end
