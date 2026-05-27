class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 1. Define os valores permitidos como string no formato hash
  enum :role, {
    user: "user",
    manager: "manager",
    admin: "admin"
  }, default: "user" # Define o padrão para novos usuários

  # 2. Garante que o Rails valide a inclusão antes de salvar
  validates :role, inclusion: { in: roles.keys.map(&:to_s) }
end
