# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Only seed in development environment
return unless Rails.env.development?

puts "🌱 Starting seed process..."

# Clean existing data (optional - comment out if you want to keep existing data)
puts "🧹 Cleaning existing data..."
CoffeeCategory.destroy_all
CoffeeVariant.destroy_all
Coffee.destroy_all
Category.destroy_all
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

# Create Categories for each Roaster
puts "\n🏷️  Creating Categories..."

# Café del Valle - Categorías enfocadas en origen
puts "\n   📂 Café del Valle Categories:"
valle_cats = {
  single_origin: roasters[0].categories.find_or_create_by!(name: 'Single Origin') do |c|
    c.description = 'Cafés de un solo origen o finca'
    c.color = '#FF6B35'
    c.icon = '🌍'
    c.position = 1
  end,
  blends: roasters[0].categories.find_or_create_by!(name: 'Blends Especiales') do |c|
    c.description = 'Mezclas cuidadosamente seleccionadas'
    c.color = '#4ECDC4'
    c.icon = '🎨'
    c.position = 2
  end,
  limited: roasters[0].categories.find_or_create_by!(name: 'Edición Limitada') do |c|
    c.description = 'Micro-lotes y cosechas exclusivas'
    c.color = '#FFD700'
    c.icon = '⭐'
    c.position = 3
  end,
  organic: roasters[0].categories.find_or_create_by!(name: 'Orgánico') do |c|
    c.description = 'Cafés certificados orgánicos'
    c.color = '#95E1D3'
    c.icon = '🌱'
    c.position = 4
  end
}
puts "      ✓ 4 categories created for Café del Valle"

# Tostadores Premium - Categorías por perfil de tueste
puts "\n   📂 Tostadores Premium Categories:"
premium_cats = {
  espresso: roasters[1].categories.find_or_create_by!(name: 'Para Espresso') do |c|
    c.description = 'Perfiles ideales para máquina de espresso'
    c.color = '#8B4513'
    c.icon = '☕'
    c.position = 1
  end,
  filter: roasters[1].categories.find_or_create_by!(name: 'Para Filtrado') do |c|
    c.description = 'Perfectos para métodos de filtrado'
    c.color = '#DDA15E'
    c.icon = '💧'
    c.position = 2
  end,
  decaf: roasters[1].categories.find_or_create_by!(name: 'Descafeinado') do |c|
    c.description = 'Cafés descafeinados de alta calidad'
    c.color = '#BC6C25'
    c.icon = '🌙'
    c.position = 3
  end,
  premium: roasters[1].categories.find_or_create_by!(name: 'Premium Selection') do |c|
    c.description = 'Lo mejor de nuestra selección'
    c.color = '#FFD60A'
    c.icon = '👑'
    c.position = 4
  end
}
puts "      ✓ 4 categories created for Tostadores Premium"

# Aroma Coffee Roasters - Categorías experimentales
puts "\n   📂 Aroma Coffee Roasters Categories:"
aroma_cats = {
  experimental: roasters[2].categories.find_or_create_by!(name: 'Experimental') do |c|
    c.description = 'Procesos innovadores y fermentaciones'
    c.color = '#B565D8'
    c.icon = '🔬'
    c.position = 1
  end,
  natural: roasters[2].categories.find_or_create_by!(name: 'Natural Process') do |c|
    c.description = 'Cafés procesados naturalmente'
    c.color = '#E63946'
    c.icon = '☀️'
    c.position = 2
  end,
  honey: roasters[2].categories.find_or_create_by!(name: 'Honey Process') do |c|
    c.description = 'Proceso honey: dulzura natural'
    c.color = '#F4A261'
    c.icon = '🍯'
    c.position = 3
  end
}
puts "      ✓ 3 categories created for Aroma Coffee Roasters"

# Mountain Brew Co. - Categorías por intensidad
puts "\n   📂 Mountain Brew Co. Categories:"
mountain_cats = {
  light: roasters[3].categories.find_or_create_by!(name: 'Tueste Claro') do |c|
    c.description = 'Tostado ligero, notas brillantes'
    c.color = '#F4E285'
    c.icon = '🌅'
    c.position = 1
  end,
  medium: roasters[3].categories.find_or_create_by!(name: 'Tueste Medio') do |c|
    c.description = 'Balance perfecto'
    c.color = '#C68B59'
    c.icon = '☕'
    c.position = 2
  end,
  dark: roasters[3].categories.find_or_create_by!(name: 'Tueste Oscuro') do |c|
    c.description = 'Intenso y con cuerpo'
    c.color = '#3E2723'
    c.icon = '🔥'
    c.position = 3
  end
}
puts "      ✓ 3 categories created for Mountain Brew Co."

