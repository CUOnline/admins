# encoding: UTF-8
require 'bundler/setup'
require 'wolf'
require './admin_app'

map('/auth') { run Wolf::Auth }
map('/')     { run AdminApp }
