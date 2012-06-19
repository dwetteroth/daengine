require 'spec_helper'

describe Daengine::DigitalAssetProcessor do
  before { Daengine.configure(:assets_path => 'c:/dev/rails/da_gem/spec/mock_data')}
  context "process_tuple_directory" do
    it 'processes only files modified in the last 2 days' do
      # process all the files in the mock dir
      expect { process_tuple_directory }.to change(DigitalAsset.count).by(1)
      # modify the first 2 files in test-data directory to have updated times
      FileUtils.touch '../mock_data/selective-ssc_2012_05_18_13_48_03_publish.xml'
      # FileUtils.touch 'mock_data/selective-ssc_2012_05_18_13_56_18_unpublish.xml'
      # re-process the updated files
      expect { process_tuple_directory }.to change(DigitalAsset.count).by(1)
    end
  end
end