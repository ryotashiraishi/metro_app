# 定数定義
## 東京メトロAPI用
API_ENDPOINT = 'https://api.tokyometroapp.jp/api/v2/'
DATAPOINTS_URL = API_ENDPOINT + 'datapoints'
ACCESS_TOKEN = ENV['TOKYO_METRO_TOKEN']

## AWS API用
AWS_API_ENDPOINT = 'http://ec2-54-187-171-156.us-west-2.compute.amazonaws.com/metro/api/v1/'
### 旅情報関連
TRIP_INFOMATIONS = 'trip/infomations'
### 旅履歴関連
TRIP_HISTORIES = 'trip/histories'
### 旅写真関連
TRIP_PHOTOS = 'trip/photos'

### ユーザー情報関連
USER_INFOMATIONS = 'user/infomations'

### ミッション情報関連
MISSION_INFOMATIONS = 'mission/infomations'

### 目的地情報関連
TARGET_PLACE_INFOMATIONS = 'target-place/infomations'

# 始発駅番号
FIRST_TRAIN_NO = 1

# 終着駅番号
LAST_TRAIN_NO = 10

## ステータス関連
PROGRESS = "1"
CANCEL = "3"
