Rails.configuration.to_prepare do
  ActiveModel::Type.register(:media_post_types, MediaPostType)
end
