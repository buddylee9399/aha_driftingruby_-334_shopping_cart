# Drifting ruby - #334 shopping cart
- https://www.driftingruby.com/episodes/shopping-cart-with-turbo

## start
- rails new aha_driftingruby_#334_shopping_cart
- rails g scaffold Category name
- rails g scaffold Product name price:decimal category:references
- update migration
```
t.decimal :price, precision: 8, scale: 2
```
- rails db:migrate
- create seeds file
- rails g controller Welcome index
```
  root to: 'welcome#index'
```

- update welcome controller

```
  def index
    @products = Product.all
  end
```

- update the index html

```
<div class="row">
	<div class="col-12 col-lg-3">
		Filtering
	</div>
	<div class="col-12 col-lg-9">
		<%= render "products/display", products: @products %>
	</div>
</div>
```

- create products/display partial

```
<%= turbo_frame_tag "products_display" do %>
  <div class="row">
    <% products.each_slice(3) do |product_group| %>
      <% product_group.each do |product| %>
        <div class="col-12 col-md-6 col-lg-4">
          <div class="card mb-5">
            <%#= image_tag product.image, class: "card-img-top" %>
            <div class="card-body">
              <h5 class="card-title">
                <%= product.name %><br>
                <%= number_to_currency(product.price) %>
              <h5>
              <p class="card-text">Some quick example text to build on the card title and make up the bulk of the card's content.</p>
              <%= button_to "Add to Cart", "#", class: "btn btn-primary" %>
            </div>
          </div>
        </div>
      <% end %>
    <% end %>
  </div>
<% end %>
```

- update layouts/app by adding bootstrap

```
head**
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <link href="https://unpkg.com/dropzone@6.0.0-beta.1/dist/dropzone.css" rel="stylesheet" type="text/css" />    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>


  <body class='bg-light'>
    <div class="container bg-white border pb-3">
      <%= render 'layouts/navigation' %>
      <% flash.each do |type, msg| %>
        <% if type == 'alert' %>
          <%= content_tag :div, msg, class: "alert alert-danger", role: :alert %>
          <% else %>
          <%= content_tag :div, msg, class: "alert alert-primary", role: :alert %>
        <% end %>
      <% end %>
      <%= yield %>
    </div>
  </body>
```

- create layouts/navigation partial

```
<nav class="navbar navbar-expand-lg navbar-light py-4">
  <div class="container-fluid">
    <a class="navbar-brand" href="#" data-config-id="brand">
      <%#= image_tag 'logo.png', class: 'img-fluid' %>
      Drifting Ruby
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="nav">
      <ul class="d-none d-lg-flex navbar-nav mt-3 mt-lg-0 mb-3 mb-lg-0">
        <%= render 'layouts/navigation_links' %>
      </ul>
      <ul class="navbar-nav mt-3 mt-lg-0 mb-3 mb-lg-0 d-lg-none">
        <%= render 'layouts/navigation_links' %>
      </ul>
    </div>
  </div>
</nav>
```

- create layouts/navigation_links partial

```
<li class="nav-item me-4">
  <%= link_to "Home", root_path, class: 'nav-link' %>
</li>
<li class="nav-item me-4">
  <%= link_to "Products", products_path, class: 'nav-link' %>
</li>
```

- active storage
- rails active_storage:install
- rails db:migrate
- update product.rb

```
  has_one_attached :image
```

- update product form
```
<%= form_with(model: product) do |form| %>
  <div class="mb-3">
    <%= form.label :name, class: 'form-label' %>
    <%= form.text_field :name, class: 'form-control' %>
  </div>

  <div class="mb-3">
    <%= form.label :price, class: 'form-label' %>
    <%= form.text_field :price, class: 'form-control' %>
  </div>

  <div class="mb-3">
    <%= form.label :category_id, class: 'form-label' %>
    <%= form.text_field :category_id, class: 'form-control' %>
  </div>

  <div class="mb-3">
    <%= form.label :image, class: 'form-label' %>
    <%= form.file_field :image, class: 'form-control' %>
  </div>

  <div class="actions">
    <%= form.submit class: 'btn btn-primary' %>
  </div>
<% end %>
```

- update products controller

```
params.require(:product).permit(:name, :price, :category_id, :image)
```
### - ended the setup of the app

## CREATING THE CART
- rails g model cart token:uniq
- rails g model cart_items cart:belongs_to product:belongs_to quantity:integer
- update the migration

```
t.integer :quantity, default: 0
```

- update the routes
```
  namespace :carts do
    resource :add, only: :create
  end  
```

- update cart.rb
```
	has_secure_token
	has_many :cart_items, dependent: :destroy
```

- create the controllers/carts folder
- create carts/adds_controller

