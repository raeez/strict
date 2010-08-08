require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'supertypes')

module Strict
  VERSION = '0.0.8'
  include Strict::Base
  include Strict::SuperTypes
end

include Strict
SuperTypes::register_default_supertypes!
