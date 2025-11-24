# frozen_string_literal: true

# Concern para hacer modelos "searchables" en ActiveAdmin
#
# Este módulo automáticamente permite buscar en todos los atributos
# EXCEPTO los sensibles (contraseñas, tokens, etc.)
#
# Uso:
#   class User < ApplicationRecord
#     include Ransackable
#   end
#
# Si necesitas personalizar qué atributos son buscables:
#   class User < ApplicationRecord
#     include Ransackable
#
#     def self.custom_ransackable_attributes
#       %w[name email custom_field]
#     end
#   end
module Ransackable
  extend ActiveSupport::Concern

  class_methods do
    # Atributos que NUNCA deben ser buscables (por seguridad)
    SENSITIVE_ATTRIBUTES = %w[
      password
      password_digest
      encrypted_password
      password_confirmation
      reset_password_token
      unlock_token
      confirmation_token
      reset_password_sent_at
      remember_created_at
      current_sign_in_at
      last_sign_in_at
      current_sign_in_ip
      last_sign_in_ip
      jti
    ].freeze

    # Método requerido por Ransack para definir atributos buscables
    # Automáticamente incluye todos los atributos EXCEPTO los sensibles
    def ransackable_attributes(auth_object = nil)
      # Si el modelo define atributos personalizados, usa esos
      return custom_ransackable_attributes if respond_to?(:custom_ransackable_attributes)

      # Caso contrario, usa todos los atributos menos los sensibles
      column_names.reject { |attr| SENSITIVE_ATTRIBUTES.include?(attr) }
    end

    # Método requerido por Ransack para definir asociaciones buscables
    # Permite buscar a través de todas las asociaciones del modelo
    def ransackable_associations(auth_object = nil)
      reflect_on_all_associations.map(&:name).map(&:to_s)
    end
  end
end
