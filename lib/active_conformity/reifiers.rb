
module ActiveConformity
  module Reifiers

    def reify_rule(rule)
      reify_regex(rule).deep_symbolize_keys
    end

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
