namespace :photos do
  desc "Migre l'ancien has_many_attached (Subcategory#photos) vers des Photo"
  task migrate_from_attachments: :environment do
    old_attachments = ActiveStorage::Attachment
      .where(record_type: "Subcategory", name: "photos")
      .order(:record_id, :id)
      .group_by(&:record_id)

    total = 0

    old_attachments.each do |subcategory_id, attachments|
      subcategory = Subcategory.find_by(id: subcategory_id)

      unless subcategory
        puts "Sous-catégorie ##{subcategory_id} introuvable, ignorée."
        next
      end

      attachments.each_with_index do |attachment, position|
        photo = subcategory.photos.create!(colspan: 1, position: position)
        photo.image.attach(attachment.blob) # réutilise le blob existant
        total += 1
      end

      attachments.each(&:destroy) # jamais .purge : blob partagé avec Photo
    end

    puts "#{total} photo(s) migrée(s)."
  end
end
