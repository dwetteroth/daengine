require "daengine/version"
require 'daengine/engine'
require File.expand_path('../../app/models/digital_asset',__FILE__)
require 'daengine/teamsite_metadata_parser'
require 'daengine/digital_asset_processor'
require 'mongoid'

module Daengine
  @config = {
    :assets_path => '/digital-assets'
  }

  @mongoid_config = {
    'database' => 'ssc_assets', # mongoid database name
    'host' => 'foo', # mongoid server
    'port' => 27017, # mongodb server port
    'slave_ok' => true
  }

  @valid_mongoid_keys = @mongoid_config.keys

  # yaml file config
  def self.configure(config_options)
    config_options.each {|k,v| @config[k.to_sym] = v} 
    config_options.each {|k,v| 
      @mongoid_config[k] = v if @valid_mongoid_keys.include? k
    } 
    Mongoid.configure do |config|
      config.from_hash(@mongoid_config)
    end
    p "configured with keys #{@config.keys}"
  end

  def self.config
    @config
  end

  def self.execute(config_options)
    self.configure(config_options)
    return DigitalAssetProcessor.execute  # start the thread daemon
  end

end
