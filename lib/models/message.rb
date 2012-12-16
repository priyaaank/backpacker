require 'mongoid'

class Message

  include Mongoid::Document

  field :text, :type => String
  field :retry_count, :type => Integer, :default => 0
  field :recieved_at, :type => DateTime
  field :visible, :type => Boolean, :default => true

end
