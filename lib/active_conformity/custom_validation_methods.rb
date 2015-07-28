module ActiveConformity
	module CustomValidationMethods
		def filesize_validator(max_size,byte_size)
			max_file_size = max_size.to_i.send(byte_size)
			if obj.asset_references.any?{ |ar| ar.filesize.to_i > max_file_size.to_i }
				errors.add(:asset_references, "asset too big")
			end
		end

		def method_missing(m, *args, &block)
			begin
				quantity = m.to_s.match(/\d+/)[0]
				if m.to_s =~ /filesize_\d+MB_max?/
					filesize_validator(quantity, :megabytes)
				elsif  m.to_s =~ /filesize_\d+GB_max?/
					filesize_validator(quantity, :gigabytes)
				else
					super
				end
			rescue
				super
			end
		end
	end
end
