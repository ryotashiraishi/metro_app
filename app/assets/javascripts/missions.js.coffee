# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->

  # TODO: ミッション中か判定処理が必要
  # ミッション中じゃない場合
  if $(location).attr('pathname') == "/missions/index"
    $('#before_start_app').css('display', '')
    $('#wrap').css('opacity', 0.25)
    $('#getting_start_app').click ->
      # 旅情報登録APIの追加処理
      $.ajax
        type: 'POST'
        url: '/apis/trip_infomations_post'
        dataType: 'json'
        data:
          user_no: '1111' 
        success: (data, status, xhr) ->
          $('#before_start_app').css('display', 'none')
          $('#wrap').css('opacity', 1)
        error: (xhr, status, error) -> 
          alert 'ネットワーク障害が発生している可能性があります。\nしばらく時間を置いて再度アクセスして下さい。'
          # デバッグ作業のため追加しているけど後で消します ↓
          $('#before_start_app').css('display', 'none')
          $('#wrap').css('opacity', 1)
          #####
        complete: (xhr, status) -> 

  # サイコロを振るボタンのイベント処理
  $('#dice_btn').click ->

    img = $('#dice_img');

    # 初期表示
    if img.hasClass('ready-dice')
      # サイコロ領域を表示する
      $('#dice_div').css('display', '')
      img.toggleClass('ready-dice');
      img.toggleClass('start-dice');
      $('#dice_btn').text('start the dice roll')
      return

    # ダイスロールスタート 
    if img.hasClass('start-dice') 
      dice_anime_gif = '/assets/dice/dice.gif';
      img.attr('src', dice_anime_gif)
      img.toggleClass('start-dice');
      img.toggleClass('stop-dice');
      $('#dice_btn').text('stop the dice')
      return

    # サイコロストップ 
    if img.hasClass('stop-dice') 
      dice_value = eval(Math.floor(Math.random() * 5) + 1)

      # ajaxで非同期に決定した駅のミッション一覧情報を取得する
      $.ajax
        type: 'GET'
        url: '/missions/mission_list_api'
        dataType: 'html'
        data: 
          'dice_no': dice_value
        success: (data, status, xhr) ->
          # 取得した情報で$('#dynamic_div')領域を更新する
          mission_div = $(data).find('#mission_data')
          $('#mission_data').remove()
          $('#mission_div').prepend(mission_div)
        error: (xhr, status, error) -> 
        complete: (xhr, status) -> 


      select_dice_img_path = "/assets/dice/" + "dice_" + dice_value + ".png"
      img.attr('src', select_dice_img_path)
      img.toggleClass('stop-dice')
      img.toggleClass('show-mission')
      $('#dice_btn').text('show the mission')
      return

    # ミッション一覧を表示 
    if img.hasClass('show-mission') 
      $('#mission_div').toggleClass('display-none-style')
      $('#dice_div').css('display', 'none')

  # ミッションをランダムに決定する処理 
  $('#random_btn').on 'click', -> 
    # 前回に選択していたミッションの色を戻す
    $('.select-mission').toggleClass('select-mission')

    # ミッションの一覧の数を取得
    total_mission = $('.mission-info')
    # ランダムでミッション一覧から番号を選ぶ
    mission_no = eval(Math.floor(Math.random() * total_mission.length) + 1)
    # ミッションを選んだエフェクトを付ける
    $(total_mission.get(mission_no - 1)).toggleClass('select-mission')

    # スマホでの表示用に時間を遅らせる
    setTimeout (->
      if confirm('このミッションで決定していいですか？')
        # ミッション進行中画面へ遷移する
        data = $(total_mission.get(mission_no - 1)).data()
        next_page = '/missions/show?' + 'station_no=' + data.stationNo + '&target_place_no=' + data.targetPlaceNo
        location.href = next_page
      else
        # ミッションを選択し直す
        $('.select-mission').toggleClass('select-mission')
      return
    ), "500"


# Turbolinksによるajaxページ遷移のため再度イベントを設定
$(document).ready(ready)
$(document).on('page:load', ready)