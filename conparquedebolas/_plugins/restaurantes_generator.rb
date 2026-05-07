module Jekyll
  TAG_SLUGS = {
    "tronas"              => "tronas",
    "carta_infantil"      => "carta-infantil",
    "zona_juegos"         => "zona-juegos",
    "cambiador"           => "cambiador",
    "terraza"             => "terraza",
    "mascotas"            => "mascotas",
    "accesible"           => "accesible",
    "opciones_saludables" => "opciones-saludables"
  }.freeze

  TAG_LABELS = {
    "tronas"              => "Tronas",
    "carta_infantil"      => "Carta infantil",
    "zona_juegos"         => "Zona de juegos",
    "cambiador"           => "Cambiador",
    "terraza"             => "Terraza",
    "mascotas"            => "Mascotas",
    "accesible"           => "Accesible",
    "opciones_saludables" => "Opciones saludables"
  }.freeze

  TAG_ICONS = {
    "tronas"              => "🪑",
    "carta_infantil"      => "🧒",
    "zona_juegos"         => "🎮",
    "cambiador"           => "🚻",
    "terraza"             => "🌿",
    "mascotas"            => "🐶",
    "accesible"           => "♿",
    "opciones_saludables" => "🥗"
  }.freeze

  class RestaurantePage < Page
    def initialize(site, base, slug, data)
      @site = site
      @base = base
      @dir  = File.join("restaurantes", slug)
      @name = "index.html"

      process(@name)
      read_yaml(File.join(base, "_layouts"), "restaurante.html")
      self.data.merge!(data)
      self.data["title"]       = data["nombre"]
      self.data["description"] = data["por_que_kids_friendly"]
    end
  end

  class CiudadPage < Page
    def initialize(site, base, slug, ciudad, restaurantes)
      @site = site
      @base = base
      @dir  = File.join("ciudades", slug)
      @name = "index.html"

      process(@name)
      read_yaml(File.join(base, "_layouts"), "ciudad.html")
      self.data["title"]        = "Restaurantes en #{ciudad}"
      self.data["description"]  = "Los mejores restaurantes kids-friendly en #{ciudad}. Sitios para comer con niños con tronas, carta infantil y zonas de juego."
      self.data["ciudad"]       = ciudad
      self.data["ciudad_slug"]  = slug
      self.data["restaurantes"] = restaurantes
    end
  end

  class TagPage < Page
    def initialize(site, base, tag_key, restaurantes)
      @site = site
      @base = base
      tag_slug  = TAG_SLUGS[tag_key]
      tag_label = TAG_LABELS[tag_key]
      @dir  = File.join("con", tag_slug)
      @name = "index.html"

      process(@name)
      read_yaml(File.join(base, "_layouts"), "filtro.html")
      self.data["title"]            = "Restaurantes con #{tag_label} en Cádiz"
      self.data["description"]      = "#{restaurantes.size} restaurantes kids-friendly en Cádiz con #{tag_label.downcase}."
      self.data["breadcrumb_url"]   = "/"
      self.data["breadcrumb_label"] = "Todas las ciudades"
      self.data["tag_label"]        = tag_label
      self.data["restaurantes"]     = restaurantes
    end
  end

  class CiudadTagPage < Page
    def initialize(site, base, ciudad_slug, ciudad, tag_key, restaurantes)
      @site = site
      @base = base
      tag_slug  = TAG_SLUGS[tag_key]
      tag_label = TAG_LABELS[tag_key]
      @dir  = File.join("ciudades", ciudad_slug, "con", tag_slug)
      @name = "index.html"

      process(@name)
      read_yaml(File.join(base, "_layouts"), "filtro.html")
      self.data["title"]            = "Restaurantes en #{ciudad} con #{tag_label}"
      self.data["description"]      = "#{restaurantes.size} restaurantes kids-friendly en #{ciudad} con #{tag_label.downcase}."
      self.data["breadcrumb_url"]   = "/ciudades/#{ciudad_slug}/"
      self.data["breadcrumb_label"] = ciudad
      self.data["tag_label"]        = tag_label
      self.data["restaurantes"]     = restaurantes
    end
  end

  class RestaurantesGenerator < Generator
    safe true

    def generate(site)
      todos = site.data["cadiz"]

      todos.each do |r|
        site.pages << RestaurantePage.new(site, site.source, r["slug"], r)
      end

      todos.group_by { |r| r["ciudad"] }.each do |ciudad, restaurantes|
        slug = Jekyll::Utils.slugify(ciudad, mode: "latin")
        site.pages << CiudadPage.new(site, site.source, slug, ciudad, restaurantes)
      end

      TAG_SLUGS.each_key do |tag_key|
        con_tag = todos.select { |r| r.dig("tags", tag_key) }
        next if con_tag.empty?
        site.pages << TagPage.new(site, site.source, tag_key, con_tag)
      end

      todos.group_by { |r| r["ciudad"] }.each do |ciudad, restaurantes_ciudad|
        ciudad_slug = Jekyll::Utils.slugify(ciudad, mode: "latin")
        TAG_SLUGS.each_key do |tag_key|
          con_tag = restaurantes_ciudad.select { |r| r.dig("tags", tag_key) }
          next if con_tag.empty?
          site.pages << CiudadTagPage.new(site, site.source, ciudad_slug, ciudad, tag_key, con_tag)
        end
      end
    end
  end
end
