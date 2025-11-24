# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Only seed in development environment
return unless Rails.env.development?

puts "🌱 Starting seed process..."

# Clean existing data (optional - comment out if you want to keep existing data)
puts "🧹 Cleaning existing data..."
RoasterMembership.destroy_all
Roaster.destroy_all
User.where.not(email: 'admin@example.com').destroy_all

# Create Admin User
puts "👤 Creating Admin User..."
admin = AdminUser.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
end
puts "   ✓ Admin created: #{admin.email}"

# Create Users
puts "\n👥 Creating Users..."

users_data = [
  { email: 'maria.owner@koffy.com', name: 'María González', password: 'password123' },
  { email: 'juan.manager@koffy.com', name: 'Juan Pérez', password: 'password123' },
  { email: 'ana.barista@koffy.com', name: 'Ana Martínez', password: 'password123' },
  { email: 'carlos.barista@koffy.com', name: 'Carlos Rodríguez', password: 'password123' },
  { email: 'lucia.member@koffy.com', name: 'Lucía Torres', password: 'password123' },
  { email: 'pedro.owner@koffy.com', name: 'Pedro Silva', password: 'password123' },
  { email: 'sofia.manager@koffy.com', name: 'Sofía Ramírez', password: 'password123' },
  { email: 'diego.barista@koffy.com', name: 'Diego Vargas', password: 'password123' },
  { email: 'valentina.barista@koffy.com', name: 'Valentina López', password: 'password123' },
  { email: 'miguel.member@koffy.com', name: 'Miguel Hernández', password: 'password123' }
]

users = users_data.map do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.name = user_data[:name]
    u.password = user_data[:password]
    u.password_confirmation = user_data[:password]
    u.confirmed_at = Time.now # Auto-confirm for development
    u.provider = 'email'
  end
  puts "   ✓ User created: #{user.name} (#{user.email})"
  user
end

# Create Coffee Lovers (Users without roaster memberships)
puts "\n☕ Creating Coffee Lovers (users without roaster memberships)..."

coffee_lovers_data = [
  { 
    email: 'laura.coffee@gmail.com', 
    name: 'Laura Jiménez', 
    password: 'password123',
    preferred_grind_method: 'French Press',
    preferred_roast_level: 'Medium',
    preferred_bag_size: '250g'
  },
  { 
    email: 'roberto.espresso@gmail.com', 
    name: 'Roberto Díaz', 
    password: 'password123',
    preferred_grind_method: 'Espresso',
    preferred_roast_level: 'Dark',
    preferred_bag_size: '500g'
  },
  { 
    email: 'camila.pour@gmail.com', 
    name: 'Camila Morales', 
    password: 'password123',
    preferred_grind_method: 'Pour Over',
    preferred_roast_level: 'Light',
    preferred_bag_size: '250g'
  },
  { 
    email: 'fernando.aeropress@gmail.com', 
    name: 'Fernando Castro', 
    password: 'password123',
    preferred_grind_method: 'AeroPress',
    preferred_roast_level: 'Medium-Light',
    preferred_bag_size: '500g'
  },
  { 
    email: 'isabel.coldbrew@gmail.com', 
    name: 'Isabel Ruiz', 
    password: 'password123',
    preferred_grind_method: 'Cold Brew',
    preferred_roast_level: 'Medium-Dark',
    preferred_bag_size: '1kg'
  },
  { 
    email: 'daniel.moka@gmail.com', 
    name: 'Daniel Ortiz', 
    password: 'password123',
    preferred_grind_method: 'Moka Pot',
    preferred_roast_level: 'Dark',
    preferred_bag_size: '250g'
  },
  { 
    email: 'andrea.chemex@gmail.com', 
    name: 'Andrea Sánchez', 
    password: 'password123',
    preferred_grind_method: 'Chemex',
    preferred_roast_level: 'Light',
    preferred_bag_size: '500g'
  },
  { 
    email: 'gabriel.turkish@gmail.com', 
    name: 'Gabriel Medina', 
    password: 'password123',
    preferred_grind_method: 'Turkish',
    preferred_roast_level: 'Medium',
    preferred_bag_size: '250g'
  }
]

