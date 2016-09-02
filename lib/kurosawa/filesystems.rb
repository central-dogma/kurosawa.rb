
require "kurosawa/filesystems/local"
require "kurosawa/filesystems/s3"

module Kurosawa
	class Filesystem
		def self.instantiate(fs)
			if fs.start_with?("file://")
				Kurosawa::Filesystems::Local.new(fs.sub("file://", ""))
			else
				raise "Unknown filesystem"
			end
		end
	end
end
