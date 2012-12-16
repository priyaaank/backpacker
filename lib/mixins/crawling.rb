require 'open-uri'

module Crawling

  def crawl
    document = fetch_from(@url).read
    extract_value_from document
  end

  def extract_value_from document
    @extractors.inject({}) do |hash, extractor|
      hash[extractor.name] = extractor.extract(document);
      hash
    end
  end

  def fetch_from url
    open(url)
  end

end
