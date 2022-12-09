

module Carts
  class ReducesController < ApplicationController
    def create
      if product_found?
        cart_item = current_cart.cart_items.find_or_initialize_by(product_id: params[:product])
        cart_item.quantity = [cart_item.quantity - 1, 1].max
        cart_item.save
      end
    end

    private

    def product_found?
      Product.exists?(params[:product])
    end
  end
end

