class PostDao
  def self.search_by_title(posts, title)
    posts_ids = Rails.cache.fetch("search_by_title_#{title}", expires_in: 1.hour) do
      posts.where("title LIKE '%#{title}%'").map(&:id)
    end

    posts.where(id: posts_ids)
  end
end
