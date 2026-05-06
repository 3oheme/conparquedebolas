module Jekyll
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
      self.data["restaurantes"] = restaurantes
    end
  end

  class RestaurantesGenerator < Generator
    safe true

    def generate(site)
      site.data["cadiz"].each do |r|
        site.pages << RestaurantePage.new(site, site.source, r["slug"], r)
      end

      site.data["cadiz"].group_by { |r| r["ciudad"] }.each do |ciudad, restaurantes|
        slug = Jekyll::Utils.slugify(ciudad)
        site.pages << CiudadPage.new(site, site.source, slug, ciudad, restaurantes)
      end
    end
  end
end
