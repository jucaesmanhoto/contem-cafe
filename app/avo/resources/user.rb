class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :role, as: :select, options: {
      'User': :user, 'Manager': :manager, 'Admin': :admin
    }, placeholder: 'Choose a role', display_with_value: true
  end
end
