# encoding: UTF-8
require 'wolf'
require './admins'

map('/auth') { run Wolf::Auth }
map('/')     { run Admins }
