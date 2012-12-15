require 'spec_helper'

describe Extractor do

  context "attributes" do

    let(:extractor) { Extractor.new(:sight_url) }

    it "should have a name" do
      extractor.name.should eq :sight_url
    end

  end

  context "applying extractor to an html fragment" do

    let(:html_fragment) { File.read("spec/fixtures/response/india_response.html") }

    context "without providing a css selector" do
      
      let(:extractor) { Extractor.new(:sight_url) }

      it "should return blank value as the result" do
        extractor.extract(html_fragment).should be_blank
      end

    end

    context "to an html fragment" do

      before do
        @extractor = Extractor.new(:sight_url, ".sights a"){|selected_html| selected_html[0]['href'] }
      end

      it "should extract href url" do
        href = @extractor.extract(html_fragment)
        href.should eq "http://www.lonelyplanet.com/india/sights"
      end

    end

  end

end
