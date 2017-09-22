class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    session["format"] = params["format"] unless params["format"] == nil
    session["ratings"] = params["ratings"] unless params["ratings"] == nil
    if session["ratings"] == nil
      session["ratings"] = {
        "G": true,
        "PG": true,
        "PG-13": true,
        "R": true
      }
    end
    @all_ratings = {
      "G": session["ratings"][:G] != nil,
      "PG": session["ratings"][:PG] != nil,
      "PG-13": session["ratings"][:"PG-13"] != nil,
      "R": session["ratings"][:R] != nil
    }
    if session["format"] == "title"
      @movies = Movie.order(:title)
      @hilight_field = "title"
    elsif session["format"] == "release_date"
      @movies = Movie.order(:release_date)
      @hilight_field = "release_date"
    else
      @movies = Movie.all
    end
    if session["ratings"] != nil
      @movies = @movies.where(:rating => session["ratings"].keys)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
