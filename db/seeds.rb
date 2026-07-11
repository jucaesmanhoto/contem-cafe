user = User.find_or_create_by(email: "t@t.com")
user.update(password: "123456", role: "admin")

# Idempotent seeds for farms and coffees used by QR-code product pages
farm = Farm.find_or_initialize_by(name: 'Sítio Santa Rita')
farm.description = <<~DESC
  Sítio Santa Rita — produtor familiar. Atualize a descrição com informações reais da fazenda.
DESC
farm.city = 'Espera Feliz'
farm.slug = 'sitio-santa-rita'
farm.save!
farm.photo.attach(io: File.open(Rails.root.join('app/assets/images/farms/sitio-santa-rita.jpg')), filename: 'sitio-santa-rita.jpg')

farm.coffees.find_or_initialize_by(name: 'Castanhas').tap do |c|
  c.description = 'Notas de castanha, corpo médio, final achocolatado.'
  c.variety = 'Catuaí'
  c.processing = 'Natural'
  c.altitude = 1200
  c.save!
end

farm.coffees.find_or_initialize_by(name: 'Floral').tap do |c|
  c.description = 'Perfil floral, acidez delicada e final limpo.'
  c.variety = 'Bourbon'
  c.processing = 'Pulped Natural'
  c.altitude = 1250
  c.save!
end

puts "Seeded farm: #{farm.name} with #{farm.coffees.count} coffees"

farm = Farm.find_or_initialize_by(name: 'Fazenda Jangada')
farm.description = <<~DESC
  Fazenda Jangada — produtor familiar. Atualize a descrição com informações reais da fazenda.
DESC
farm.city = 'Cabo Verde'
farm.slug = 'fazenda-jangada'
farm.save!
farm.photo.attach(io: File.open(Rails.root.join('app/assets/images/farms/ivan-santana.webp')), filename: 'ivan-santana.webp')

farm.coffees.find_or_initialize_by(name: 'JG22').tap do |c|
  c.description = 'Notas de castanha, corpo médio, final achocolatado.'
  c.variety = 'Catuaí amarelo'
  c.processing = 'Natural'
  c.altitude = 950
  c.save!
end

farm.coffees.find_or_initialize_by(name: 'JG25').tap do |c|
  c.description = 'Perfil floral, acidez delicada e final limpo.'
  c.variety = 'Bourbon'
  c.processing = 'Pulped Natural'
  c.altitude = 1250
  c.save!
end

puts "Seeded farm: #{farm.name} with #{farm.coffees.count} coffees"
