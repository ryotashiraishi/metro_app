# 定数定義
## 東京メトロAPI用
API_ENDPOINT = 'https://api.tokyometroapp.jp/api/v2/'
DATAPOINTS_URL = API_ENDPOINT + 'datapoints'
ACCESS_TOKEN = ENV['TOKYO_METRO_TOKEN']

## AWS API用
AWS_API_ENDPOINT = 'http://ec2-54-187-171-156.us-west-2.compute.amazonaws.com/metro/api/v1/'
### 旅情報関連
TRIP_INFOMATIONS = 'trip/infomations'

### ユーザー情報関連
USER_INFOMATIONS = 'user/infomations'
