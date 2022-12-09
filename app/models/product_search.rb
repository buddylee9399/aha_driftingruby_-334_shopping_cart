

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

