require 'alias'

module NameParser
  # Represents a parsing object that describes a given name.
  class Parser
    include Patterns

    attr_reader :first, :middle, :last, :title, :suffixes

    # Options can include:
    #  messy_data: [true|false]
    #  check_for_reversed_names: [true|false]
    def initialize(name, options = {})
      @name = name.dup

      @options = {
        check_for_reversed_names: false,
      }

      if options[:messy_data]
        @options.update(
          check_for_reversed_names: true,
        )
      end
      @options.update(options) # Override with explicit options

      @suffixes = []
      run
    end

    def suffix
      @suffixes.first
    end

    def first_initial
      @first[0] rescue nil
    end

    def middle_initial
      @middle[0] rescue nil
    end

    def last_initial
      @last[0] rescue nil
    end

    protected

      def run
        remove_non_name_characters
        remove_extra_spaces
        clean_trailing_suffixes
        parse_title
        parse_suffixes
        remove_commas
        reverse_last_and_first_names
        parse_name
        fix_cases
        handle_only_first_names
      end

      def remove_non_name_characters
        @name.gsub!(/[^A-Za-z0-9\-\'\.&\/ \,]/, '')
      end

      def remove_extra_spaces
        @name.gsub!(/\s+/, ' ')
        @name.strip!
      end

      # David L. Bradfute, Ph.D., J.D. becomes David L. Bradfute Ph.D. J.D.
      # We don't want to simply remove all of the spaces;
      # they can differentiate first and last names.
      def clean_trailing_suffixes
        # true means case insensitive
        pattern = Regexp.new(format('(.+), (%s)', SUFFIX_PATTERN), true)
        until @name.gsub!(pattern, '\\1 \\2').nil? do
          # Replace suffixes...
        end
      end

      # This is applied when #messy_data == true
      def reverse_last_and_first_names
        # If the second name is in the nicknames list, then the format is probably LAST FIRST MIDDLE without commas

        if @options[:check_for_reversed_names]
          if NickNames[@name.split(' ')[1]].length > NickNames[@name.split(' ')[0]].length
            @name.gsub!(/(#{@name.split(' ')[0]}) /, '\\1,')
          end
        end

        @name.gsub!(/;/, '')
        @name.gsub!(/(.+),(.+)/, '\\2 ;\\1')
        @name.strip!
      end

      def remove_commas
        @name.gsub!(/,/, '')
      end

      def parse_title
        before_and_after("TITLES") do
          pattern = /(^(?:#{TITLE_PATTERN})\b)/i
          return unless match = @name.match(pattern)
          @title = match[1].strip
          @name.gsub!(/#{@title}/, '')
        end
      end

      def parse_suffixes
        before_and_after("SUFFIXES") do
          pattern = /(\b(?:#{SUFFIX_PATTERN}))$/i
          while match = @name.match(pattern) do
            suffix = match[1].strip
            @suffixes << suffix
            @name.gsub!(/#{suffix}/, '')
            # puts "parsing suffix: #{@name}"
          end
        end
      end

      def before_and_after(label='')
        puts "BEFORE #{label}: #{@name}"
        yield
        puts "AFTER #{label}: #{@name}"
      end

      def parse_name
        case
        when match = @name.match(Regexp.new('^%s%s$' % [NAME_PATTERN, LAST_NAME_PATTERN], true))
          @first, @last = match.captures
        when match = @name.match(Regexp.new('^%s%s%s%s$' % [NAME_PATTERN, NAME_PATTERN, NAME_PATTERN, LAST_NAME_PATTERN], true))
          @first, *middles, @last = match.captures[0..3]
          @middle = middles.join(' ')
        when match = @name.match(Regexp.new('^%s%s%s$' % [NAME_PATTERN, NAME_PATTERN, LAST_NAME_PATTERN], true))
          @first, @middle, @last = match.captures
        end
      end

      def fix_cases
        [:first, :middle, :last].each do |part|
          self.instance_variable_get("@#{part}").capitalize! if self.instance_variable_get("@#{part}").respond_to?(:capitalize)
        end
      end

      def handle_only_first_names
        return unless @first.nil? || @first.empty?
        @first = @name
      end
  end
end
