require 'spec_helper'

describe DigitalAssetsController do
  let(:digital_asset) { FactoryGirl.create :digital_asset }
  describe "index" do
    it "assigns all digital_assets as @digital_assets" do
      get :index
      assigns(:digital_assets).should eq([digital_asset])
    end
  end

  describe "show" do
    it 'returns a single asset when given a guid' do
      get :show, :id => digital_asset.guid
      assigns(:digital_asset).guid.should eq(digital_asset.guid)
    end
    it 'returns a single asset when given a sami_code' do
      get :show, :id => digital_asset.sami_code
      assigns(:digital_asset).should eq(digital_asset)
    end
    it 'returns the most recent asset when given a SAMI ID' do
      FactoryGirl.create :digital_asset, :sami_code => digital_asset.sami_code, :changed_at => 2.years.ago
      get :show, :id => digital_asset.sami_code
      assigns(:digital_asset).should eq(digital_asset)
    end
    it "assigns the requested digital_asset as @digital_asset" do
      get :show, :id => digital_asset.id
      assigns(:digital_asset).should eq(digital_asset)
    end

    # context "documents" do
    #   it 'can get the individual documents via a nested route' do
    #     get :show, :id => digital_asset.documents.first.id,
    #         :digital_asset_id => digital_asset.id
    #   end
    # end
  end

  # describe "new" do
  #   it "returns a not allowed" do
  #     get :new, {}
  #     response.should be '404'
  #   end
  # end

  # describe "edit" do
  #   it "returns a not allowed" do
  #     get :edit, {:id => digital_asset.id}
  #     response.should be '404'
  #   end
  # end

  describe 'search' do
    context 'blank query' do
      it 'returns nothing' do
        get :search
        assigns(:digital_assets).should be_empty
      end
    end
    context 'path' do
      before do
        5.times { FactoryGirl.create :digital_asset }
        @single = FactoryGirl.create :digital_asset
        @single.documents.clear
        @single.documents.build(:path => '/one/off.path', :doc_changed_at => Time.now, :content_type => '999')
        @single.save!
      end
      it 'returns a single resource for a complete path' do
        get :search, :path => '/one/off.path'
        assigns(:digital_assets).should have(1).result
        assigns(:digital_assets).first.should eq(@single)
      end
      it 'returns an array of resources for a partial match' do
      end
    end
    # /digital_assets/search?content_type[]=777,content_type[]=666
    context 'content_type' do
      before do
        @second = FactoryGirl.create :digital_asset, :guid => 'some-new-asset_134'
        @second.documents.clear
        @second.documents << FactoryGirl.build(:document)
        @second.save!
      end
      it 'returns all documents for a single content type' do
        get :search, :doctype => '666'
        assigns(:digital_assets).should == [digital_asset]
      end
      it 'returns all documents for a set of multiple content_types' do
        get :search, :doctype => ['666', '777']
        assigns(:digital_assets).should include(@second)
        assigns(:digital_assets).should include(digital_asset)
        # assigns(:digital_assets).entries.count.should be(2)
      end
    end
    context 'sami_code' do
      before do
        3.times { FactoryGirl.create :digital_asset, :sami_code => 'SOMETHING.001' }
      end
      it 'returns all documents with a particular sami_code' do
        get :search, :sami => 'SOMETHING.001'
        assigns(:digital_assets).size.should be(3)
      end
    end
    context 'fund_ids' do
      before do
        2.times { FactoryGirl.create :digital_asset, :fund_ids => ['1234', '4567'] }
        2.times { FactoryGirl.create :digital_asset, :fund_ids => ['1234', '2323'] }
        1.times { FactoryGirl.create :digital_asset, :fund_ids => ['9999'] }
      end
      it 'returns all documents with a particular fund_ids' do
        get :search, :funds => '1234'
        assigns(:digital_assets).size.should be(4)
      end
      it 'returns all documents for a set of multiple fund_ids' do
        get :search, :funds => ['1234', '9999']
        assigns(:digital_assets).size.should be(5)
      end
      it 'returns all documents for a set of multiple fund_ids' do
        get :search, :funds => ['7777', '9999']
        assigns(:digital_assets).size.should be(1)
      end
    end
    context 'audience' do
      before do
        3.times { FactoryGirl.create :digital_asset, :audiences => ['492'] }
      end
      it 'returns all documents with a particular audience' do
        get :search, :audience => '492'
        assigns(:digital_assets).size.should be(3)
      end
    end
    context 'title' do
      it 'returns all documents with a particular title' do
        get :search, :title => 'Doc Title'
        assigns(:digital_assets).should include(digital_asset)
      end
    end
    context 'guid' do
      it 'returns all documents with a particular guid' do
        get :search, :guid => digital_asset.guid
        assigns(:digital_assets).entries.should == [digital_asset]
      end
    end
    context 'business owner' do
      it 'returns all documents with a particular business owner' do
        get :search, :business_owner => 'biz owner'
        assigns(:digital_assets).should include(digital_asset)
      end
    end
    context "combination searches" do
      before {5.times {FactoryGirl.create :digital_asset}}
      it 'returns and-ed results for multiple criteria' do
        get :search, :guid => digital_asset.guid, :title => digital_asset.title
        assigns(:digital_assets).entries.should == [digital_asset]
      end
      it 'returns multiple results' do
        get :search, :title => digital_asset.title, :audiences => digital_asset.audiences, :sami => digital_asset.sami_code
        assigns(:digital_assets).size.should be(6)
      end
      it 'returns nothing if not all criteria match' do
        get :search, :guid => 'blargh-blargh-blargh', :title => 'Doc Title'
        assigns(:digital_assets).entries.should == []
      end
    end
  end

  describe 'sync_assets' do
    context 'no tuple files' do
      it 'makes no updates' do
        pending 'finish specs for DA polling code'
        # expect {
        #   get :sync_assets 
        #   }.to_not change(DigitalAsset, :count)
      end
    end
    context 'bulk file' do
      before do
        # touch the bulk file
        # FileUtils.touch Dir.glob()
      end
      it 'updates the count by the # of docs in the bulk' do
        pending 'add specs for bulk files'
        # expect {
        #   get :sync_assets 
        #   }.to change(DigitalAsset, :count).by(200)
      end
    end
    context 'bulk + selective' do
      before do
        # load bulk file into the temp dir
        # load the selective file into the dir
      end
      it 'doesnt re-add existing docs from the selective' do
        pending 'completion of file polling code'
        # expect {
        #   get :sync_assets 
        #   }.to_not change(DigitalAsset, :count)
      end
    end
  end

end
