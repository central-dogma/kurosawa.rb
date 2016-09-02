
module Kurosawa::Filesystems
	class Base
		def ls(prefix)
			[]
		end

		def get(key)
			""
		end

		def put(key, value)
		end

		def del(key)
		end

		def exists(key)
			false
		end

		def cleanup!
		end
	end
end