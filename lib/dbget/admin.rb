require 'thor'

module DBGet
  class Admin < Thor
    desc "generate_authorized_keys", "generate authorized keys for access"
    def generate_authorized_keys
      if File.exist? File.join(Dir.pwd, 'keydir')
        key_dir = File.join(Dir.pwd, 'keydir')
      elsif ENV.include?('DBGET_KEYDIR_PATH')
        key_dir = ENV['DBGET_KEYDIR_PATH']
      else
        key_dir = ''
      end

      raise "Key directory 'keydir' not found." unless File.exists?(key_dir) and File.directory?(key_dir)

      puts "### Generated by dbget, DO NOT EDIT"

      keys = Dir["#{key_dir}/*.pub"]
      keys.each do |pub_key|
        bin_path = 'dbget-serve'
        key_name = File.basename(pub_key, '.pub')
        key_data = File.read(pub_key)

        puts "command=\"#{bin_path} #{key_name}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{key_data}"
      end
    end
  end

end