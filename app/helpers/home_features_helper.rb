module HomeFeaturesHelper
  def home_feature_public_path(home_feature)
    featurable = home_feature.featurable

    case featurable
    when Category
      category_path(featurable)
    when Subcategory
      category_path(featurable.category)
    when Photo
      category_path(featurable.subcategory.category)
    end
  end
end