# Create Coffees and their Variants
puts "\n☕ Creating Coffees and Variants..."

# Café del Valle - Coffees
puts "\n   🌱 Café del Valle Coffees:"

coffee1 = roasters[0].coffees.find_or_create_by!(name: 'Ethiopian Yirgacheffe') do |c|
  c.description = 'Café brillante y floral con notas de bergamota y jazmín. Proceso lavado que resalta su acidez cítrica.'
  c.origin_country = 'Ethiopia'
  c.varietal = 'Heirloom'
  c.process_method = 'Washed'
  c.roast_level = 'Light'
  c.flavor_notes = 'Bergamota, Jazmín, Limón, Té Earl Grey'
  c.featured = true
  c.is_active = true
end
coffee1.categories << [ valle_cats[:single_origin], valle_cats[:limited] ]
coffee1.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 16.99; v.stock = 45 }
coffee1.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '500g') { |v| v.price = 30.99; v.stock = 30 }
coffee1.coffee_variants.find_or_create_by!(grind_type: 'Filter', bag_size: '250g') { |v| v.price = 16.99; v.stock = 25 }
puts "      ✓ Ethiopian Yirgacheffe (Featured) - 3 variants"

coffee2 = roasters[0].coffees.find_or_create_by!(name: 'Colombian Supremo') do |c|
  c.description = 'Café suave y balanceado con dulzura de caramelo. El clásico colombiano de las montañas de Antioquia.'
  c.origin_country = 'Colombia'
  c.varietal = 'Caturra'
  c.process_method = 'Washed'
  c.roast_level = 'Medium'
  c.flavor_notes = 'Caramelo, Chocolate, Nueces, Panela'
  c.featured = true
  c.is_active = true
end
coffee2.categories << [ valle_cats[:single_origin] ]
coffee2.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 14.99; v.stock = 60 }
coffee2.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '1kg') { |v| v.price = 52.99; v.stock = 20 }
coffee2.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '250g') { |v| v.price = 14.99; v.stock = 40 }
coffee2.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '500g') { |v| v.price = 27.99; v.stock = 35 }
puts "      ✓ Colombian Supremo (Featured) - 4 variants"

coffee3 = roasters[0].coffees.find_or_create_by!(name: 'House Blend Valle') do |c|
  c.description = 'Nuestra mezcla insignia. Equilibrio perfecto entre cuerpo y acidez para el día a día.'
  c.origin_country = 'Multiple'
  c.varietal = 'Blend'
  c.process_method = 'Mixed'
  c.roast_level = 'Medium'
  c.flavor_notes = 'Chocolate con Leche, Avellanas, Frutas Dulces'
  c.featured = false
  c.is_active = true
end
coffee3.categories << [ valle_cats[:blends] ]
coffee3.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 12.99; v.stock = 80 }
coffee3.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '500g') { |v| v.price = 23.99; v.stock = 50 }
coffee3.coffee_variants.find_or_create_by!(grind_type: 'Filter', bag_size: '250g') { |v| v.price = 12.99; v.stock = 30 }
puts "      ✓ House Blend Valle - 3 variants"

coffee4 = roasters[0].coffees.find_or_create_by!(name: 'Organic Peru') do |c|
  c.description = 'Café orgánico certificado de comercio justo. Suave y con notas dulces naturales.'
  c.origin_country = 'Peru'
  c.varietal = 'Typica'
  c.process_method = 'Washed'
  c.roast_level = 'Medium-Light'
  c.flavor_notes = 'Miel, Almendras, Cítricos Suaves'
  c.featured = false
  c.is_active = true
end
coffee4.categories << [ valle_cats[:organic], valle_cats[:single_origin] ]
coffee4.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 15.49; v.stock = 40 }
coffee4.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '500g') { |v| v.price = 28.99; v.stock = 25 }
puts "      ✓ Organic Peru - 2 variants"

# Tostadores Premium - Coffees
puts "\n   🔥 Tostadores Premium Coffees:"

coffee5 = roasters[1].coffees.find_or_create_by!(name: 'Espresso Intenso') do |c|
  c.description = 'Blend premium para espresso. Cuerpo completo, crema densa y persistente.'
  c.origin_country = 'Brazil, Colombia'
  c.varietal = 'Blend'
  c.process_method = 'Mixed'
  c.roast_level = 'Medium-Dark'
  c.flavor_notes = 'Chocolate Oscuro, Frutos Secos, Caramelo Tostado'
  c.featured = true
  c.is_active = true
