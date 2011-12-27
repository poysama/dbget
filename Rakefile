require "bundler/gem_tasks"

desc "Generate authorized_keys file from keys directory"
task :generate_authorized_keys do
  key_dir = File.join(File.dirname(__FILE__), 'keydir')
  raise "Key directory 'keys' not found." unless File.exists?(key_dir) and File.directory?(key_dir)

  puts "### Generated by dbget, DO NOT EDIT"

  keys = FileList['keydir/*.pub']
  keys.each do |pub_key|
    bin_path = File.join(File.dirname(__FILE__), 'bin/dbget-serve')
    key_name = File.basename(pub_key, '.pub')
    key_data = File.read(pub_key)

    puts "command=\"#{bin_path} #{key_name}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{key_data}"
  end
end