coffee_lovers = coffee_lovers_data.map do |lover_data|
  user = User.find_or_create_by!(email: lover_data[:email]) do |u|
    u.name = lover_data[:name]
    u.password = lover_data[:password]
    u.password_confirmation = lover_data[:password]
    u.confirmed_at = Time.now # Auto-confirm for development
    u.preferred_grind_method = lover_data[:preferred_grind_method]
    u.preferred_roast_level = lover_data[:preferred_roast_level]
    u.preferred_bag_size = lover_data[:preferred_bag_size]
    u.provider = 'email'
  end
  puts "   ✓ Coffee Lover: #{user.name} (#{user.email}) - #{user.preferred_grind_method} / #{user.preferred_roast_level}"
  user
end

# Create Roasters
puts "\n🏢 Creating Roasters..."

roasters_data = [
  {
    name: 'Café del Valle',
    location: 'Medellín, Colombia',
    description: 'Tostador artesanal especializado en cafés de origen colombiano con procesos sostenibles.'
  },
  {
    name: 'Tostadores Premium',
    location: 'Bogotá, Colombia',
    description: 'Especialistas en tueste medio y alto para cafés especiales de exportación.'
  },
  {
    name: 'Aroma Coffee Roasters',
    location: 'Buenos Aires, Argentina',
    description: 'Tostadores boutique enfocados en micro-lotes y cafés experimentales.'
  },
  {
    name: 'Mountain Brew Co.',
    location: 'Ciudad de México, México',
    description: 'Tostadores de altura especialistas en cafés de Chiapas y Oaxaca.'
  }
]

roasters = roasters_data.map do |roaster_data|
  roaster = Roaster.find_or_create_by!(name: roaster_data[:name]) do |r|
    r.location = roaster_data[:location]
    r.description = roaster_data[:description]
    r.active = true
  end
  puts "   ✓ Roaster created: #{roaster.name}"
  roaster
end

# Create Roaster Memberships with different roles and salary types
puts "\n💼 Creating Roaster Memberships..."

# Roaster 1: Café del Valle
puts "\n   📋 Café del Valle Team:"

# Owner - Salario anual
membership1 = RoasterMembership.find_or_create_by!(
  user: users[0],
  roaster: roasters[0]
) do |m|
  m.role = 'owner'
  m.salary = 60000.00
  m.currency = 'USD'
  m.salary_period = 'annual'
  m.active = true
end
puts "      ✓ #{users[0].name} - Owner - $60,000/year"

# Manager - Salario mensual
membership2 = RoasterMembership.find_or_create_by!(
  user: users[1],
  roaster: roasters[0]
) do |m|
  m.role = 'manager'
  m.salary = 3000.00
  m.currency = 'USD'
  m.salary_period = 'monthly'
  m.active = true
end
puts "      ✓ #{users[1].name} - Manager - $3,000/month"

# Barista - Salario quincenal
membership3 = RoasterMembership.find_or_create_by!(
  user: users[2],
  roaster: roasters[0]
) do |m|
  m.role = 'barista'
  m.salary = 1200.00
  m.currency = 'USD'
  m.salary_period = 'biweekly'
  m.active = true
end
puts "      ✓ #{users[2].name} - Barista - $1,200/biweekly"

# Barista part-time - Salario por hora
membership4 = RoasterMembership.find_or_create_by!(
  user: users[3],
  roaster: roasters[0]
) do |m|
  m.role = 'barista'
  m.salary = 15.00
  m.currency = 'USD'
  m.salary_period = 'hourly'
  m.active = true
end
puts "      ✓ #{users[3].name} - Barista (PT) - $15/hour"

# Member
membership5 = RoasterMembership.find_or_create_by!(
  user: users[4],
  roaster: roasters[0]
) do |m|
  m.role = 'member'
  m.salary = 500.00
  m.currency = 'USD'
  m.salary_period = 'weekly'
  m.active = true
end
puts "      ✓ #{users[4].name} - Member - $500/week"

# Roaster 2: Tostadores Premium
puts "\n   📋 Tostadores Premium Team:"

membership6 = RoasterMembership.find_or_create_by!(
  user: users[5],
  roaster: roasters[1]
) do |m|
  m.role = 'owner'
  m.salary = 4500.00
  m.currency = 'USD'
  m.salary_period = 'monthly'
  m.active = true
