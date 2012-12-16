require 'spec_helper'

describe Message do

  context "attributes" do
    
    let(:message_text) { {:url => "http://www.lonelyplanet.com/india/northeast-states/agartala"}.to_json }
    let(:message) { Message.new(:text => message_text) }

    it "should have text" do
      message.should respond_to :text
    end

    it "should return text as added to message during creation" do
      message.text.should eq message_text
    end

    it "should have a retry count" do
      message.should respond_to :retry_count
    end

    it "should have retry count as 0 initially" do
      message.retry_count.should eq 0
    end

    it "should have a recieved at" do
      message.should respond_to :recieved_at
    end
  
    it "should have recieved at as nil by default" do
      message.recieved_at.should be_nil
    end

    it "should have a visible flag" do
      message.should respond_to :visible
    end

    it "should have visible as true by default" do
      message.visible.should be_true
    end
    
  end

end
