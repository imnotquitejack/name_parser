require 'colorize'

module NameParser
  autoload :Version, 'name_parser/version'
  autoload :Patterns, 'name_parser/patterns'
  autoload :Parser, 'name_parser/parser'
  autoload :NickNames, 'name_parser/nick_names'

  def name_parser(name, options = {})
    Parser.new(name, options)
  end

  def self.parse(name, options = {})
    Parser.new(name, options)
  end
end

class String
  include NameParser

  def parse_name(options = {})
    name_parser(self, options)
  end
end
