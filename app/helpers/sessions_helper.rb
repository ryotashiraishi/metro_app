module SessionsHelper
  def current_user
    # セッションに情報がなければ取得しにいく
    user = {
      user_no: session[:user_no] || user_infomations_get(uid: session[:uid])["user_no"],
      uid: session[:uid]
    } 
  end
end
