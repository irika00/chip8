require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    describe 'on initial page load' do
      it 'renders the form without redirecting or searching' do
        expect(Movie).not_to receive(:find_in_tmdb)
        get :search_tmdb
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('search_tmdb')
      end
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
      get :search_tmdb, params: { title: 'hardware' }
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: { title: 'hardware' }
      end
      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    describe 'with a blank title' do
      it 'redirects with an error and does not search' do
        expect(Movie).not_to receive(:find_in_tmdb)
        get :search_tmdb, params: { title: '' }
        expect(response).to redirect_to(search_tmdb_path)
        expect(flash[:danger]).to eq("Please fill in all required fields!")
      end
    end

    describe 'with no matches' do
      it 'sets a warning message' do
        allow(Movie).to receive(:find_in_tmdb).and_return([])
        get :search_tmdb, params: { title: 'zzzzzz' }
        expect(flash[:warning]).to eq("No movies found with given parameters!")
      end
    end
  end

  describe 'adding a movie' do
    it 'saves the movie and redirects to /search' do
      expect {
        post :add_movie, params: { title: 'Hackers', rating: 'R',
                                   description: 'Hack the planet',
                                   release_date: '1995-09-15' }
      }.to change(Movie, :count).by(1)
      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:success]).to eq("Hackers was successfully added to RottenPotatoes.")
    end
  end
end