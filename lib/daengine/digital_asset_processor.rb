module Daengine
class DigitalAssetProcessor
  
  @@last_read_time = 2.days.ago

  def self.trap_signals
    sigtrap = proc { 
      puts "DigitalAssetProcessor: caught trapped signal, shutting down"
      @@run = false 
    }
    signals = ["SIGTERM", "SIGINT"]
    signals.push("SIGHUP") unless is_windows?
    signals.each do |signal|
      trap signal, sigtrap
    end
  end

  def self.is_windows?
    processor, platform, *rest = RUBY_PLATFORM.split("-")
    platform =~ /mswin/ || platform =~ /mingw/
  end

  def self.execute
    @@run = true
    trap_signals
    @@wthread = Thread.new { worker() }  
    return @@wthread
  end
  
  def self.worker
    puts "DigitalAssetProcessor: start processing digital assets!"
    while @@run
      begin
        self.process_tuple_directory
        process_tuple_directory
      rescue => e
        puts e.message
        puts e.backtrace
      end
      sleep(5)
    end
    @@wthread.exit
  end

  def self.process_tuple_directory
    path = Daengine.config[:assets_path]
    raise "DigitalAssetProcessor: unable to read from asset path #{path}" unless File::directory?(path)
    # read the given directory, process each file in date order starting 2 days ago
    deploy_files= []

    puts "DigitalAssetProcessor: reading digital asset deployment files from #{path}"
    deploy_files = Dir.entries(path).select {
      |f| File.file?("#{path}/#{f}") and File.mtime("#{path}/#{f}") > @@last_read_time
    }.sort_by{ |f| File.mtime("#{path}/#{f}") }

    deploy_files.each do |filename|
      #parse the file and add content to database.
      file = File.expand_path(filename, path) 
      p "DigitalAssetProcessor: processing file #{file}"
      open_file = File.open(file, 'rb')
      Daengine::TeamsiteMetadataParser.parse_tuple_file(open_file)
      p "DigitalAssetProcessor: finished parsing #{filename}."
      @@last_read_time = File.mtime(file)
      p "DigitalAssetProcessor: set last read time to #{@@last_read_time}."
    end

  end
  
end
end