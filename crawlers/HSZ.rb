require 'nokogiri'
require 'open-uri'
require 'JSON'

def crawl_list
  item_urls = []

  list_urls = %w{
    http://society.hccg.gov.tw/web/SelfPageSetup?command=display&pageID=22308&page=view
    http://society.hccg.gov.tw/web/SelfPageSetup?command=display&pageID=22309
    http://society.hccg.gov.tw/web/SelfPageSetup?command=display&pageID=23994
    http://society.hccg.gov.tw/web/SelfPageSetup?command=display&pageID=22311
    http://society.hccg.gov.tw/web/SelfPageSetup?command=display&pageID=22321&page=view
  }

  list_urls.each do |list_url|
    doc = get_doc(list_url)
    doc.css('#denis a').each do |a|
      item_urls << URI.join(list_url, a.attr('href')).to_s
    end
  end
  item_urls << 'http://society.hccg.gov.tw/web/SelfPageSetup?command=display&pageID=22314&page=view'

  item_urls.uniq!
  item_urls.reject!{|item_url| item_url.include?('.doc')}
  item_urls.select!{|item_url| item_url.include?('SelfPageSetup')}

  item_urls.map{|item_url| crawl_item(item_url)}
end

# e.g. http://society.hccg.gov.tw/web/SelfPageSetup?command=display&pageID=22372
def crawl_item(url)
  doc = get_doc(url)

  if !doc.to_s.include?('補助項目')
    return
  end

  main_section = doc.at_css('#denis')

  title = main_section.at_css("th:contains('補助項目')").next_element.text.strip

  data_types = {}

  main_section.css('th').each do |el|
    if el.text.include?('表件下載') || el.text.include?('補助項目')
      next
    end

    if el
      data_types[el.text.try(:strip)] = el.next_element.text.try(:strip)
    end
  end

  content = data_types.map{|k,v| "#{k}：#{v}".strip }.join("\n\n")

  files = []
  if el = main_section.at_css("th:contains('表件下載')")
    el.next_element.css('a').each do |a|
      file_url = URI.join(url, a.attr('href'))
      file_name = a.attr('title').try(:strip) || a.text.strip
      files << {name:file_name, filename:file_url.to_s}
    end
  end

  {
    title: title,
    content: content,
    url: url,
    files: files
  }
end

def get_doc(url)
  Nokogiri.HTML(open(url))
end

class Object
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    else
      public_send(*a, &b) if respond_to?(a.first)
    end
  end
end

result = crawl_list
#puts result.to_json
File.open('data.json', 'w') { |file| file.write(result.to_json) }
