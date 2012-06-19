class DigitalAssetsController < ApplicationController

  respond_to :json, :html, :only => [:index, :show, :search]

  CACHE_LAST_PARSE_TIME = 'last_parse_time'
  # GET /digital_assets
  # GET /digital_assets.json
  def index
    @digital_assets = DigitalAsset.all
    respond_with(@digital_assets)
  end

  # GET /digital_assets/1
  # GET /digital_assets/1.json
  def show
    @digital_asset = /\w{4,8}\.\d{0,3}/ =~ params[:id] ? DigitalAsset.sami_is(params[:id]).desc(:changed_at).first : DigitalAsset.find(params[:id])
    respond_with(@digital_asset)
  end

  #/digital_assets/search/sami_code=92023
  #/digital_assets/search/sami_code=NE00192&title=Fund%20Prospectus&fund_code=20293
  def search
    @digital_assets = []
    # loop thru each parameter that matches one of the method signatures
    @digital_assets = params.keys.select do |pk|
      DigitalAsset.respond_to?("#{pk}_is".to_sym) or DigitalAsset.respond_to?("#{pk}_in".to_sym)
    end.reduce(DigitalAsset) do |sum, key|
      # for each key, call the 'named query' method with the value given and chain...
      method = DigitalAsset.respond_to?("#{key}_in".to_sym) ? "#{key}_in".to_sym : "#{key}_is".to_sym
      sum.send(method, method.to_s.end_with?('in') ? params[key].to_a : params[key]) # should return result of the send call for chaining
    end
    respond_with(@digital_assets)
  end

  def sync_assets
    time0 = Rails.cache.read(CACHE_LAST_PARSE_TIME)
    if time0.nil?
      time0 = 2.days.ago
    end
    logger.info "Last time when ssc deploy files were read: #{time0.inspect}"
    time1 = Time.new
    logger.info "Current time: #{time1.inspect}"

    Rails.cache.write(CACHE_LAST_PARSE_TIME, time1)
    deploy_files= []

    start_directory = EDIST['digital_assets_directory']
    logger.info "Reading digital asset deployment files from #{start_directory}"
    if (File::directory?(start_directory))
      Dir.foreach(start_directory) do |entry|
        if (!File::directory?(entry))
          filename = start_directory + entry
          difference0 = File.mtime(filename)- time0 #To-Do - We should be looking at created time - ctime
          difference1 = File.mtime(filename) - time1
          if ((difference0 >= 0) & (difference1 < 0))
            if(/bulk-ssc_|selective-ssc_/ =~ filename)
              deploy_files << filename
            end
          end
        end
      end
    end

    deploy_files.each do |filename|
      #parse the file and add content to database.
      logger.info "Processing file #{filename} found."
      file = File.expand_path(filename, __FILE__)
      open_file = open(file, 'rb')
      Etl::TeamsiteMetadataParser.parse_tuple_file(open_file)
      logger.info "Finished parsing #{filename}."
    end

    head :accepted
  end

end
