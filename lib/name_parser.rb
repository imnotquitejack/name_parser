module NameParser
  autoload :Version, 'name_parser/version'
  autoload :Patterns,'name_parser/patterns'
  autoload :Parser,  'name_parser/parser'
  autoload :NickNames,  'name_parser/nick_names'

  def name_parser(name)
    Parser.new(name)
  end

  def self.parse(name)
    Parser.new(name)
  end
end

class String
  include NameParser

  def parse_name
    return name_parser(self)
  end
end