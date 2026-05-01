# Idempotent seeds for farms and coffees used by QR-code product pages
farm = Farm.find_or_initialize_by(name: 'Sítio Santa Rita')
farm.description = <<~DESC
  Sítio Santa Rita — produtor familiar. Atualize a descrição com informações reais da fazenda.
DESC
farm.slug = 'sitio-santa-rita'
farm.save!

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
