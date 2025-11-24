ActiveAdmin.register Review do
  # Permit parameters for create/update
  permit_params :user_id, :roaster_id, :rating, :comment

  # Index page configuration
  index do
    selectable_column
    id_column
    column :user do |review|
      link_to review.user.email, admin_user_path(review.user)
    end
    column :roaster do |review|
      link_to review.roaster.name, admin_roaster_path(review.roaster)
    end
    column :rating do |review|
      # Display rating with stars or formatted number
      "#{review.rating} / 5.0"
    end
    column :comment do |review|
      # Truncate long comments for better display
      if review.comment.present?
        truncate(review.comment, length: 50)
      else
        "No comment"
      end
    end
    column :created_at
    actions
  end

  # Filters for the index page
  filter :user
  filter :roaster
  filter :rating
  filter :created_at

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :user do |review|
        link_to review.user.email, admin_user_path(review.user)
      end
      row :roaster do |review|
        link_to review.roaster.name, admin_roaster_path(review.roaster)
      end
      row :rating do |review|
        "#{review.rating} / 5.0"
      end
      row :comment do |review|
        if review.comment.present?
          simple_format(review.comment)
        else
          "No comment provided"
        end
      end
      row :created_at
      row :updated_at
    end
  end

  # Form configuration
  form do |f|
    f.inputs "Review Details" do
      f.input :user, as: :select, collection: User.all.map { |u| [ u.email, u.id ] }
      f.input :roaster, as: :select, collection: Roaster.all.map { |r| [ r.name, r.id ] }
      f.input :rating, as: :number, step: 0.01, min: 0, max: 5,
              hint: "Rating must be between 0 and 5"
      f.input :comment, as: :text,
              hint: "Optional comment (max 2000 characters)"
    end
    f.actions
  end
end