end
coffee5.categories << [ premium_cats[:espresso], premium_cats[:premium] ]
coffee5.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 17.99; v.stock = 55 }
coffee5.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '250g') { |v| v.price = 17.99; v.stock = 70 }
coffee5.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '1kg') { |v| v.price = 64.99; v.stock = 15 }
puts "      ✓ Espresso Intenso (Featured) - 3 variants"

coffee6 = roasters[1].coffees.find_or_create_by!(name: 'Kenya AA Nyeri') do |c|
  c.description = 'Micro-lote de la región de Nyeri. Acidez vibrante tipo vino con complejidad increíble.'
  c.origin_country = 'Kenya'
  c.varietal = 'SL28, SL34'
  c.process_method = 'Washed'
  c.roast_level = 'Light-Medium'
  c.flavor_notes = 'Grosella Negra, Vino Tinto, Tomate Cherry, Cítricos'
  c.featured = true
  c.is_active = true
end
coffee6.categories << [ premium_cats[:filter], premium_cats[:premium] ]
coffee6.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 21.99; v.stock = 30 }
coffee6.coffee_variants.find_or_create_by!(grind_type: 'Filter', bag_size: '250g') { |v| v.price = 21.99; v.stock = 25 }
puts "      ✓ Kenya AA Nyeri (Featured) - 2 variants"

coffee7 = roasters[1].coffees.find_or_create_by!(name: 'Decaf Swiss Water Colombia') do |c|
  c.description = 'Descafeinado por proceso Swiss Water. Mantiene todo el sabor sin la cafeína.'
  c.origin_country = 'Colombia'
  c.varietal = 'Castillo'
  c.process_method = 'Washed (Swiss Water Decaf)'
  c.roast_level = 'Medium'
  c.flavor_notes = 'Chocolate, Caramelo, Nuez'
  c.featured = false
  c.is_active = true
end
coffee7.categories << [ premium_cats[:decaf] ]
coffee7.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 16.99; v.stock = 35 }
coffee7.coffee_variants.find_or_create_by!(grind_type: 'Filter', bag_size: '250g') { |v| v.price = 16.99; v.stock = 30 }
coffee7.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '250g') { |v| v.price = 16.99; v.stock = 25 }
puts "      ✓ Decaf Swiss Water Colombia - 3 variants"

# Aroma Coffee Roasters - Coffees
puts "\n   🔬 Aroma Coffee Roasters Coffees:"

coffee8 = roasters[2].coffees.find_or_create_by!(name: 'Gesha Anaerobic Fermentation') do |c|
  c.description = 'Proceso experimental con fermentación anaeróbica de 96 horas. Perfil de sabor único y exótico.'
  c.origin_country = 'Panama'
  c.varietal = 'Gesha'
  c.process_method = 'Anaerobic Natural'
  c.roast_level = 'Light'
  c.flavor_notes = 'Fruta de la Pasión, Rosa, Lichi, Piña, Vino Blanco'
  c.featured = true
  c.is_active = true
end
coffee8.categories << [ aroma_cats[:experimental] ]
coffee8.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 45.99; v.stock = 12 }
puts "      ✓ Gesha Anaerobic (Featured) - 1 variant"

coffee9 = roasters[2].coffees.find_or_create_by!(name: 'Brazil Natural Pulped') do |c|
  c.description = 'Natural pulped de Brasil. Dulzor intenso y cuerpo sedoso.'
  c.origin_country = 'Brazil'
  c.varietal = 'Catuaí Rojo'
  c.process_method = 'Pulped Natural'
  c.roast_level = 'Light-Medium'
  c.flavor_notes = 'Fresas, Chocolate con Leche, Caramelo, Miel'
  c.featured = false
  c.is_active = true
end
coffee9.categories << [ aroma_cats[:natural] ]
coffee9.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 18.99; v.stock = 40 }
coffee9.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '250g') { |v| v.price = 18.99; v.stock = 30 }
puts "      ✓ Brazil Natural Pulped - 2 variants"

coffee10 = roasters[2].coffees.find_or_create_by!(name: 'Costa Rica Honey Black') do |c|
  c.description = 'Proceso honey black: secado completo con todo el mucílago. Dulzor extremo.'
  c.origin_country = 'Costa Rica'
  c.varietal = 'Caturra, Catuaí'
  c.process_method = 'Black Honey'
  c.roast_level = 'Light-Medium'
  c.flavor_notes = 'Melaza, Frutas Tropicales, Ron, Caña de Azúcar'
  c.featured = false
  c.is_active = true