```


module Carts
  class AddsController < ApplicationController
    def create
      if product_found?
        cart_item = current_cart.cart_items.find_or_initialize_by(product_id: params[:product])
        cart_item.quantity += 1
        cart_item.save
      end
    end

    private

    def product_found?
      Product.exists?(params[:product])
    end
  end
end


```

- update application controller

```
  helper_method :current_cart
  def current_cart
    cart = Cart.find_or_create_by(token: cookies[:cart_token])
    cookies[:cart_token] ||= cart.token
    cart
  end
```

- update the display partial

```
<%= button_to "Add to Cart", carts_add_path, params: { product: product }, class: "btn btn-primary" %>
```

- update the welcome/index, at the top

```
<%= render "carts/checkout_button" %>
```
- create views/carts folder
- create carts/checkout_button.html.erb partial
```
<div class="mb-3">
  <%= link_to "#", class: "btn btn-outline-dark" do %>
    <div class="badge bg-primary">
      <%= render "carts/item_count", count: current_cart.quantity %>
    </div>
    Checkout
  <% end %>
</div>
```

- update cart.rb

```
  def quantity
    cart_items.sum(&:quantity)
  end
```

- create the carts/item_count partial

```
<%= content_tag :div, count, id: "cart_count" %>
```

- refresh the home page, press any 'add to cart' button, refresh the page and we should see the checkout update by 1
- we want it in real time so the user doesnt refresh the page
- update welcome index with

```
<%= turbo_stream_from current_cart %>
```

- update cart_item.rb

```
  after_create_commit do
    broadcast_replace_to cart,
                         target: "cart_count",
                         partial: "carts/item_count",
                         locals: { count: cart.quantity }
  end

  after_update_commit do
    broadcast_replace_to cart,
                         target: "cart_count",
                         partial: "carts/item_count",
                         locals: { count: cart.quantity }
  end
```

- refresh the welcome index page and press any add to cart
- we should see the checkout update
- update routes

```
resource :checkout, only: :show
```
- create checkouts_controller.rb
```


class CheckoutsController < ApplicationController
  def show
  end
end
```

- create the views/checkouts folder
- create checkouts/show file

```
<%= turbo_stream_from current_cart %>
<div class="py-16 px-6 px-md-14 bg-white">
  <div class="d-flex mb-12 align-items-center">
    <h3 class="mb-0">Order summary</h3>
    <span class="flex-shrink-0 d-inline-flex ms-4 align-items-center justify-content-center rounded-circle bg-primary text-white" style="width: 32px; height: 32px;">
      <%= render "carts/item_count", count: current_cart.quantity %>
    </span>
  </div>
  <div class="mb-12 pb-16 border-bottom">
    ITEMS
  </div>
  <div class="mb-12">
    <div class="mb-10">
      <div class="py-3 px-10 rounded-pill">
        <div class="d-flex justify-content-between">
          <span class="lead fw-bold" data-config-id="row4">Total</span>
          TOTAL PRICE
        </div>
      </div>
    </div>
  </div>

  <a class="btn btn-primary w-100 text-uppercase" href="#" data-config-id="primary-action">Confirm Order</a>
</div>
```

- go to /checkout, we should see the page
- update the checkouts/show page

```
 <div class="mb-12 pb-16 border-bottom">
    <% current_cart.cart_items.each do |cart_item| %>
      <%= render "carts/item_line", cart_item: cart_item %>
    <% end %>
  </div>
```

- and with the price

```
     <div class="d-flex justify-content-between">
          <span class="lead fw-bold" data-config-id="row4">Total</span>
          <%= render "carts/total_price" %>
        </div>
```

- create the partial carts/item_line

```
<%= turbo_stream_from current_cart %>
<div class="py-16 px-6 px-md-14 bg-white">
  <div class="d-flex mb-12 align-items-center">
    <h3 class="mb-0">Order summary</h3>
    <span class="flex-shrink-0 d-inline-flex ms-4 align-items-center justify-content-center rounded-circle bg-primary text-white" style="width: 32px; height: 32px;">
      <%= render "carts/item_count", count: current_cart.quantity %>
    </span>
  </div>
 <div class="mb-12 pb-16 border-bottom">
    <% current_cart.cart_items.each do |cart_item| %>
      <%= render "carts/item_line", cart_item: cart_item %>
    <% end %>
  </div>
  <div class="mb-12">
    <div class="mb-10">
      <div class="py-3 px-10 rounded-pill">
     		<div class="d-flex justify-content-between">
          <span class="lead fw-bold" data-config-id="row4">Total</span>
          <%#= render "carts/total_price" %>
        </div>
      </div>
    </div>
  </div>

  <a class="btn btn-primary w-100 text-uppercase" href="#" data-config-id="primary-action">Confirm Order</a>
</div>
```

