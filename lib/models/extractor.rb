require 'nokogiri'

class Extractor

  attr_accessor :name
  
  def initialize(name, css_selector = nil, &block)
    @name = name
    @css_selector = css_selector
    @post_processing_block = block
  end

  def extract(document)
    return "" if @css_selector.nil?
    html = Nokogiri::HTML(document)
    selected_fragment = html.css(@css_selector) 
    has_matching_content?(selected_fragment) ? @post_processing_block.call(selected_fragment) : ""
  end

  private

  def has_matching_content? html_fragment
    !(html_fragment.nil? || html_fragment.blank?)
  end 

end