end
puts "      ✓ #{users[5].name} - Owner - $4,500/month"

membership7 = RoasterMembership.find_or_create_by!(
  user: users[6],
  roaster: roasters[1]
) do |m|
  m.role = 'manager'
  m.salary = 2800.00
  m.currency = 'USD'
  m.salary_period = 'monthly'
  m.active = true
end
puts "      ✓ #{users[6].name} - Manager - $2,800/month"

membership8 = RoasterMembership.find_or_create_by!(
  user: users[7],
  roaster: roasters[1]
) do |m|
  m.role = 'barista'
  m.salary = 120.00
  m.currency = 'USD'
  m.salary_period = 'daily'
  m.active = true
end
puts "      ✓ #{users[7].name} - Barista - $120/day"

# Cross-membership: Juan también trabaja en Tostadores Premium
membership9 = RoasterMembership.find_or_create_by!(
  user: users[1],
  roaster: roasters[1]
) do |m|
  m.role = 'barista'
  m.salary = 18.00
  m.currency = 'USD'
  m.salary_period = 'hourly'
  m.active = true
end
puts "      ✓ #{users[1].name} - Barista (PT) - $18/hour (cross-membership)"

# Roaster 3: Aroma Coffee Roasters (Argentina - COP)
puts "\n   📋 Aroma Coffee Roasters Team:"

membership10 = RoasterMembership.find_or_create_by!(
  user: users[0],
  roaster: roasters[2]
) do |m|
  m.role = 'manager'
  m.salary = 350000.00
  m.currency = 'ARS'
  m.salary_period = 'monthly'
  m.active = true
end
puts "      ✓ #{users[0].name} - Manager - $350,000 ARS/month"

membership11 = RoasterMembership.find_or_create_by!(
  user: users[8],
  roaster: roasters[2]
) do |m|
  m.role = 'barista'
  m.salary = 15000.00
  m.currency = 'ARS'
  m.salary_period = 'weekly'
  m.active = true
end
puts "      ✓ #{users[8].name} - Barista - $15,000 ARS/week"

# Roaster 4: Mountain Brew Co. (México - MXN)
puts "\n   📋 Mountain Brew Co. Team:"

membership12 = RoasterMembership.find_or_create_by!(
  user: users[9],
  roaster: roasters[3]
) do |m|
  m.role = 'owner'
  m.salary = 45000.00
  m.currency = 'MXN'
  m.salary_period = 'monthly'
  m.active = true
end
puts "      ✓ #{users[9].name} - Owner - $45,000 MXN/month"

membership13 = RoasterMembership.find_or_create_by!(
  user: users[2],
  roaster: roasters[3]
) do |m|
  m.role = 'barista'
  m.salary = 200.00
  m.currency = 'MXN'
  m.salary_period = 'hourly'
  m.active = true
end
puts "      ✓ #{users[2].name} - Barista - $200 MXN/hour"

# Summary
puts "\n" + "="*60
puts "✅ Seed completed successfully!"
puts "="*60
puts "\n📊 Summary:"
puts "   • Users created: #{User.count}"
puts "   • Coffee Lovers (no memberships): #{User.coffee_lovers_only.count}"
puts "   • Roaster Members: #{User.roaster_members.count}"
puts "   • Roasters created: #{Roaster.count}"
puts "   • Memberships created: #{RoasterMembership.count}"
puts "\n💰 Salary Periods Distribution:"
RoasterMembership.group(:salary_period).count.each do |period, count|
  puts "   • #{period.capitalize}: #{count}"
end
puts "\n💱 Currencies Used:"
RoasterMembership.group(:currency).count.each do |currency, count|
  puts "   • #{currency}: #{count}"
end
puts "\n🔐 Login Credentials:"
puts "   Admin Panel: http://localhost:3000/admin"
puts "   Email: admin@example.com"
puts "   Password: password"
puts "\n   🏪 Roaster Member Users (all passwords: password123):"
users.first(5).each do |user|
  puts "   • #{user.email}"
end
puts "\n   ☕ Coffee Lover Users (all passwords: password123):"
coffee_lovers.first(5).each do |user|
  puts "   • #{user.email} - #{user.preferred_grind_method}"
end
puts "\n🚀 Ready to test the API!"
puts "="*60