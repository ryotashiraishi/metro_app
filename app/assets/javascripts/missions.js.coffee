# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->

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
      select_dice_img_path = "/assets/dice/" + "dice_" + dice_value + ".png"
      img.attr('src', select_dice_img_path)
      img.toggleClass('stop-dice')
      img.toggleClass('ready-dice')
      $('#dice_btn').text('shake the dice')
      return
    

# Turbolinksによるajaxページ遷移のため再度イベントを設定
$(document).ready(ready)
$(document).on('page:load', ready)