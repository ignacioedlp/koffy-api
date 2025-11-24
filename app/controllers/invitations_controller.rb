# Controller para manejar invitaciones de usuarios
# Devise Invitable viene con vistas HTML, pero como esta es una API,
# necesitamos nuestro propio controlador que responda con JSON
class InvitationsController < Devise::InvitationsController
  # Aseguramos que el usuario esté autenticado para enviar invitaciones
  before_action :authenticate_user!, only: [ :create ]

  # Configuramos respuestas en formato JSON
  respond_to :json

  # POST /users/invitation
  # Enviar una invitación a un nuevo usuario
  def create
    # Invitamos al usuario con el email proporcionado
    # current_user es quien está enviando la invitación
    self.resource = User.invite!(invite_params, current_user) do |u|
      # Puedes agregar campos adicionales aquí
      # Por ejemplo: u.name = params[:user][:name]
    end

    if resource.errors.empty?
      # La invitación se envió exitosamente
      render json: {
        message: "Invitación enviada exitosamente",
        user: {
          id: resource.id,
          email: resource.email,
          invitation_sent_at: resource.invitation_sent_at,
          invited_by: {
            id: current_user.id,
            email: current_user.email
          }
        }
      }, status: :created
    else
      # Hubo errores (por ejemplo, email ya existe)
      render json: {
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT /users/invitation
  # Aceptar una invitación y configurar contraseña
  def update
    # Buscamos el usuario por el token de invitación
    self.resource = User.accept_invitation!(accept_invitation_params)

    if resource.errors.empty?
      # La invitación fue aceptada exitosamente
      # Iniciamos sesión automáticamente al usuario
      # devise-jwt agregará el token JWT en los headers de respuesta
      sign_in(resource)

      render json: {
        message: "Invitación aceptada exitosamente. Token JWT en el header Authorization.",
        user: {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          invitation_accepted_at: resource.invitation_accepted_at
        }
      }, status: :ok
    else
      # Hubo errores (token inválido, contraseñas no coinciden, etc.)
      render json: {
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  # Parámetros permitidos para enviar invitación
  def invite_params
    params.require(:user).permit(:email, :name)
  end

  # Parámetros permitidos para aceptar invitación
  def accept_invitation_params
    params.require(:user).permit(
      :invitation_token,
      :password,
      :password_confirmation,
      :name
    )
  end

  # Sobrescribimos este método para evitar redirecciones HTML
  def after_accept_path_for(resource)
    nil
  end
end
