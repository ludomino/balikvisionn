xml.instruct! :xml, version: "1.0"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.changefreq "weekly"
    xml.priority "1.0"
  end

  xml.url do
    xml.loc about_url
    xml.changefreq "monthly"
    xml.priority "0.5"
  end

  @categories.each do |category|
    xml.url do
      xml.loc category_url(category)
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end

  @subcategories.each do |subcategory|
    xml.url do
      xml.loc category_subcategory_url(subcategory.category, subcategory)
      xml.changefreq "weekly"
      xml.priority "0.7"
    end
  end
end
