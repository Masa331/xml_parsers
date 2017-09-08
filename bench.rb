require 'nokogiri'

class SaxParser
  class Parser < Nokogiri::XML::SAX::Document
    attr_reader :total

    def start_element(name, attrs)
      @current_element = name
      @current_attrs = attrs.to_h
    end

    def characters(string)
      @total ||= 0
      value = string.strip

      if @current_element == 'field' && @current_attrs['name'] == 'Value'
        @total += value.to_d
      end
    end
  end

  def initialize(file)
    @file = file
  end

  def result
    parser = Parser.new()
    agent = Nokogiri::XML::SAX::Parser.new(parser)
    agent.parse(@file)

    parser.total
  end
end

class DomParser
  def initialize(file)
    @file = file
  end

  def result
    parser = Nokogiri::XML(@file)
    parser.xpath("//field[@name='Value']").inject(0) { |sum, n| sum + n.text.to_d  }
  end
end

raw = File.read("file.xml")

Benchmark.bm(30) do |b|
  b.report("SAX: }") do
    SaxParser.new(raw).result
  end

  b.report("DOM: }") do
    DomParser.new(raw).result
  end
end
