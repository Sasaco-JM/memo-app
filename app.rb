# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

# include ERB::Util

# $json_path = './json/memo.json'
# $json_data = File.open($json_path) { |file| JSON.parse(file.read) }

# ルーティング
# ページ表示
get '/' do
  json_data = load_json

  @title = 'Top'
  @memos = json_data

  erb :index
end

# 追加ボタン
get '/memo' do
  @title = 'new memo'
  erb :new
end

get '/memo/:id' do
  @memo = get_memo(params[:id])
  @id = params[:id]
  @title = 'show memo'
  erb :detail
end

# 編集ボタン
get '/memo/edit/:id' do
  @memo = get_memo(params[:id])
  @id = params[:id]
  @title = 'edit memo'
  erb :edit
end

# データ操作
# 保存ボタン
post '/memo' do
  json_data = load_json
  json_data = {} if json_data.nil?
  id = calc_max_id

  new_memo = create_memo_hash(params)

  json_data[id] = new_memo
  File.open('./json/memo.json', 'w') { |file| JSON.dump(json_data, file) }

  redirect '/'
  erb :index
end

# 変更ボタン
patch '/memo/:id' do
  id = params[:id].to_s
  json_data = load_json
  new_memo = create_memo_hash(params)
  json_data[id] = new_memo

  File.open('./json/memo.json', 'w') { |file| JSON.dump(json_data, file) }

  redirect '/'
  erb :index
end

# 削除ボタン
delete '/memo/:id' do
  json_data = load_json
  json_data.delete(params[:id].to_s)

  File.open('./json/memo.json', 'w') { |file| JSON.dump(json_data, file) }

  redirect '/'
  erb :index
end

# メソッド
def calc_max_id
  id = 0
  json_data = load_json
  json_data.each { |k, _v| id = k.to_i if id <= k.to_i }
  (id += 1).to_s
end

def create_memo_hash(params)
  title = escape_params(params[:title])
  content = escape_params(params[:content])

  { title: title, content: content }
end

def get_memo(id)
  json_data = load_json
  json_data[id]
end

def load_json
  File.open('./json/memo.json') { |file| JSON.parse(file.read) }
end

def escape_params(text)
  Rack::Utils.escape_html(text)
end

# 問題点

# jsonファイルないのメモを一覧表示する際に、
# @memo[:title]でメモタイトルを表示しているが、["title"]じゃないと取得できない時がある。
# →今は常に["title"]で取得している

# 新規登録したデータなどだけ表示されなかったりする
# →更新後にjsonファイルを再読み込みする処理を追加したら表示できた。

# jsonファイルから特定のメモだけ読み出す方法
# →解決

# 問題：rubocopでグローバル変数を警告される。
