require "sinatra/base"
require "sinatra/reloader"
require "json"

# filesystems
require "kurosawa/filesystems"

module Kurosawa
	class Database < ::Sinatra::Base

		set :bind, '0.0.0.0'
		configure :development do
			register Sinatra::Reloader
		end

		filesystem = ENV["KUROSAWA_FILESYSTEM"] || "file://~/.kurosawa"

		set :filesystem, Filesystem.instantiate(filesystem)

		def sanitize_path(path)
			match = /^\/[a-z0-9\-_\/]*$/i.match(URI.unescape(path))
			if match
				match.to_s.sub(/\/+$/, "")
			else
				p URI.unescape(path)
				halt 400
			end
		end

		def sanitize_body(body)
			begin
				JSON.parse(body)
			rescue => e
				puts e
				halt 400
			end
		end

		def random_key
			SecureRandom.hex(4)
		end

		def get_property(fs, path)
			property_entries = fs.ls("#{path}/$")
			if property_entries.length == 0
				nil
			elsif property_entries.length == 1
				JSON.parse(fs.get(property_entries[0]), symbolize_names: true)
			else
				# conflict
				raise "TODO get_property handle conflict"
			end
		end
 
		def set_property(fs, path, type:)
			puts "set property: #{path}"
			property_entries = fs.ls("#{path}/$")
			p property_entries
			if property_entries.length > 0
				property_entries.each do |x|
					fs.del(x)
				end
			end
			fs.put("#{path}/$#{random_key}", {type: type}.to_json)
		end


		def read(fs, path, ignore_objects: false)

			puts "read: path=#{path.inspect}"
			prop = get_property(fs, path)
			if prop == nil
				nil
			elsif prop[:type] == "object"
				res = {}

				inner_entries = fs.ls("#{path}")
					.select{ |x| /^\/\$/.match(x) == nil }
					.map{ |x| x.sub(/\/[^\/]+$/, "") }
					.map{ |x| match = /(?<first>^\/[^\/]+)/.match(x.sub(/^#{path}/, "")); match[:first] if match }
					.select{ |x| x != nil}
					.uniq

				puts "read: object: inner: #{fs.ls("#{path}").inspect}"
				puts "read: object: inner: #{inner_entries.inspect}"

				inner_entries.each do |x|
					res[x[1..-1]] = read(fs, path + x)
				end

				res

			elsif prop[:type] == "array"
				inner_entries = fs.ls("#{path}")
					.select{ |x| /\/\$/.match(x) == nil }

				puts "read: array: #{inner_entries.inspect}"

				inner_entries.select{|x| fs.exists(x)}.map do |x|
					JSON.parse(fs.get(x), symbolize_names: true)[:value] 
				end

			else
				inner_entries = fs.ls("#{path}")
					.select{ |x| /\/\$/.match(x) == nil }

				puts "read: string: #{inner_entries.inspect}"

				if inner_entries.length == 1
					JSON.parse(fs.get(inner_entries[0]), symbolize_names: true)[:value] 
				elsif inner_entries.length == 0
					nil
				else
					{"$conflict": inner_entries.map{|x| JSON.parse(fs.get(x), symbolize_names: true) }}
					#raise "read conflict at #{path} #{inner_entries.inspect}"
				end
			end
		end

		def write(fs, path, body)

			if body.is_a? Hash
				set_property(fs, path, type: "object")
				body.each do |k,v|
					write(fs, "#{path}/#{k}", v)
				end

			elsif body.is_a? Array
				set_property(fs, path, type: "array")
				body.each do |value|
					write(fs, "#{path}/#{random_key}", value)
				end

			else
				existing_entries = fs.ls("#{path}")

				if existing_entries.length > 0
					existing_entries.each do |x|
						fs.del(x)
					end
				end
				set_property(fs, path, type: "string")
				fs.put("#{path}/#{random_key}", {value: body.to_s}.to_json)
			end
		end

		def delete(fs, path)
			inner_entries = fs.ls("#{path}")

			puts "delete: #{inner_entries.inspect}"

			inner_entries.each do |x|
				fs.del(x)
			end
		end

		get "*" do
			path = sanitize_path(request.path)
			x = read(settings.filesystem, path)
			status 404 if x == nil
			x.to_json
		end

		post "*" do
			path = sanitize_path(request.path)

		end

		put "*" do
			path = sanitize_path(request.path)
			delete(settings.filesystem, path)
			write(settings.filesystem, path, sanitize_body(request.body.read))
			read(settings.filesystem, path).to_json
		end

		patch "*" do
			path = sanitize_path(request.path)
			write(settings.filesystem, path, sanitize_body(request.body.read))
			read(settings.filesystem, path).to_json
		end

		delete "*" do
			path = sanitize_path(request.path)
			delete(settings.filesystem, path)
			read(settings.filesystem, path).to_json
		end

		head "*" do
			path = sanitize_path(request.path)

		end



	end
end