- refresh the page, we should see it
- update the page with the actual content

```
<%= content_tag :div, class: "row mb-8 align-items-center", id: dom_id(cart_item) do %>
  <div class="align-self-stretch col-12 col-lg-3 mb-4 mb-md-0">
    <%= image_tag cart_item.product.image, class: "img-fluid", style: "max-width: 100px" %>
  </div>
  <div class="col-12 col-md-9">
    <div class="d-flex justify-content-between">
      <div class="pe-2">
        <h3 class="mb-2 lead fw-bold"><%= cart_item.product.name %></h3>
      </div>
      <div>
        <span class="lead text-info fw-bold"><%= number_to_currency(cart_item.product.price) %></span>
        REMOVE ITEM
      </div>
    </div>
    <div class="d-flex align-items-center justify-content-between">
      <div></div>
      <div class="d-inline-flex align-items-center px-4 fw-bold text-secondary border rounded-2">
        -
        <div class="form-control m-0 px-2 py-4 text-center text-md-end border-0">
          XX
        </div>
        +
      </div>
    </div>
  </div>
<% end %>
```

- refresh the page
- ADDING THE ABILITY TO REDUCE AND ADD PRODUCT COUNT IN THE CHECKOUT PAGE
- update the routes

```
  namespace :carts do
    resource :add, only: :create
    resource :reduce, only: :create
    resource :remove, only: :destroy
  end
```

- update the carts/line_item partial with the final code

```
<%= content_tag :div, class: "row mb-8 align-items-center", id: dom_id(cart_item) do %>
  <div class="align-self-stretch col-12 col-lg-3 mb-4 mb-md-0">
    <%= image_tag cart_item.product.image, class: "img-fluid", style: "max-width: 100px" %>
  </div>
  <div class="col-12 col-md-9">
    <div class="d-flex justify-content-between">
      <div class="pe-2">
        <h3 class="mb-2 lead fw-bold"><%= cart_item.product.name %></h3>
      </div>
      <div>
        <span class="lead text-info fw-bold"><%= number_to_currency(cart_item.product.price) %></span>
        <%= button_to "remove",
          carts_remove_path,
          params: { product: cart_item.product },
          method: :delete %>
      </div>
    </div>
    <div class="d-flex align-items-center justify-content-between">
      <div></div>
      <div class="d-inline-flex align-items-center px-4 fw-bold text-secondary border rounded-2">
        <%= button_to "-", carts_reduce_path, params: { product: cart_item.product }, class: "btn px-0 py-2" %>
        <div class="form-control m-0 px-2 py-4 text-center text-md-end border-0">
          <%= render "carts/item_quantity", cart_item: cart_item %>
        </div>
        <%= button_to "+", carts_add_path, params: { product: cart_item.product }, class: "btn px-0 py-2" %>
      </div>
    </div>
  </div>
<% end %>
```

- create the partial carts/item_quantity

```
<%= content_tag :span, cart_item.quantity, id: dom_id(cart_item, "quantity") %>
```

- create the carts/removes_controller.rb

```
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
```

- update cart_item.rb

```
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  after_create_commit do
    broadcast_replace_to cart,
                         target: "cart_count",
                         partial: "carts/item_count",
                         locals: { count: cart.quantity }
  end

  after_update_commit do
    broadcast_replace_to cart,
                         target: "cart_count",
                         partial: "carts/item_count",
                         locals: { count: cart.quantity }
  end

  after_destroy_commit do 
    broadcast_remove_to cart
    broadcast_replace_to cart,
                         target: "cart_count",
                         partial: "carts/item_count",
                         locals: { count: cart.quantity }
  end
end

```

- refresh the checkout page and press the remove button
- it worked
- update the checkout_button partial to fix the homepage checkout button

```
<%= link_to checkout_path, class: "btn btn-outline-dark" do %>
```

- create the carts/reduces_controller.rb
```
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
```

- update the cart_item.rb with the final code, theres a few extra steps that will be coming up, in here

```
class CartItem < ApplicationRecord
  # since we are using this: target: dom_id(self, "quantity")
  # below, we need to include this include
  include ActionView::RecordIdentifier

  belongs_to :cart
  belongs_to :product

  after_create_commit do
    update_item_count
    update_total_price
  end

  after_update_commit do
    update_item_count
    update_total_price
    broadcast_replace_to cart,
                         target: dom_id(self, "quantity"),
                         partial: "carts/item_quantity",
                         locals: { cart_item: self }
  end

  after_destroy_commit do
    broadcast_remove_to cart
    update_item_count
    update_total_price
  end

  def total_price
    quantity.to_i * product.price.to_f
  end

  private

  def update_total_price
    broadcast_replace_to cart,
                         target: "total_price",
                         partial: "carts/total_price",
                         locals: { current_cart: cart }
  end

  def update_item_count
    broadcast_replace_to cart,
                         target: "cart_count",
                         partial: "carts/item_count",
                         locals: { count: cart.quantity }
  end
end
```

