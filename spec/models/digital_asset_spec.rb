require 'spec_helper'

describe DigitalAsset do

  subject { FactoryGirl.build :digital_asset }

  context '#fields' do
    let(:defined_fields) {
      [:title, :changed_at, :sami_code, :product_ids, :summary,
        :published_at, :expires_at, :documents, :guid, :fund_ids, :audiences]
    }
    it 'has all defined fields' do
      defined_fields.each {|f| should respond_to(f)}
    end
  end

  context '#validation' do
    required_fields = [:guid, :title, :changed_at, :published_at, :expires_at]
    required_fields.each do |f|
      it "validates #{f} is required" do
        should be_valid
        subject.send("#{f}=", nil)
        should be_invalid "should be invalid if #{f} is missing"   
      end
    end
    it 'must have at least one document' do
      subject.documents.clear
      subject.should be_invalid
    end
    it 'cannot have a past expiration date' do
      subject.expires_at = 2.hours.ago
      subject.should be_invalid
    end
  end

  context '#documents' do
    let(:manifest) { FactoryGirl.build :document, :path => '/foo/manifest/foo.doc'}
    it 'doesnt add manifest documents' do
        subject.documents << manifest
        subject.save.should be_false
        # DigitalAsset.find(subject.id).documents should have(1).document
    end
  end

  context "purge!" do
    before do
      50.times { FactoryGirl.create :digital_asset }
      FactoryGirl.create :digital_asset, :updated_at => 10.minutes.ago
    end
    it 'removes all assets more than 5 minutes stale if bulk file has been processed' do
      expect {
        DigitalAsset.purge!
      }.to change(DigitalAsset, :count).by(-1)
    end
  end


  context '#finders' do
    before do
      @asset = FactoryGirl.create :digital_asset, :fund_ids => ['303'], 
        :audiences => ['690'], :sami_code => 'F000000.BAR'
      FactoryGirl.create :digital_asset, :fund_ids => ['420'], 
        :sami_code => 'MEH12345.000', :updated_at => 1.hour.ago
    end
    it 'has a finder by fund_id' do
      DigitalAsset.should respond_to(:funds_in)
      DigitalAsset.funds_in(['303']).should have(1).digital_asset
      DigitalAsset.funds_in(['808']).should have(0).digital_assets
    end
    it 'has a finder by product_id' do
      DigitalAsset.should respond_to(:product_in)
      DigitalAsset.product_in(['690']).should have(2).digital_asset
    end
    it 'has a finder by sami_code' do
      DigitalAsset.should respond_to(:sami_is)
      DigitalAsset.sami_is('F000000.BAR').should have(1).digital_asset
    end
    it 'has a finder by the embedded doc path' do
      DigitalAsset.should respond_to(:path_is)
      DigitalAsset.path_is(@asset.documents.first.path).should have(1).digital_asset
    end
    it 'has a type finder for the documents' do
      DigitalAsset.should respond_to(:doctype_in)
      DigitalAsset.doctype_in(['666']).should have(2).digital_asset
    end
    it 'can chain finders together' do
      FactoryGirl.create :digital_asset, :fund_ids => ['999'], 
        :audiences => ['420'], :sami_code => 'F000000.BAR'
      DigitalAsset.funds_in(['303', '420']).should have(2).digital_asset        
      DigitalAsset.funds_in(['303', '420']).audience_in(['690']).should have(1).digital_asset        
    end
    it 'has a finder for stale documents' do
      DigitalAsset.should respond_to(:stale)
      DigitalAsset.stale.should have(1).item
    end
    it 'has a method that tells you if the bulk-file processing is working' do
      DigitalAsset.should respond_to(:bulk_processed?)
      2.times { FactoryGirl.create :digital_asset }
      2.times { FactoryGirl.create :digital_asset, :updated_at => 10.minutes.ago }
      DigitalAsset.count.should == 6
      DigitalAsset.stale.count.should == 3
      DigitalAsset.should_not be_bulk_processed
      54.times { FactoryGirl.create :digital_asset }
      DigitalAsset.should be_bulk_processed
    end
  end

end
