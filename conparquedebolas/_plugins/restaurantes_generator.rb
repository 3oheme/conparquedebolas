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
      self.data["title"] = data["nombre"]
    end
  end

  class RestaurantesGenerator < Generator
    safe true

    def generate(site)
      site.data["cadiz"].each do |r|
        site.pages << RestaurantePage.new(site, site.source, r["slug"], r)
      end
    end
  end
end
