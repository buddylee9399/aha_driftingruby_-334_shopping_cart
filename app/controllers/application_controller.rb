class ApplicationController < ActionController::Base
  helper_method :current_cart
  def current_cart
    cart = Cart.find_or_create_by(token: cookies[:cart_token])
    cookies[:cart_token] ||= cart.token
    cart
  end
end
