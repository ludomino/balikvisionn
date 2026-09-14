# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

if User.count.zero?
  email = ENV.fetch("ADMIN_EMAIL") { "admin@example.com" if Rails.env.development? }
  password = ENV.fetch("ADMIN_PASSWORD") { "password123" if Rails.env.development? }

  if email && password
    User.create!(email_address: email, password: password)
    puts "Admin user created: #{email}"
  else
    puts "Skipping admin user creation: set ADMIN_EMAIL and ADMIN_PASSWORD env vars."
  end
else
  puts "Admin user already exists, skipping."
end
