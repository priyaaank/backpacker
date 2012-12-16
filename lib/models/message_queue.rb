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
    return nil if msg_to_return.nil?
    update_message_before_returning msg_to_return
    msg_to_return
  end

  def send_message message
    messages << message
  end

  private 

  def update_message_before_returning message
    message.update_attributes({
      :visible => false,
      :retry_count => message.retry_count + 1,
      :recieved_at => Time.now
    })
  end

  def visible_messages
    make_messages_visible_if_visibility_timeout_has_happened
    messages.where({:visible => true})
  end

  def make_messages_visible_if_visibility_timeout_has_happened
    visibility_time_out_gap = Time.now - Message::VISIBILITY_TIMEOUT_IN_SECONDS
    messages_to_be_updated = messages.where({:recieved_at.lte => visibility_time_out_gap})
    messages_to_be_updated.update_all({:visible => true}) unless messages_to_be_updated.nil? || messages_to_be_updated.blank?
  end
  
end
