require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '購入情報' do
    before do
      @order = FactoryBot.build(:order)
    end

    it 'item_idは一意であること' do
      @order.save
      another_order = FactoryBot.build(:order, item: @order.item)
      another_order.valid?

      expect(another_order.errors[:item_id]).to include('has already been taken')
    end
  end
end
