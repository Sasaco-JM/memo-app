# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

# ルーティング
# ページ表示
get '/' do
  @title = 'Top'

  cmd = 'SEL_ALL'
  @memos = db_exec(cmd, params)

  erb :index
end

# 追加ボタン
get '/memos' do
  @title = 'new memo'
  erb :new
end

get '/memos/:id' do
  @title = 'show memo'

  cmd = 'SEL'
  @memo = db_exec(cmd, params)

  erb :detail
end

# 編集ボタン
get '/memos/:id/edit' do
  @title = 'edit memo'

  cmd = 'SEL'
  @memo = db_exec(cmd, params)
  erb :edit
end

# データ操作
# 保存ボタン
post '/memos' do
  cmd = 'INS'
  db_exec(cmd, params)

  redirect '/'
  erb :index
end

# 変更ボタン
patch '/memos/:id' do
  cmd = 'UPD'
  db_exec(cmd, params)

  redirect '/'
  erb :index
end

# 削除ボタン
delete '/memos/:id' do
  cmd = 'DEL'
  db_exec(cmd, params)

  redirect '/'
  erb :index
end

# メソッド

def db_exec(cmd, params)
  connection = PG.connect(host: 'localhost', user: 'sasaco', password: 'sasaco', dbname: 'memodb', port: '5432')

  begin
    case cmd
    when 'INS'
      connection.exec('INSERT INTO memos(title,content) VALUES( $1,$2);', [params[:title], params[:content]])
    when 'UPD'
      connection.exec('UPDATE memos SET title = $1,content = $2 WHERE id = $3;', [params[:title], params[:content], params[:id]])
    when 'DEL'
      connection.exec('DELETE FROM memos WHERE id = $1;', [params[:id]])
    when 'SEL'
      connection.exec('SELECT * FROM memos WHERE id = $1;', [params[:id]])
    when 'SEL_ALL'
      connection.exec('SELECT * FROM memos;')
    end
  ensure
    connection.finish
  end
end

helpers do
  include Rack::Utils
  alias_method :esc, :escape_html
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
