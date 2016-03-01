require 'ostruct'

module Resolvable
  class OpenStructShim < OpenStruct
    attr_writer :kernel

    def method_missing(method_name, *args)
      kernel.warn("Missing method called on OpenStructShim: #{method_name} is not defined on #{self.class.name}")

      super
    end

    def kernel
      @kernel ||= Kernel
    end
  end
end
