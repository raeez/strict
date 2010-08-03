require 'rubygems'
require 'hoe'
require 'lib/typestrict'

Hoe.new('Strict', Strict::VERSION) do |p|
  p.name = 'typestrict'
  p.author = 'Raeez Lorgat'
  p.description = 'Static typesystem for ruby'
  p.email = 'raeez@mit.edu'
  p.summary = 'Strict implements a static typesystem over dynamic ruby objects'
  p.url = 'http://www.raeez.com/strict'
end

desc "Release and publish documentation"
task :repubdoc => [:release, :publish_docs]
