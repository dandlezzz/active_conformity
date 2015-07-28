# The reifiers are methods that help turn json friendly strings into executable ruby
# and vice versa.
module ActiveConformity
  module Reifiers
    def reify_regex(rule)
      return rule unless rule.is_a?(Hash)
      if rule["format"]
        rule["format"]["with"] = Regexp.new(rule["format"]["with"])
      elsif rule[:format]
        rule[:format][:with] = Regexp.new(rule[:format][:with])
      end
      return rule
    end
  end
end
