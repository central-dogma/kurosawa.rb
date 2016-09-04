
require "kurosawa/filesystems/local"
require "kurosawa/filesystems/s3"

require "uri"

module Kurosawa
	class Filesystem
		def self.instantiate(fs)
			if fs.start_with?("file://")
				Kurosawa::Filesystems::Local.new(fs.sub("file://", ""))
			elsif fs.start_with?("s3://") or fs.start_with?("s3http://") or fs.start_with?("s3https://")
				
				url = URI.parse(fs);
				tokens = url.userinfo.split(":")

				Kurosawa::Filesystems::S3.new(
					access_key_id:"#{tokens[0]}",
					secret_access_key:"#{tokens[1]}",
					region:"#{tokens[2]}",
					bucket:url.scheme == "s3" ? url.host : "",
					endpoint:url.scheme == "s3" ? nil : "#{url.scheme.sub("s3","")}://#{url.host}:#{url.port}",
					force_path_style: url.scheme != "s3")
			else
				raise "Unknown filesystem"
			end
		end
	end
end
