class SessionsController < ApplicationController
  def index
  end

  def create
    # 認証情報を取得
  	auth = request.env['omniauth.auth']

    # セッションにユーザー情報を詰める
    session[:oauth_token] = ENV['FACEBOOK_APP_ID']
    session[:oauth_token_secret] = ENV['FACEBOOK_APP_SECRET']
    session[:oauth_access_token] = auth['credentials']['token']
    session[:uid] = auth['uid'].to_s
    session[:provider] = auth['provider']
    session[:name] = auth['info']['name']
    session[:first_name] = auth['info']['first_name']
    session[:last_name] = auth['info']['last_name']
    session[:image_url] = auth['info']['image']

    # AWSのDBに未登録のユーザーであれば登録する
    ## ユーザー情報の取得
    user = user_infomations_get(uid: session[:uid])
    ## ユーザーがnilの場合、ユーザー情報を登録する 
    user = user_infomations_post(session) if user.nil?

    # ユーザーNoをセッションに保持する
    session[:user_no] = user["user_no"]

    redirect_to missions_index_path
  end

  def failure
    redirect_to root_path
  end

  def destroy
    session[:oauth_token] = nil
    session[:oauth_token_secret] = nil
    session[:oauth_access_token] = nil
    session[:uid] = nil
    session[:provider] = nil
    session[:name] = nil
    session[:first_name] = nil
    session[:last_name] = nil
    session[:image_url] = nil
    session[:user_no] = nil

    redirect_to root_path
  end
end