- create the partial carts/total_price 

```
<span class="fw-bold" id="total_price">
  <%= number_to_currency(current_cart.cart_items.sum(&:total_price)) %>
</span>
```
- update checkouts/show

```
     		<div class="d-flex justify-content-between">
          <span class="lead fw-bold" data-config-id="row4">Total</span>
          <%= render "carts/total_price" %>
        </div>
```

- refresh the checkout page, and increment item, remove, the total should update, the cart should update and the total price
- WE ARE DONE WITH THE SHOPPPING CART
- ADDING THE FILTERING
- add the routes

```
  post :search, to: "searches#show"
```

- update welcome/index with the search form

```
<%= turbo_stream_from current_cart %>
<%= render "carts/checkout_button" %>

<div class="row">
  <div class="col-12 col-lg-3">
    <%= turbo_frame_tag "filtering" do %>
      <div class="h3">Filtering</div>
      <%= form_for :search, url: search_path do |f| %>
        <div class="input-group mb-3">
          <%= f.text_field :query, class: "form-control" %>
          <%= f.submit "Search", class: "btn btn-outline-secondary" %>
        </div>

        <%= f.select :sort, [
            ["Price Low to High", :price_lth],
            ["Price High to Low", :price_htl]
          ], { include_blank: true },
          class: "form-select mb-3" %>


        <div class="h4">Price</div>
        <ul class="list-group mb-3">

          <li class="list-group-item">
            <div class="form-check">
              <%= f.check_box :price, { multiple: true, class: "form-check-input" } ,
                "lt1000", nil %>
              <%= f.label :price, "< $1000", class: "form-check-label" %>
            </div>
          </li>

          <li class="list-group-item">
            <div class="form-check">
              <%= f.check_box :price, { multiple: true, class: "form-check-input" } ,
                "bewteen1000and2500", nil %>
              <%= f.label :price, "$1000 - $2500", class: "form-check-label" %>
            </div>
          </li>

          <li class="list-group-item">
            <div class="form-check">
              <%= f.check_box :price, { multiple: true, class: "form-check-input" } ,
                "gt2500", nil %>
              <%= f.label :price, "> $2500", class: "form-check-label" %>
            </div>
          </li>

        </ul>

        <div class="h4">Category</div>
        <ul class="list-group mb-3">
          <% Category.all.each do |category| %>
            <li class="list-group-item">
              <div class="form-check">
                <%= f.check_box :category_id, { multiple: true, class: "form-check-input" } ,
                  category.id, nil %>
                <%= f.label :category_id, category.name, class: "form-check-label" %>
              </div>
            </li>
           <% end %>
        </ul>

      <% end %>
    <% end %>
  </div>
  <div class='col-12 col-lg-9'>
    <%= render "products/display", products: @products %>
  </div>
</div>
```

- create the searches controller

```
class SearchesController < ApplicationController
  def show
    @products = ProductSearch.call(params)
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "products_display",
          partial: "products/display",
          locals: { products: @products }
        )
      }
    end
  end
end
```

- create file models/product_search.rb

```


class ProductSearch
  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    products
      .where(search_condition)
      .where(price_condition)
      .where(category_condition)
      .order(sort_condition)
  end

  private

  def products
    @products ||= Product.includes(image_attachment: :blob).all
  end

  def search_condition
    return unless @params.dig(:search, :query)

    ["name LIKE ?", "%#{@params.dig(:search, :query)}%"]
  end

  def price_condition
    return unless @params.dig(:search, :price)
    conditions = [].tap do |array|
      array << (..1000) if @params.dig(:search, :price).include?("lt1000")
      array << (1000..2500) if @params.dig(:search, :price).include?("bewteen1000and2500")
      array << (2500..) if @params.dig(:search, :price).include?("gt2500")
    end
    { price: conditions }
  end

  def category_condition
    return unless @params.dig(:search, :category_id)

    { category_id: @params.dig(:search, :category_id) }
  end

  def sort_condition
    return unless @params.dig(:search, :sort)

    case @params.dig(:search, :sort)
    when "price_lth"
      { price: :asc }
    when "price_htl"
      { price: :desc }
    end
  end



end
```

- update welcome controller, index action

```
@products = ProductSearch.call(params)
```

- update the welcome index

```
  <div class='col-12 col-lg-9'>
    <%= render "products/display", products: @products %>
  </div>
```

- make sure the display partial has the turbo frame

```
<%= turbo_frame_tag "products_display" do %>
	....
<% end %>
```
- refresh the welcome page and test the search
- IT WORKED

## THE END
