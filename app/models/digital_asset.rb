require 'mongoid'

class DigitalAsset
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :changed_at, type: Time
  field :audiences, type: Array, default: []
  field :sami_code, type: String
  field :product_ids, type: Array, default: []
  field :published_at, type: Time
  field :unpublished_at, type: Time
  field :expires_at, type: Time  
  field :guid, type: String
  field :fund_ids, type: Array, default: []
  field :business_owner, type: String
  field :summary, type: String

  key :guid

  # field :documents, type: Hash

  embeds_many :documents, :class_name => 'DigitalAsset::Document'

  accepts_nested_attributes_for :documents

  scope :title_is, ->(title) { where(:title => title)}
  scope :business_owner_is, ->(business_owner) { where(:business_owner => business_owner)}
  scope :guid_is, ->(guid) { where(:guid => guid)}
  scope :funds_in, ->(fund_id) { where(:fund_ids.in => fund_id)}
  scope :audience_in, ->(audience_id) {where(:audiences.in => audience_id)}
  scope :sami_is, ->(sami_code) {where(:sami_code => sami_code)}
  scope :path_is, ->(path) {where(:'documents.path' => path)}
  scope :doctype_in, ->(types) {where(:'documents.content_type'.in => types)}
  scope :product_in, ->(types) {where(:product_ids.in => types)}
  scope :stale, -> {where(:updated_at.lte => 2.minutes.ago)}

  # validations
  validates_presence_of :guid, :title, :changed_at, :published_at, 
      :expires_at, :audiences, :documents

  validate :validate_future_expiration

  # validates_uniqueness_of :guid

  def self.purge!
    # last_update = DigitalAsset.desc(:updated_at).try(:first).try :updated_at
    DigitalAsset.stale.destroy_all if bulk_processed?
  end

  def validate_future_expiration
    errors.add(:expires_at, "Expiration date must be at least 1 minute from now") unless expires_at and expires_at > 1.minute.from_now
  end

  def self.bulk_processed?
    (stale.count.to_f / self.count) <= 0.05
  end
end

class DigitalAsset::Document
  include Mongoid::Document

  field :path, type: String
  field :doc_changed_at, type: Time
  field :content_type, type: String
  embedded_in :digital_asset

  key :path

  validates_uniqueness_of :path

  validates_presence_of :path #, :doc_changed_at, :content_type
  validates_format_of :path, without: /\/manifest|archives\// # dont accept manifest files

end
