# https://github.com/AustinBlues/RSS-Speed-Reader/blob/master/lib/rss_speed_reader.rb
# https://github.com/tenderlove/nokogiri/pull/524

module Daengine::TeamsiteMetadataParser

  @@translation = {
      'TeamSite/Metadata/web_title' => 'title',
      "TeamSite/Metadata/enterprise_last_updated_date"=> 'changed_at',
      "TeamSite/Metadata/enterprise_audience_id"=> 'audiences',
      "TeamSite/Metadata/enterprise_sami_desc"=> 'sami_code',
      "TeamSite/Metadata/enterprise_last_publication_date"=> 'published_at',
      "TeamSite/Metadata/enterprise_unpublish_date"=> 'unpublished_at',
      "TeamSite/Metadata/enterprise_expiration_date"=> 'expires_at',
      "TeamSite/Metadata/enterprise_guid" => 'guid',
      "TeamSite/Metadata/shortSynopsis" => 'summary',
      "TeamSite/Metadata/business_owner" => 'business_owner',
      "TeamSite/Metadata/enterprise_product_id" => 'product_ids'
  }
  @@path_tuples = {
      "path" => 'path',
      "TeamSite/Metadata/enterprise_last_content_update_date" => 'doc_changed_at',
      "TeamSite/Metadata/enterprise_content_type_id" => 'content_type'
  }
  @@validations = {
      "TeamSite/Metadata/display_on_website" => lambda { |val| /Y|1/ =~ val },
      "TeamSite/Metadata/enterprise_expiration_date" => lambda { |val| Time.parse(val) > 1.minute.from_now },
      # "TeamSite/Metadata/enterprise_unpublish_date" => lambda {|val| val.blank? },
      "path" => lambda {|val| !(/\/manifest\// =~ val) }
  }

  @@logger = nil

  def self.logger=(some_logger)
    @@logger = some_logger
    self
  end

  def self.log(args)
    @@logger.error(args) unless @@logger.blank?
  end

  def self.parse_tuple_file(file)
    time do
      asset = nil
      assets = {}
      docpath = {}
      valid = true
      while (line = file.gets)
        case line
        when /<\/?data-tuple>/
          if (asset.blank?)
            asset = DigitalAsset.new
          elsif(valid)
            assets[asset.guid] ||= asset.attributes # first tuple metadata wins
            assets[asset.guid]['documents_attributes'] ||= []           
            assets[asset.guid]['documents_attributes'] << docpath
            # assets[asset.guid]['_id'] = asset.guid
            asset = nil; docpath = {}; valid = true;
          else
            asset = nil; docpath = {}; valid = true;
          end
        when /<tuple-field name="([^"]+)">([^<]+)<\/tuple-field>/
          if (valid)
            if @@validations[$1]
              valid = @@validations[$1].call($2)
            end
            if @@path_tuples[$1]
              docpath[@@path_tuples[$1]] = $2 # if this is one of our keys, 'send' to the method
            elsif (@@translation[$1])
              val = asset.send("#{@@translation[$1]}").respond_to?(:[]) ? $2.split(',') : $2
              asset.send("#{@@translation[$1]}=", val)
            end
          end
        end
      end
      # loop thru each doc in the collection, either replace or delete it
      assets.keys.each do |key|
        da = nil
        begin
          if(!assets[key]['unpublished_at'].blank?)
             DigitalAsset.where(guid: key).delete_all
          else
            da = DigitalAsset.find_or_initialize_by(guid: key)
            da.documents = []
            da.update_attributes!(assets[key])
          end
        rescue Exception => e
          p "Unable to save/update DigitalAsset guid=#{da.try(:guid)}, #{da.try(:errors).try(:full_messages)}"
        end      
      end
      DigitalAsset.purge!  # if the purge criteria is met, purge anything not updated
    end
  end

  def self.time
    start = Time.now
    yield
    self.log "elapsed time was #{Time.now - start}"
  end

end
