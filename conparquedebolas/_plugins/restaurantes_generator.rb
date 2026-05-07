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

  def self.has_en(r)
    !r["por_que_kids_friendly_en"].to_s.strip.empty?
  end

  class RestaurantePage < Page
    def initialize(site, base, slug, data, lang)
      @site = site
      @base = base
      @dir  = lang == "en" ? File.join("en", "restaurantes", slug) : File.join("restaurantes", slug)
      @name = "index.html"
      process(@name)
      read_yaml(File.join(base, "_layouts"), "restaurante.html")
      self.data.merge!(data)
      self.data["lang"] = lang
      if lang == "en"
        self.data["title"]         = data["nombre"]
        self.data["description"]   = data["por_que_kids_friendly_en"]
        self.data["alternate_url"] = "/restaurantes/#{slug}/"
      else
        self.data["title"]         = data["nombre"]
        self.data["description"]   = data["por_que_kids_friendly"]
        self.data["has_en"]        = Jekyll.has_en(data)
        self.data["alternate_url"] = "/en/restaurantes/#{slug}/"
      end
    end
  end

  class CiudadPage < Page
    def initialize(site, base, slug, ciudad, restaurantes, lang)
      @site = site
      @base = base
      @dir  = lang == "en" ? File.join("en", "ciudades", slug) : File.join("ciudades", slug)
      @name = "index.html"
      process(@name)
      read_yaml(File.join(base, "_layouts"), "ciudad.html")
      t = site.data["i18n"][lang]
      self.data["ciudad"]       = ciudad
      self.data["ciudad_slug"]  = slug
      self.data["restaurantes"] = restaurantes
      self.data["lang"]         = lang
      if lang == "en"
        self.data["title"]         = "#{t['restaurantes_en']} #{ciudad}"
        self.data["description"]   = "#{restaurantes.size} #{t['restaurantes_label']} in #{ciudad}."
        self.data["alternate_url"] = "/ciudades/#{slug}/"
      else
        self.data["title"]         = "#{t['restaurantes_en']} #{ciudad}"
        self.data["description"]   = "Los mejores restaurantes kids-friendly en #{ciudad}."
        self.data["has_en"]        = restaurantes.any? { |r| Jekyll.has_en(r) }
        self.data["alternate_url"] = "/en/ciudades/#{slug}/"
      end
    end
  end

  class TagPage < Page
    def initialize(site, base, tag_key, restaurantes, lang)
      @site    = site
      @base    = base
      tag_slug = TAG_SLUGS[tag_key]
      @dir     = lang == "en" ? File.join("en", "con", tag_slug) : File.join("con", tag_slug)
      @name    = "index.html"
      process(@name)
      read_yaml(File.join(base, "_layouts"), "filtro.html")
      t         = site.data["i18n"][lang]
      tag_label = t["tags"][tag_key]
      self.data["tag_key"]      = tag_key
      self.data["restaurantes"] = restaurantes
      self.data["lang"]         = lang
      if lang == "en"
        self.data["title"]            = "#{t['restaurantes_con']} #{tag_label} in Cádiz"
        self.data["description"]      = "#{restaurantes.size} #{t['restaurantes_label']} with #{tag_label.downcase} in Cádiz."
        self.data["alternate_url"]    = "/con/#{tag_slug}/"
        self.data["breadcrumb_url"]   = "/en/"
        self.data["breadcrumb_label"] = t["todas_ciudades"]
      else
        self.data["title"]            = "#{t['restaurantes_con']} #{tag_label} en Cádiz"
        self.data["description"]      = "#{restaurantes.size} restaurantes kids-friendly en Cádiz con #{tag_label.downcase}."
        self.data["has_en"]           = restaurantes.any? { |r| Jekyll.has_en(r) }
        self.data["alternate_url"]    = "/en/con/#{tag_slug}/"
        self.data["breadcrumb_url"]   = "/"
        self.data["breadcrumb_label"] = t["todas_ciudades"]
      end
    end
  end

  class CiudadTagPage < Page
    def initialize(site, base, ciudad_slug, ciudad, tag_key, restaurantes, lang)
      @site    = site
      @base    = base
      tag_slug = TAG_SLUGS[tag_key]
      @dir     = lang == "en" ? File.join("en", "ciudades", ciudad_slug, "con", tag_slug) : File.join("ciudades", ciudad_slug, "con", tag_slug)
      @name    = "index.html"
      process(@name)
      read_yaml(File.join(base, "_layouts"), "filtro.html")
      t         = site.data["i18n"][lang]
      tag_label = t["tags"][tag_key]
      self.data["tag_key"]      = tag_key
      self.data["restaurantes"] = restaurantes
      self.data["lang"]         = lang
      if lang == "en"
        self.data["title"]            = "Restaurants in #{ciudad} with #{tag_label}"
        self.data["description"]      = "#{restaurantes.size} #{t['restaurantes_label']} in #{ciudad} with #{tag_label.downcase}."
        self.data["alternate_url"]    = "/ciudades/#{ciudad_slug}/con/#{tag_slug}/"
        self.data["breadcrumb_url"]   = "/en/ciudades/#{ciudad_slug}/"
        self.data["breadcrumb_label"] = ciudad
      else
        self.data["title"]            = "#{t['restaurantes_en']} #{ciudad} con #{tag_label}"
        self.data["description"]      = "#{restaurantes.size} restaurantes kids-friendly en #{ciudad} con #{tag_label.downcase}."
        self.data["has_en"]           = restaurantes.any? { |r| Jekyll.has_en(r) }
        self.data["alternate_url"]    = "/en/ciudades/#{ciudad_slug}/con/#{tag_slug}/"
        self.data["breadcrumb_url"]   = "/ciudades/#{ciudad_slug}/"
        self.data["breadcrumb_label"] = ciudad
      end
    end
  end

  class HomePageEN < Page
    def initialize(site, base, ciudades)
      @site = site
      @base = base
      @dir  = "en"
      @name = "index.html"
      process(@name)
      read_yaml(File.join(base, "_layouts"), "home.html")
      self.data["lang"]          = "en"
      self.data["title"]         = "Kid-friendly restaurants in Cádiz"
      self.data["description"]   = "The best places to eat with children in the province of Cádiz."
      self.data["alternate_url"] = "/"
      self.data["ciudades"]      = ciudades
    end
  end

  class RestaurantesGenerator < Generator
    safe true

    def generate(site)
      todos = site.data["cadiz"]

      todos.each do |r|
        site.pages << RestaurantePage.new(site, site.source, r["slug"], r, "es")
        site.pages << RestaurantePage.new(site, site.source, r["slug"], r, "en") if Jekyll.has_en(r)
      end

      todos.group_by { |r| r["ciudad"] }.each do |ciudad, restaurantes|
        slug = Jekyll::Utils.slugify(ciudad, mode: "latin")
        site.pages << CiudadPage.new(site, site.source, slug, ciudad, restaurantes, "es")
        en_rs = restaurantes.select { |r| Jekyll.has_en(r) }
        site.pages << CiudadPage.new(site, site.source, slug, ciudad, en_rs, "en") unless en_rs.empty?
      end

      TAG_SLUGS.each_key do |tag_key|
        con_tag = todos.select { |r| r.dig("tags", tag_key) }
        next if con_tag.empty?
        site.pages << TagPage.new(site, site.source, tag_key, con_tag, "es")
        en_con_tag = con_tag.select { |r| Jekyll.has_en(r) }
        site.pages << TagPage.new(site, site.source, tag_key, en_con_tag, "en") unless en_con_tag.empty?
      end

      todos.group_by { |r| r["ciudad"] }.each do |ciudad, restaurantes_ciudad|
        ciudad_slug = Jekyll::Utils.slugify(ciudad, mode: "latin")
        TAG_SLUGS.each_key do |tag_key|
          con_tag = restaurantes_ciudad.select { |r| r.dig("tags", tag_key) }
          next if con_tag.empty?
          site.pages << CiudadTagPage.new(site, site.source, ciudad_slug, ciudad, tag_key, con_tag, "es")
          en_con_tag = con_tag.select { |r| Jekyll.has_en(r) }
          site.pages << CiudadTagPage.new(site, site.source, ciudad_slug, ciudad, tag_key, en_con_tag, "en") unless en_con_tag.empty?
        end
      end

      en_ciudades = todos.select { |r| Jekyll.has_en(r) }
                         .group_by { |r| r["ciudad"] }
                         .map { |ciudad, rs|
                           { "ciudad" => ciudad,
                             "slug"   => Jekyll::Utils.slugify(ciudad, mode: "latin"),
                             "restaurantes" => rs }
                         }
      site.pages << HomePageEN.new(site, site.source, en_ciudades) unless en_ciudades.empty?
    end
  end
end
