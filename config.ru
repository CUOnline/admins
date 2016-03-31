# encoding: UTF-8
require './admin_app'

map('/auth') { run WolfCore::Auth }
map('/')     { run AdminApp }
