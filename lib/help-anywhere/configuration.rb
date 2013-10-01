# -*- encoding: utf-8 -*-
module HelpAnywhere
  def self.configure(configuration=HelpAnywhere::Configuration.new)
    yield configuration if block_given?
    @@configuration = configuration
  end

  def self.config
    @@configuration ||= HelpAnywhere::Configuration.new
  end

  class Configuration
    attr_accessor :edition_role

    def has_edition_role? scope
      if edition_role.instance_of?(Proc)
        edition_role.bind(scope).call
      else
        scope.send(edition_role.to_s.to_sym)
      end
    end

    def routes
      yield @routes if block_given?

      @routes
    end

    def render_routes
      @routes.to_javascript
    end

    def initialize
      @routes = HelpAnywhere::Routes.new
      @edition_role = lambda{ true } #per default, we need no authentication to edit help resources
    end
  end

  class Routes
    DEFAULTS_ROUTES = [['/', '_root'], ['??', '$1']]

    attr_accessor :match_data, :ignore_data

    def initialize
      @match_data = []
      @ignore_data = []
    end

    def match regexp, result
      self.match_data << [ regexp, result ]
    end

    def ignore regexp
      self.ignore_data << [ regexp, result ]
    end

    def to_json *args
      arr = self.match_data + DEFAULTS_ROUTES

      arr.to_json
    end

    def to_javascript
      arr = self.match_data + DEFAULTS_ROUTES

      output = "HelpAnywhere.add_routes(["
      output += arr.map{ |x| "[/#{x[0].source}/, '#{x[1].sub('\'', '\\\'')}']" }.join(',')
      output += "]);"

      #output += "HelpAnywhere.ignore(["

      output
    end
  end
end
