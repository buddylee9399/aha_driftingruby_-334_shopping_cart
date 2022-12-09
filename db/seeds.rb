# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

desktop = Category.create(name: "Desktop")
laptop = Category.create(name: "Laptop")
display = Category.create(name: "Display")

puts "#{Category.count} categories created"

Product.create(name: "iMac", price: 1299, category: desktop)
Product.create(name: "Mac mini", price: 699, category: desktop)
Product.create(name: "Mac Pro", price: 5999, category: desktop)
Product.create(name: "MacBook Air", price: 999, category: laptop)
Product.create(name: "MacBook Pro", price: 1999, category: laptop)
Product.create(name: "Pro Display XDR", price: 4999, category: display)

puts "#{Product.count} products created"
