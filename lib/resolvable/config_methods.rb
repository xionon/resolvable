module Resolvable
  module ConfigMethods
    def self.included(klass)
      to_class_eval = %w[warnings suggestions automatic].map do |method_name|
        <<-METHOD_BODY
          def self.#{method_name}=(other)
            @@#{method_name} = other
          end

          def self.#{method_name}
            @@#{method_name} = nil unless defined?(@@#{method_name})
            @@#{method_name}
          end

        METHOD_BODY
      end

      klass.class_eval(to_class_eval.join("\n"))
    end
  end
end
