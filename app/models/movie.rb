class Movie < ActiveRecord::Base
  class Movie::InvalidKeyError < StandardError; end 
   
  def self.find_in_tmdb(query)
    begin
      Tmdb::Movie.find(query) 
      matching_movies = Tmdb::Movie.find(query) 
      @movies = []
      matching_movies.each do |movie|
        @movies.push({tmdb_id:movie.id, title:movie.title, rating:"R", release_date:movie.release_date})
      end
      @movies
    rescue NoMethodError => tmdb_gem_exception
      if Tmdb::Api.response['code'] == 401
        raise Movie::InvalidKeyError, 'Invalid API key'
      else
        raise tmdb_gem_exception
      end 
    end
  end

  def self.create_from_tmdb(id)
    @movie_details = Tmdb::Movie.detail(id)
    Movie.create!({title:@movie_details["title"],rating:"R",release_date:@movie_details["release_date"]})    
  end

  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
end
