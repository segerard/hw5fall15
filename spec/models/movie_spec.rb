require 'spec_helper'
require 'rails_helper'


describe Movie do
  describe 'searching Tmdb by keyword' do
    before :each do
      @fake_movie = double('movie')
      allow(@fake_movie).to receive(:id).and_return('1')
      allow(@fake_movie).to receive(:title).and_return('Inception')
      allow(@fake_movie).to receive(:rating).and_return('R')
      allow(@fake_movie).to receive(:release_date).and_return('20151010')
    end
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        allow(Tmdb::Movie).to receive(:find).with('Inception').and_return([@fake_movie])
        expect(Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(NoMethodError)
        allow(Tmdb::Api).to receive(:response).and_return('code' => 401)
        expect {Movie.find_in_tmdb('Inception')}.to raise_error(Movie::InvalidKeyError)
      end
      it 'should raise tmdb_gem_exception' do
        allow(Tmdb::Movie).to receive(:find).and_raise(NoMethodError)
        allow(Tmdb::Api).to receive(:response).and_return('code' => 200)
        expect {Movie.find_in_tmdb('Inception')}.to raise_error(NoMethodError)
      end
    end
  end
  describe 'Adding movie from Tmdb' do
      it 'should call Tmdb with movie id' do
        @fake_tmdb_movie = {"title" => "Inception", "release_date" => '20151010'}
        allow(Tmdb::Movie).to receive(:detail).and_return(@fake_tmdb_movie) 
        expect(Tmdb::Movie).to receive(:detail).with('1')
        Movie.create_from_tmdb('1')
      end
      it 'should call Movie create' do
        @fake_tmdb_movie = {"title" => "Inception", "release_date" => '20151010'}
        allow(Movie).to receive(:create!).with(@fake_tmdb_movie)
        expect(Movie).to receive(:create!)
        Movie.create_from_tmdb('1')
      end
  end
end
