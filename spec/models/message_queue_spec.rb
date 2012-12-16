require 'spec_helper'

describe MessageQueue do
  
  context "attributes" do
    
    let(:queue) { MessageQueue.url }

    it "should have a name" do
      queue.name.should eq "url"
    end

    it "should have a field called name" do
      queue.should respond_to :name
    end
    
  end

  context "messages" do
    
    let(:queue) { MessageQueue.url }

    before do
      message_body = {:body => "Hola!", :url => "http://lonelyplanet.com"}.to_json
      @new_message = Message.new(:text => message_body)
      queue.messages << @new_message
    end

    it "should have messages in it" do
      queue.should respond_to :messages
    end

    it "should contain message without altering it' state" do
      queue.messages.first.should eq @new_message
    end

    it "should be returned as a list" do
      queue.messages.should be_a Array
    end

  end

  context "operations" do

    let(:queue) { MessageQueue.url }
    let(:one_second) { 1 }

    before do
      lonely_planet = {:body => "Hola!", :url => "http://lonelyplanet.com"}.to_json
      trip_advisor = {:body => "Hola!", :url => "http://tripadvisor.com"}.to_json
      @message_one = Message.new(:text => lonely_planet)
      @message_two = Message.new(:text => trip_advisor)
      queue.messages << [@message_one, @message_two]
    end

    it "should return the size of queue" do
      queue.size.should eq 2
    end

    it "should return size for visible messages only" do
      @message_two.update_attributes(:visible => false)

      queue.size.should eq 1
    end

    it "should include invisible messages that have crossed visibility timeout, in size" do
      queue.recieve

      Timecop.travel(Time.now + Message::VISIBILITY_TIMEOUT_IN_SECONDS + one_second) do
        queue.size.should eq 2
      end
    end

    context "recieve" do

      it "should mark message invisible" do
        message = queue.recieve

        message_from_db = MessageQueue.url.messages.where(:_id => message.id)
        message.visible.should be_false
      end

      it "should return nil if queue is empty" do
        2.times { queue.recieve }

        queue.recieve.should be_nil
      end

      it "should update the recieved at timestamp" do
        message = nil
        Timecop.freeze(2022, 12, 12, 10, 5, 0) do
          message = queue.recieve
        end
        Timecop.return

        message_from_db = MessageQueue.url.messages.where(:_id => message.id)
        message.recieved_at.should eq Time.new(2022, 12, 12, 10, 5, 0)
      end

      it "should not return an invisible message" do
        @message_one.update_attributes(:visible => false)

        queue.size.times do
          queue.recieve.id.should_not eq @message_one.id
        end
      end

      it "should increment retry count by one" do
        @message_one.update_attributes(:retry_count => 2)

        retry_counts = queue.size.times.collect { queue.recieve.retry_count }
        retry_counts.should include(1,3)
      end

      it "should pick invisible messages too after visibility timeout period" do
        message = queue.recieve

        Timecop.travel(Time.now + Message::VISIBILITY_TIMEOUT_IN_SECONDS + one_second) do
          messages = queue.size.times.collect do
            queue.recieve
          end
          messages.should include(message)
        end
      end

      it "should not pick invisible message if visibility timeout is not crossed" do
        message = queue.recieve

        Timecop.travel(Time.now + Message::VISIBILITY_TIMEOUT_IN_SECONDS - one_second) do
          messages = queue.size.times.collect do
            queue.recieve
          end
          messages.should_not include(message)
        end
      end

    end

    context "delete" do

      it "should remove the message from the queue" do
        queue.recieve.delete

        Timecop.travel(2022, 12, 12, 10, 5, 0) do
          queue.size.should eq 1
        end
      end

    end

  end

end
