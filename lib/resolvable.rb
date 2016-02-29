require "resolvable/version"

module Resolvable
  class DoubleSuccessError < StandardError; end
  class FailureAfterSuccessError < StandardError; end
  class SuccessAfterFailureError < StandardError; end

  module ClassMethods
    def default_failure_message
    "Failed to resolve #{self.name}"
    end
  end

  def self.included(klass)
    klass.extend(Resolvable::ClassMethods)
  end

  def success!
    raise SuccessAfterFailureError.new if(failure?)
    raise DoubleSuccessError.new if(success?)

    resolve(:success)

    self
  end

  def failure!
    raise FailureAfterSuccessError.new if(success?)

    resolve(:failure)
    add_error(self.class.default_failure_message)

    self
  end

  def success?
    resolution == :success
  end

  def failure?
    resolution == :failure
  end

  def errors
    @errors ||= []
  end

  private

  def add_error(message)
    errors << message
  end

  def resolution
    @resolution
  end

  def resolve(resolve_into_state=:success)
    @resolution = resolve_into_state
  end
end
