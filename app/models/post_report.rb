class PostReport < Struct.new(:word_count, :word_histogram)
  def self.generate(post)
    PostReport.new(
      word_count: post.content.split.map { |word| word.gsub(/\W/, '') }.count,
      word_histogram: post.content.split.map { |word| word.gsub(/\W/, '') }.map(&:downcase).group_by { |word| word }.transfrom_values(&:size)
    )
  end
end
