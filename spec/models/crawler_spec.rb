require 'spec_helper'

class SuperCrawler
  
  def initialize(url, extractors)
    @url = url
    @extractors = extractors
  end

  include Crawling

end

describe SuperCrawler do

  let(:uri) { "http://www.lonelyplanet.com/india" }
  let(:response_file) { "spec/fixtures/response/india_response.html" }
  
  context "with extractors that have content" do

    let(:sight_url_extractor) { Extractor.new(:sight_url, ".sights a")  { |html| html[0]['href']} }
    let(:sight_count_extractor) { Extractor.new(:sight_count, ".sights"){ |html| html[0].text.strip } }

    before do
      @crazy_crawler = SuperCrawler.new(uri, [sight_url_extractor, sight_count_extractor])
      response = File.read(response_file)
      stub_request(:any, uri).to_return(:body => response, :status => 200)

      @selector_results = @crazy_crawler.crawl
    end
    
    it "should extract url for url extractor" do
      @selector_results[:sight_url].should eq "http://www.lonelyplanet.com/india/sights"
    end

    it "should extract count using count extractor" do
      @selector_results[:sight_count].should eq "Sights (1,150)"
    end

    it "should crawl values for all the extractors" do
      @selector_results.size.should eq 2
    end

  end

  context "with extractors that do not have content" do

    let(:non_existent_content) { Extractor.new(:sight_url, ".sight")  { |html| html[0]['href']} }

    before do
      @crazy_crawler = SuperCrawler.new(uri, [non_existent_content])
      response = File.read(response_file)
      stub_request(:any, uri).to_return(:body => response, :status => 200)

      @selector_results = @crazy_crawler.crawl
    end

    it "should return a blank value" do
      @selector_results[:sight_url].should be_blank
    end

  end


end
