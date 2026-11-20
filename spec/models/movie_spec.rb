require 'rails_helper'
require 'spec_helper'

describe Movie do
  describe 'searching TMDB by keyword' do
    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get).and_call_original
      Movie.find_in_tmdb({title: "hacker", language: "en"})
    end

    it 'calls TMDb with valid API key' do
      Movie.find_in_tmdb({title: "hacker", language: "en"})
    end

    it 'returns unsaved Movie objects' do
      results = Movie.find_in_tmdb({title: "olympics"})
      expect(results.first).to be_a(Movie)
      expect(results.first).to be_new_record
    end
  end
end