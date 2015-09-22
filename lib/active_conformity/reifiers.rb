
module ActiveConformity
  module Reifiers

    def reify_rule(rule)
      reify_regex(rule).deep_symbolize_keys
    end

    def reify_regex(rule)
      return rule unless rule.is_a?(Hash) && rule[:format]
      rule[:format][:with] = Regexp.new(rule[:format][:with])
      rule
    end
  end
end
