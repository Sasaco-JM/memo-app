# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'dotenv/load'

# ルーティング
# ページ表示
get '/' do
  @title = 'Top'
  @memos = select_all_memo
  @connection.finish

  erb :index
end

# 追加ボタン
get '/memos' do
  @title = 'new memo'

  erb :new
end

get '/memos/:id' do
  @title = 'show memo'
  @memo = select_memo(params)
  @connection.finish

  erb :detail
end

# 編集ボタン
get '/memos/:id/edit' do
  @title = 'edit memo'
  @memo = select_memo(params)
  @connection.finish

  erb :edit
end

# データ操作
# 保存ボタン
post '/memos' do
  insert_memo(params)
  @connection.finish

  redirect '/'
  erb :index
end

# 変更ボタン
patch '/memos/:id' do
  update_memo(params)
  @connection.finish

  redirect '/'
  erb :index
end

# 削除ボタン
delete '/memos/:id' do
  delete_memo(params)
  @connection.finish

  redirect '/'
  erb :index
end

# メソッド

def insert_memo(params)
  connection.exec('INSERT INTO memos(title,content) VALUES( $1,$2);', [params[:title], params[:content]])
end

def update_memo(params)
  connection.exec('UPDATE memos SET title = $1,content = $2 WHERE id = $3;', [params[:title], params[:content], params[:id]])
end

def delete_memo(params)
  connection.exec('DELETE FROM memos WHERE id = $1;', [params[:id]])
end

def select_memo(params)
  connection.exec('SELECT * FROM memos WHERE id = $1;', [params[:id]])
end

def select_all_memo
  connection.exec('SELECT * FROM memos;')
end

def connection
  @connection ||= PG.connect(host: ENV['DATABASE_HOST'], user: ENV['DATABASE_USER'], password: ENV['DATABASE_PASSWORD'], dbname: ENV['DATABASE_NAME'],
                             port: ENV['DATABASE_PORT'])
end

helpers do
  include Rack::Utils
  alias_method :esc, :escape_html
end
