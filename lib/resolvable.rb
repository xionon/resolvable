require "resolvable/version"

module Resolvable
  class DoubleSuccessError < StandardError; end
  class FailureAfterSuccessError < StandardError; end

  module ClassMethods
    def default_failure_message
    "Failed to resolve #{self.name}"
    end
  end

  def self.included(klass)
    klass.extend(Resolvable::ClassMethods)
  end

  def success!
    raise DoubleSuccessError.new if(defined? @success)

    @success = true
    self
  end

  def failure!
    raise FailureAfterSuccessError.new if(success?)

    @success = false
    @errors ||= []
    @errors << self.class.default_failure_message

    self
  end

  def success?
    @success == true
  end

  def failure?
    @success == false
  end

  def errors
    @errors
  end
end
