class Item < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category
  belongs_to :condition
  belongs_to :delivery_fee
  belongs_to :prefecture
  belongs_to :shipping_date

  belongs_to :user
  has_one_attached :image
  has_one :order

  validates :image, :name, :description, :price, presence: true
  validates :category_id, :condition_id, :delivery_fee_id, :prefecture_id, :shipping_date_id,
            numericality: { other_than: 1, message: "can't be blank" }

  validates :price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 300,
    less_than_or_equal_to: 9_999_999
  }
  validates :price, format: { with: /\A[0-9]+\z/ }
end
