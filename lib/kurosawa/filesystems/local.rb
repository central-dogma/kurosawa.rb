require 'kurosawa/filesystems/base'
require 'fileutils'

module Kurosawa::Filesystems
	class Local < Base

		def initialize(root_path)
			@root_path = File.expand_path(root_path)
			FileUtils.mkdir_p(@root_path)
		end

		def root_path
			@root_path
		end

		def path(key)
			File.join(@root_path, key)
		end

		def ls(prefix)
			puts "fs: ls #{prefix}"
			(Dir["#{@root_path}/#{prefix}*"] + Dir["#{@root_path}/#{prefix}/**/*"]).
				select{|x| File.file?(x)}.
				map{|x| x.sub(/^#{root_path}/, "").
				gsub(/\/+/, "/")}.
				uniq
			
		end

		def get(key)
			puts "fs: get #{path(key)}"
			File.read(path(key))
		end

		def put(key, value)
			puts "fs: put #{path(key)}"
			FileUtils.mkdir_p(File.dirname(path(key)))
			File.write(path(key), value)
		end

		def del(key)
			puts "fs: delete #{path(key)}"
			File.delete(path(key)) if File.file?(path(key))
		end

		def exists(key)
			puts "fs: exists #{path(key)}"
			File.exists?(path(key)) and File.file?(path(key))
		end

		def cleanup!
			Dir['#{@root_path}**/*'].
				select { |d| File.directory? d }.
				select { |d| (Dir.entries(d) - %w[ . .. ]).empty? }.
				each   { |d| Dir.rmdir d }
		end

	end
end
