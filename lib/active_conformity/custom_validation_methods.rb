module ActiveConformity
	module CustomValidationMethods
		def filesize_validator(max_size,byte_size)
      max_file_size = max_size.to_i.send(byte_size)
      if obj.asset_references.any?{ |ar| ar.filesize.to_i > max_file_size.to_i }
        errors.add(:asset_references, "asset too big")
      end
    end

    def range_validator(min, max)
      min_val, max_val = obj.value.to_s.scan(/\d+/)
      errors.add(:value, "out of range") if min_val < min
      errors.add(:value, "out of range") if max_val > max
      errors.add(:value, "bad range") if min_val > max_val
    end

    def method_missing(m, *args, &block)
      if m.to_s =~ /filesize_\d+MB_max?/
        quantity = m.to_s.match(/\d+/)[0]
        filesize_validator(quantity, :megabytes)
      elsif  m.to_s =~ /filesize_\d+GB_max?/
        quantity = m.to_s.match(/\d+/)[0]
        filesize_validator(quantity, :gigabytes)
      elsif m.to_s =~ /validates_range/
        range_validator(method_args[0], method_args[1])
      else
        super
      end
    end
	end
end
