require 'ostruct'
require 'resolvable/config_methods'

module Resolvable
  SuggestedMethod = Struct.new(:file, :line, :method_info, :type)

  class OpenStructShim < OpenStruct
    include Resolvable

    def self.inherited(klass)
      klass.include(ConfigMethods)
    end

    def self.default_failure_message
      "Failed to resolve #{self.name}"
    end

    attr_accessor :kernel

    def initialize(*args)
      auto_generated_methods = args[0] || {}
      auto_generated_methods.each do |k, v|
        if(respond_to?("#{k}="))
          send("#{k}=", v)
        else
          __suggest_method__("#{k}=", nil, nil, nil)
        end
      end

      self.kernel = Kernel

      super
    end

    def method_missing(method_name, *args)
      file, line, method_info = caller(1, 1)[0].split(":")

      __warn__(method_name, file, line, method_info)
      __suggest_method__(method_name, file, line, method_info)

      super
    end

    def __warn__(method_name, file, line, method_info)
      return unless self.class.warnings

      kernel.warn "Missing method called on OpenStructShim: #{method_name} is not defined on #{self.class.name} (Called from #{file}##{line} in #{method_info}"
    end

    def __suggest_method__(method_name, file, line, method_info)
      return unless self.class.suggestions

      type = :attr_reader

      if method_name =~ /=$/
        type = :attr_accessor
        method_name = method_name.to_s.gsub(/=$/, "").to_sym
      end

      __suggested_methods__[method_name] = Resolvable::SuggestedMethod.new(file, line, method_info, type)
    end

    def __suggested_methods__
      @__suggested_methods__ ||= {}
    end

    def __suggested_method_summary__
      __suggested_methods__
        .group_by { |key, suggestion| suggestion.type }
        .map { |attr_type, suggestions|
          "#{attr_type} #{suggestions.map { |s| ":#{s[0]}" }.join(", ")}"
        }.join("\n")
    end
  end
end
