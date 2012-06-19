FactoryGirl.define do

  factory :document, :class => 'DigitalAsset::Document' do
    path '/some/crazy/file.path'
    doc_changed_at 2.days.ago
    content_type '777'
  end

  factory :digital_asset do
    title 'Doc Title'
    changed_at 2.days.ago
    audiences ['490']
    sequence(:guid) {|n| "guid-foobar-permanent-#{n}"} 
    published_at 10.days.ago
    expires_at 2.months.from_now
    fund_ids ['420']
    sami_code 'F0000.BAR'
    product_ids ['690', '420']
    business_owner 'biz owner'
    sequence(:documents) {|n|[DigitalAsset::Document.new(path: "/#{n}/foo/bar.txt", doc_changed_at: 2.days.ago, content_type: '666')]}
  end
end