ActiveAdmin.register User do
  # Specify the parameters that should be permitted for assignment
  # Agregamos los parámetros de invitación
  permit_params :email, :name, :password, :password_confirmation, :invitation_limit

  # Define the index page (list of users)
  index do
    selectable_column
    id_column
    column :email
    column :name
    column :provider
    # Columna de confirmación
    column "Confirmation Status" do |user|
      if user.confirmed?
        status_tag("✓ Confirmed", class: 'ok')
      else
        status_tag("✗ Not Confirmed", class: 'error')
      end
    end
    # Columnas de invitación
    column "Invitation Status" do |user|
      if user.invitation_accepted_at
        status_tag("Accepted", class: 'ok')
      elsif user.invitation_sent_at
        status_tag("Pending", class: 'warning')
      else
        status_tag("Registered", class: 'default')
      end
    end
    column :invitations_count, label: "Invitaciones Enviadas"
    column :locked_at do |user|
      user.access_locked? ? status_tag("Locked", class: 'error') : status_tag("Active", class: 'ok')
    end
    column :created_at
    actions do |user|
      # Acción de confirmación
      unless user.confirmed?
        item "Confirm", confirm_admin_user_path(user), method: :put, class: "member_link"
      end
      # Acción de bloqueo/desbloqueo
      if user.access_locked?
        item "Unlock", unlock_admin_user_path(user), method: :put, class: "member_link"
      else
        item "Lock", lock_admin_user_path(user), method: :put, class: "member_link"
      end
    end
  end

  # Define filters for the index page
  filter :email
  filter :name
  filter :provider
  filter :confirmed_at, label: "Email Confirmed"
  filter :locked_at
  filter :invitation_accepted_at, label: "Invitation Accepted"
  filter :invitation_sent_at, label: "Invitation Sent"
  filter :invited_by_id, label: "Invited by (ID)"
  filter :created_at

  # Define the form for creating/editing users
  form do |f|
    f.inputs do
      f.input :email
      f.input :name
      f.input :provider, as: :select, collection: ['google', 'email'], include_blank: true
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  # Define the show page
  show do
    attributes_table do
      row :id
      row :email
      row :name
      row :provider
      row :uid
      row("Email Confirmed") do |user|
        if user.confirmed?
          status_tag("✓ Confirmed at #{user.confirmed_at&.strftime('%d/%m/%Y %H:%M')}", class: 'ok')
        else
          status_tag("✗ Not Confirmed at #{user.confirmed_at&.strftime('%d/%m/%Y %H:%M')}", class: 'error')
        end
      end
      row :confirmation_sent_at do |user|
        user.confirmation_sent_at&.strftime('%d/%m/%Y %H:%M') || "Not Sent"
      end
      row :failed_attempts
      row :locked_at
      row("Status") do |user|
        user.access_locked? ? status_tag("Locked", class: 'error') : status_tag("Active", class: 'ok')
      end
      row :created_at
      row :updated_at
    end
    
    # Panel de información de invitaciones
    panel "Invitation Information" do
      attributes_table_for user do
        row("Invitation Status") do |u|
          if u.invitation_accepted_at
            status_tag("Accepted at #{u.invitation_accepted_at&.strftime('%d/%m/%Y %H:%M')}", class: 'ok')
          elsif u.invitation_sent_at
            status_tag("Pending (sent at #{u.invitation_sent_at&.strftime('%d/%m/%Y %H:%M')})", class: 'warning')
          else
            status_tag("Registered directly", class: 'default')
          end
        end
        row("Invited by") do |u|
          if u.invited_by
            link_to u.invited_by.email, admin_user_path(u.invited_by)
          else
            "Not Invited"
          end
        end
        row("Invitations sent") { |u| u.invitations_count }
        row("Invitation limit") { |u| u.invitation_limit || "No limit" }
      end
    end
    
    panel "Confirmation Actions" do
      if user.confirmed?
        "✓ User already confirmed"
      else
        link_to "Confirm Manually", confirm_admin_user_path(user), method: :put, class: "button"
        text_node " "
        link_to "Resend Confirmation Email", resend_confirmation_admin_user_path(user), method: :put, class: "button"
      end
    end
    
    panel "Security Actions" do
      if user.access_locked?
        link_to "Unlock User", unlock_admin_user_path(user), method: :put, class: "button"
      else
        link_to "Lock User", lock_admin_user_path(user), method: :put, class: "button"
      end
    end
  end

  # Member actions to lock and unlock users
  member_action :lock, method: :put do
    resource.lock_access!
    redirect_to admin_user_path(resource), notice: "User locked successfully"
  end

  member_action :unlock, method: :put do
    resource.unlock_access!
    redirect_to admin_user_path(resource), notice: "User unlocked successfully"
  end

  # Member action para confirmar manualmente un usuario
  member_action :confirm, method: :put do
    if resource.confirmed?
      redirect_to admin_user_path(resource), alert: "User already confirmed"
    else
      resource.confirm
      redirect_to admin_user_path(resource), notice: "✅ User confirmed successfully"
    end
  end

  # Member action para reenviar email de confirmación
  member_action :resend_confirmation, method: :put do
    if resource.confirmed?
      redirect_to admin_user_path(resource), alert: "User already confirmed"
    else
      resource.send_confirmation_instructions
      redirect_to admin_user_path(resource), notice: "📧 Confirmation email reenviado exitosamente"
    end
  end

  # Collection action para invitar nuevos usuarios
  # Usamos GET porque necesitamos pasar el email como parámetro
  collection_action :invite_new_user, method: :get do
    email = params[:email]
    
    if email.present?
      # Intentamos invitar al usuario
      # No pasamos inviter porque current_admin_user es AdminUser, no User
      # Si necesitas rastrear quién invitó, usa la Opción 2 en los comentarios
      user = User.invite!({email: email})
      
      if user.errors.empty?
        redirect_to admin_users_path, notice: "✅ Invitation sent successfully to #{email}"
      else
        redirect_to admin_users_path, alert: "❌ Error: #{user.errors.full_messages.join(', ')}"
      end
    else
      redirect_to admin_users_path, alert: "⚠️ Email is required"
    end
  end
  
  # Agregar botón de invitar en la barra de acciones
  action_item :invite, only: :index do
    link_to "Invite User", "#", class: "button", onclick: "var email = prompt('Enter the email of the user to invite:'); if(email) { window.location.href = '/admin/users/invite_new_user?email=' + email; } return false;"
  end
end