end
coffee10.categories << [ aroma_cats[:honey] ]
coffee10.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 19.99; v.stock = 35 }
puts "      ✓ Costa Rica Honey Black - 1 variant"

# Mountain Brew Co. - Coffees
puts "\n   ⛰️  Mountain Brew Co. Coffees:"

coffee11 = roasters[3].coffees.find_or_create_by!(name: 'Chiapas High Altitude') do |c|
  c.description = 'Café de altura de Chiapas. Cultivo a más de 1,600 msnm con certificación de comercio justo.'
  c.origin_country = 'Mexico'
  c.varietal = 'Bourbon, Typica'
  c.process_method = 'Washed'
  c.roast_level = 'Light'
  c.flavor_notes = 'Manzana Verde, Almendra, Azúcar Morena, Cacao'
  c.featured = true
  c.is_active = true
end
coffee11.categories << [ mountain_cats[:light] ]
coffee11.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 15.99; v.stock = 50 }
coffee11.coffee_variants.find_or_create_by!(grind_type: 'Filter', bag_size: '500g') { |v| v.price = 29.99; v.stock = 30 }
puts "      ✓ Chiapas High Altitude (Featured) - 2 variants"

coffee12 = roasters[3].coffees.find_or_create_by!(name: 'Oaxaca Medium Roast') do |c|
  c.description = 'Balance perfecto de acidez y cuerpo. Ideal para todas las preparaciones.'
  c.origin_country = 'Mexico'
  c.varietal = 'Mundo Novo, Caturra'
  c.process_method = 'Washed'
  c.roast_level = 'Medium'
  c.flavor_notes = 'Chocolate, Avellana, Naranja, Miel'
  c.featured = false
  c.is_active = true
end
coffee12.categories << [ mountain_cats[:medium] ]
coffee12.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 13.99; v.stock = 60 }
coffee12.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '1kg') { |v| v.price = 49.99; v.stock = 20 }
coffee12.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '250g') { |v| v.price = 13.99; v.stock = 45 }
puts "      ✓ Oaxaca Medium Roast - 3 variants"

coffee13 = roasters[3].coffees.find_or_create_by!(name: 'Dark Mountain Blend') do |c|
  c.description = 'Tueste oscuro para los que buscan intensidad. Bajo en acidez, alto en cuerpo.'
  c.origin_country = 'Mexico, Guatemala'
  c.varietal = 'Blend'
  c.process_method = 'Mixed'
  c.roast_level = 'Dark'
  c.flavor_notes = 'Chocolate Amargo, Nuez Tostada, Tabaco Dulce, Especias'
  c.featured = false
  c.is_active = true
end
coffee13.categories << [ mountain_cats[:dark] ]
coffee13.coffee_variants.find_or_create_by!(grind_type: 'Whole Bean', bag_size: '250g') { |v| v.price = 14.99; v.stock = 45 }
coffee13.coffee_variants.find_or_create_by!(grind_type: 'Espresso', bag_size: '500g') { |v| v.price = 27.99; v.stock = 30 }
puts "      ✓ Dark Mountain Blend - 2 variants"

puts "\n📊 Coffee & Variants Summary:"
puts "   • Total Categories: #{Category.count}"
puts "   • Total Coffees: #{Coffee.count}"
puts "   • Featured Coffees: #{Coffee.featured.count}"
puts "   • Total Variants: #{CoffeeVariant.count}"
puts "   • Total Stock Units: #{CoffeeVariant.sum(:stock)}"

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
puts "\n" + "="*70
puts "✅ Seed completed successfully!"
puts "="*70
puts "\n📊 Summary:"
puts "   👥 Users & Memberships:"
puts "      • Total Users: #{User.count}"
puts "      • Coffee Lovers (no memberships): #{User.coffee_lovers_only.count}"
puts "      • Roaster Members: #{User.roaster_members.count}"
puts "      • Memberships created: #{RoasterMembership.count}"
puts "\n   🏪 Roasters & Products:"
puts "      • Roasters: #{Roaster.count}"
puts "      • Categories: #{Category.count}"
puts "      • Coffees: #{Coffee.count}"
puts "      • Featured Coffees: #{Coffee.featured.count}"
puts "      • Coffee Variants: #{CoffeeVariant.count}"
puts "      • Total Stock Units: #{CoffeeVariant.sum(:stock)}"
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
puts "\n☕ Coffee Products by Roaster:"
Roaster.all.each do |roaster|
  puts "   • #{roaster.name}: #{roaster.coffees.count} coffees, #{roaster.categories.count} categories"
end

puts "\n🚀 Ready to test the API!"
puts "="*70
