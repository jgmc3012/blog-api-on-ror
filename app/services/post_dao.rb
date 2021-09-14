class PostDao
    def self.search_by_title(posts ,title)
        posts.where("title LIKE '%#{title}%'")
    end
end