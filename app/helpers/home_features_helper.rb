module HomeFeaturesHelper
  def home_feature_public_path(home_feature)
    featurable = home_feature.featurable

    case featurable
    when Category
      category_path(featurable)
    when Subcategory
      category_subcategory_path(featurable.category, featurable)
    when Photo
      category_subcategory_path(featurable.subcategory.category, featurable.subcategory)
    end
  end
end
