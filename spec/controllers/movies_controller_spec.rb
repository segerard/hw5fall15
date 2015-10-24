require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    it 'should call the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with('hardware').and_return (@fake_results)
      post :search_tmdb, {:search_terms => 'hardware'}
    end
    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        post :search_tmdb, {:search_terms => 'hardware'}
      end
      it 'should select the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
      it 'should make the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)        
      end
    end
    describe 'invalid search' do
      context 'blank or nil search' do
        it 'should redirect to home page' do
          post :search_tmdb, {:search_terms => ''}
          expect(response).to redirect_to(movies_path)
        end
        it 'shoudld flash invalid search message' do
          post :search_tmdb, {:search_terms => ''}
          expect(flash[:warning]).to eq("Invalid search term")
        end
        it 'should redirect to home page' do
          post :search_tmdb, {:search_terms => nil}
          expect(response).to redirect_to(movies_path)
        end
        it 'shoudld flash invalid search message' do
          post :search_tmdb, {:search_terms => nil}
          expect(flash[:warning]).to eq("Invalid search term")
        end
      end
      context 'no matching movies search' do
        it 'should call model method that performs Tmdb search' do
          allow(Movie).to receive(:find_in_tmdb).and_return([])
          expect(Movie).to receive(:find_in_tmdb)
          post :search_tmdb, {:search_terms => 'xcvb'}
        end
        it 'should redirect to homepage' do
          allow(Movie).to receive(:find_in_tmdb).and_return([])
          post :search_tmdb, {:search_terms => 'xcvb'}
          expect(response).to redirect_to(movies_path)
        end
        it 'should display flash saying no matches found' do
          allow(Movie).to receive(:find_in_tmdb).and_return([])
          post :search_tmdb, {:search_terms => 'xcvb'}
          expect(flash[:warning]).to eq("'xcvb' was not found in TMDb.")
        end
      end
    end
  end
  describe 'adding movies' do
    context 'Movie selected' do
      it 'should call the create_from_tmdb method' do
        allow(Movie).to receive(:create_from_tmdb).with("1")
        expect(Movie).to receive(:create_from_tmdb)
        post :add_tmdb, {:tmdb_movies => {"1"=>"1"}}
      end
      it 'should return to movies page' do
        allow(Movie).to receive(:create_from_tmdb).with("1")
        post :add_tmdb, {:tmdb_movies => {"1"=>"1"}}
        expect(response).to redirect_to(movies_path)
      end
      it 'should make the TMDb details available to that template' do
        allow(Movie).to receive(:create_from_tmdb).with("1")
        post :add_tmdb, {:tmdb_movies => {"1"=>"1"}}
        expect(assigns(:tmdb_ids)).to eq(["1"])        
      end
      it 'should show flash indicating movies were added' do
        allow(Movie).to receive(:create_from_tmdb).with("1")
        post :add_tmdb, {:tmdb_movies => {"1"=>"1"}}
        expect(flash[:warning]).to eq("Movies successfully added to Rotten Potatoes")
      end
    end
    context 'No movies selected' do
      it 'should return to movies page' do
        post :add_tmdb, {:tmdb_movies => nil}
        expect(response).to redirect_to(movies_path)
      end
      it 'should show flash indicating no movies were added' do
        post :add_tmdb, {:tmdb_movies => nil}
        expect(flash[:warning]).to eq("No movies selected")
      end
    end
  end
end
