require 'rubygems'
require 'hoe'
require 'lib/typestrict'

Hoe.spec 'Strict' do
  self.name = 'typestrict'
  self.version = Strict::VERSION
  self.author = 'Raeez Lorgat'
  self.description = 'Static typesystem for ruby'
  self.email = 'raeez@mit.edu'
  self.summary = 'Strict implements a static typesystem over dynamic ruby objects'
  self.url = 'http://www.raeez.com/strict'
end

desc "Release and publish documentation"
task :repubdoc => [:release, :publish_docs]
