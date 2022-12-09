module Carts
  class RemovesController < ApplicationController
    def destroy
      if product_found?
        cart_item = current_cart.cart_items.find_by(product_id: params[:product])
        cart_item.destroy
      end
    end

    private

    def product_found?
      Product.exists?(params[:product])
    end
  end
end

