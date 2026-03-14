class OrderAddress
  include ActiveModel::Model
  attr_accessor :user_id, :item_id, :post_code, :prefecture_id, :city, :block, :building, :phone_number, :token

  validates :user_id, presence: true
  validates :item_id, presence: true
  validates :token, presence: true
  validates :post_code, presence: true
  validates :post_code, format: { with: /\A\d{3}-\d{4}\z/, message: 'is invalid. Enter it as follows (e.g. 123-4567)' }
  validates :prefecture_id, numericality: { other_than: 1, message: "can't be blank" }
  validates :city, presence: true
  validates :block, presence: true
  validates :phone_number, presence: true
  validates :phone_number, length: { minimum: 10, message: 'is too short' }
  validates :phone_number, format: { with: /\A\d+\z/, message: 'is invalid. Input only number' }
  validates :phone_number, length: { maximum: 11 }, allow_blank: true

  def save
    ActiveRecord::Base.transaction do
      order = Order.create!(user_id: user_id, item_id: item_id)
      Address.create!(post_code: post_code, prefecture_id: prefecture_id, city: city, block: block, building: building,
                      phone_number: phone_number, order_id: order.id)
    end
    true
  end
end
