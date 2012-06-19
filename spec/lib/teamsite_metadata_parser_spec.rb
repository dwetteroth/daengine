require 'spec_helper'

describe Daengine::TeamsiteMetadataParser do

  subject { Daengine::TeamsiteMetadataParser }

  context "#parse_tuple_file" do
    it 'reads xml' do   
      # subject.logger= Logger.new(STDOUT)
      file = File.expand_path('./spec/mock_data/selective_new_package.xml')
      expect { 
        subject.parse_tuple_file(open(file))
        }.to change(DigitalAsset, :count).by(2)
      entered = DigitalAsset.first
      entered.id.should == '163742d3-fbc2-4c99-8396-6eabe7464b8f'
      entered.documents[0].path.should == '/digitalAssets/SSC_Developer_Installation_Guide-163742d3-fbc2-4c99-8396-6eabe7464b8f.doc'
      entered.summary.should == 'first foo bar...'
      DigitalAsset.first.documents.count.should eq(2)
    end
    it 'can read a whole bulk deploy xml file quickly' do
      # subject.logger= Logger.new(STDOUT)
      file = File.expand_path('./spec/mock_data/bulk-ssc_deploy.xml')
      open_file = open(file, 'rb')
      expect {
        subject.parse_tuple_file(open_file)
      }.to change(DigitalAsset, :count).by(1588)
    end
  end

 
  context 'deleting paths' do
    before do
      file = File.expand_path('./spec/mock_data/selective_new_package.xml')
      subject.parse_tuple_file(open(file))
    end
    it 'deletes paths that are no-longer in the tuples for a package' do
      file = File.expand_path('./spec/mock_data/selective_path_delete_from_package.xml')
      DigitalAsset.find('163742d3-fbc2-4c99-8396-6eabe7464b8f').documents.should have(2).items
      expect { 
        subject.parse_tuple_file(open(file))
        }.to change(DigitalAsset, :count).by(0)
      DigitalAsset.find('163742d3-fbc2-4c99-8396-6eabe7464b8f').documents.should have(1).item
    end
  end

  context 'remove unpublished documents from mongo' do
      before do
        file = File.expand_path('./spec/mock_data/selective-ssc_2012_05_18_13_48_03_publish.xml')
        subject.parse_tuple_file(open(file))
      end
    it 'removes package records from mongo that are in unpublished state' do
      DigitalAsset.find('11570991-9887-46df-8c47-d0870e6b5008').documents.should have(1).item
      file = File.expand_path('./spec/mock_data/selective-ssc_2012_05_18_13_56_18_unpublish.xml')
      expect {
        subject.parse_tuple_file(open(file))
        }.to change(DigitalAsset, :count).by(-1)
    end
  end
  
end