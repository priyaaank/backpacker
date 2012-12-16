require 'mongoid'

class Message

  include Mongoid::Document

  field :text, :type => String
  field :retry_count, :type => Integer, :default => 0
  field :recieved_at, :type => DateTime
  field :visible, :type => Boolean, :default => true

  embedded_in :message_queue

  VISIBILITY_TIMEOUT_IN_SECONDS = 300

  def delete
    message_queue.messages.where(:_id => self.id).destroy
  end

end
