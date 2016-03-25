# encoding: UTF-8
require './admin_app'

map('/auth') { run Wolf::Auth }
map('/')     { run AdminApp }
