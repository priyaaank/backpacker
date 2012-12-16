require 'mongoid'

class MessageQueue
  
  include Mongoid::Document

  field :name, :type => String

  embeds_many :messages

  def self.url
    find_or_create_by(:name => "url")
  end

  def size
    visible_messages.size
  end

  def recieve
    msg_to_return = visible_messages.first
    msg_to_return.update_attributes({
      :visible => false,
      :retry_count => msg_to_return.retry_count + 1,
      :recieved_at => Time.now
    })
    msg_to_return
  end

  private 

  def visible_messages
    visibility_time_out_gap = Time.now - Message::VISIBILITY_TIMEOUT_IN_SECONDS
    messages.any_of({:visible => true},
                    {:recieved_at.lte => visibility_time_out_gap}
                   )
  end
  
end
