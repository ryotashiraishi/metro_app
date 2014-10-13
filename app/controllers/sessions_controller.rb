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

    redirect_to root_path, notice: 'Authentication is completed.'
  end

  def destory
  end
end
