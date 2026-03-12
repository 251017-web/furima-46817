class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:index, :create]
  before_action :check_permission, only: [:index, :create]

  def index
    @order_address = OrderAddress.new
  end

  def create
    @order_address = OrderAddress.new(order_params)
    return render :index, status: :unprocessable_entity unless @order_address.valid?

    charge = pay_item

    if @order_address.save
      redirect_to root_path
    else
      refund_charge(charge)
      render :index, status: :unprocessable_entity
    end
  rescue Payjp::PayjpError
    @order_address.errors.add(:base, '決済に失敗しました')
    render :index, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    refund_charge(charge) if charge
    @order_address.errors.add(:base, '商品はすでに購入されています')
    render :index, status: :unprocessable_entity
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def check_permission
    return unless current_user.id == @item.user_id || @item.order.present?

    redirect_to root_path
  end

  def order_params
    params.require(:order_address).permit(:post_code, :prefecture_id, :city, :block, :building, :phone_number).merge(
      user_id: current_user.id, item_id: params[:item_id], token: params[:token]
    )
  end

  def refund_charge(charge)
    charge.refund
  rescue Payjp::PayjpError => e
    Rails.logger.error("Charge refund failed for charge_id=#{charge.id}: #{e.message}")
    @order_address.errors.add(:base, '購入処理に失敗しました')
  end

  def pay_item
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    Payjp::Charge.create(
      amount: @item.price,
      card: @order_address.token,
      currency: 'jpy'
    )
  end
end
