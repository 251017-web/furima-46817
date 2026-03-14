require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  let(:buyer) { FactoryBot.create(:user) }
  let(:seller) { FactoryBot.create(:user) }
  let(:item) { FactoryBot.create(:item, user: seller) }
  let(:charge) { double('Payjp::Charge', id: 'ch_test_123', refund: true) }
  let(:basic_auth_header) do
    ActionController::HttpAuthentication::Basic.encode_credentials('admin', '2222')
  end
  let(:order_address_params) do
    {
      order_address: {
        post_code: '123-4567',
        prefecture_id: 2,
        city: '横浜市',
        block: '青山1-1-1',
        building: '柳ビル103',
        phone_number: '09012345678'
      },
      token: 'tok_test_123'
    }
  end

  before do
    ENV['BASIC_AUTH_USER'] = 'admin'
    ENV['BASIC_AUTH_PASSWORD'] = '2222'
    sign_in buyer
    allow(Payjp::Charge).to receive(:create).and_return(charge)
  end

  describe 'POST /items/:item_id/orders' do
    it '決済成功かつ保存成功でトップページに遷移すること' do
      post item_orders_path(item), params: order_address_params, headers: { 'HTTP_AUTHORIZATION' => basic_auth_header }

      expect(response).to redirect_to(root_path)
      expect(Payjp::Charge).to have_received(:create)
      expect(Order.count).to eq(1)
      expect(Address.count).to eq(1)
    end

    it '決済成功後に保存失敗した場合は返金して購入画面を再表示すること' do
      allow_any_instance_of(OrderAddress).to receive(:save) do |instance|
        instance.errors.add(:base, '商品はすでに購入されています')
        false
      end

      post item_orders_path(item), params: order_address_params, headers: { 'HTTP_AUTHORIZATION' => basic_auth_header }

      expect(charge).to have_received(:refund)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it '決済失敗時は返金せず購入画面を再表示すること' do
      allow(Payjp::Charge).to receive(:create).and_raise(Payjp::PayjpError.new('payment failed'))

      post item_orders_path(item), params: order_address_params, headers: { 'HTTP_AUTHORIZATION' => basic_auth_header }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Order.count).to eq(0)
      expect(Address.count).to eq(0)
    end

    it '保存時に競合例外が起きても返金して購入画面を再表示すること' do
      allow_any_instance_of(OrderAddress).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

      post item_orders_path(item), params: order_address_params, headers: { 'HTTP_AUTHORIZATION' => basic_auth_header }

      expect(charge).to have_received(:refund)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
