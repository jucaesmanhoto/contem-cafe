class AddRoleToUser < ActiveRecord::Migration[8.1]
  def change
    # 1. Adiciona a coluna como string com valor padrão
    add_column :users, :role, :string, null: false, default: "user"

    # 2. Adiciona a trava de segurança no nível do banco (Check Constraint)
    add_check_constraint :users, "role IN ('user', 'manager', 'admin')", name: "allowed_roles"
  end
end
