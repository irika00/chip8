class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.find_in_tmdb(params, api_key = ENV['TMDB_API_KEY'])
    query = { api_key: api_key, query: params[:title] }
    query[:year] = params[:release_year] if params[:release_year].present?
    query[:language] = 'en-US' if params[:language] == 'en'
  
    response = Faraday.get('https://api.themoviedb.org/3/search/movie', query)
    data = JSON.parse(response.body)
  
    (data['results'] || []).map do |m|
      Movie.new(title: m['title'], release_date: m['release_date'],
                description: m['overview'], rating: 'R')
    end.reject { |m| Movie.exists?(title: m.title, release_date: m.release_date) }
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end
