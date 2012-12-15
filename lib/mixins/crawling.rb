require 'open-uri'

module Crawling

  def crawl
    document = fetch_from(@url).read
    @extractors.inject({}) do |hash, extractor|
      hash[extractor.name] = extractor.extract(document);
      hash
    end
  end

  def fetch_from url
    open(url)
  end

end
