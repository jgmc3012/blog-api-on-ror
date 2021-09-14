class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :published, :author

  def author
    {
      id: self.object.user.id,
      name: self.object.user.name,
      email: self.object.user.email
    }
  end
end
