require 'kurosawa/filesystems/base'
require 'uri'
require 'aws-sdk'

module Kurosawa::Filesystems
	class S3 < Base

		def initialize(access_key_id:,secret_access_key:,region:,endpoint:,bucket:,force_path_style:false)

			options = {
				:access_key_id => URI.encode(access_key_id),
				:secret_access_key => URI.decode(secret_access_key),
				:region => region,
				:force_path_style => force_path_style
			}
			options[:endpoint] = endpoint if endpoint

			@s3 = Aws::S3::Client.new(options)
			@bucket_name = bucket
			@bucket = Aws::S3::Bucket.new(bucket, client: @s3)
		end

		def ls(prefix)
			prefix.gsub!(/^\/+/, "")
			puts "s3:ls #{prefix}"
			result = []
			next_marker = nil
			loop do
				options = {
					bucket: @bucket_name,
					marker: next_marker
				}

				options[:prefix] = prefix if prefix.length != 0

				resp = @s3.list_objects(options);
				result += resp.contents.map { |x| "/#{x.key}" }
				break if resp.next_marker == nil
				next_marker = resp.next_marker
			end
			result
		end

		def get(key)
			key.gsub!(/^\/+/, "")
			puts "s3:get #{key}"
			resp = @s3.get_object(bucket: @bucket_name, key: key)
			resp.body.read
		end

		def put(key, value)
			key.gsub!(/^\/+/, "")
			puts "s3:put #{key}"
			@s3.put_object(bucket: @bucket_name, key: key, body: value)
		end

		def del(key)
			key.gsub!(/^\/+/, "")
			puts "s3:del #{key}"
			@s3.delete_object(bucket: @bucket_name, key: key)
		end

		def exists(key)
			key.gsub!(/^\/+/, "")
			puts "s3:exists #{key}"
			@bucket.objects[key].exists?
		end

		def cleanup!
		end
	end
end