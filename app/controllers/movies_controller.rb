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
    if session["ratings"] == nil
      session["ratings"] = {
        "G": true,
        "PG": true,
        "PG-13": true,
        "R": true
      }
      @all_ratings = session["ratings"]
      @movies = Movie.all
    else
      if (params[:sortBy] == nil && session[:sortBy] != nil) || (params["ratings"] == nil && session["ratings"] != nil)
        session[:sortBy] = params[:sortBy] unless params[:sortBy] == nil
        session["ratings"] = params["ratings"] unless params["ratings"] == nil
        redirect_to movies_path(:sortBy => session[:sortBy], "ratings" => session["ratings"])
      else
        if params[:sortBy] != nil
          session[:sortBy] = params[:sortBy]
          if params[:sortBy] == "title"
            @movies = Movie.order(:title)
            @hilight_field = "title"
          elsif params[:sortBy] == "release_date"
            @movies = Movie.order(:release_date)
            @hilight_field = "release_date"
          end
        end
        if params["ratings"] != nil
          session["ratings"] = params["ratings"]
          @all_ratings = {
            "G": params["ratings"][:G] != nil,
            "PG": params["ratings"][:PG] != nil,
            "PG-13": params["ratings"][:"PG-13"] != nil,
            "R": params["ratings"][:R] != nil
          }
          @movies = Movie.all if @movies == nil
          @movies = @movies.where(:rating => params["ratings"].keys)
        end
      end
    end



    # if session.keys.length == 0
    #   params['ratings'] = {
    #     "G": true,
    #     "PG": true,
    #     "PG-13": true,
    #     "R": true
    #   }
    # end
    # if params[:sortBy] != session[:sortBy] || params["ratings"] != session["ratings"]
    #   session[:sortBy] = params[:sortBy]
    #   session["ratings"] = params["ratings"]
    #   redirect_to movies_path(session)
    # else
    #   puts "-----------"
    #   puts session[:sortBy]
    #   puts session["ratings"]
    #   puts "-----------"
    #   if session["ratings"] == nil
    #     @all_ratings = {
    #       "G": false,
    #       "PG": false,
    #       "PG-13": false,
    #       "R": false
    #     }
    #   else
    #     @all_ratings = {
    #       "G": session["ratings"][:G] != nil,
    #       "PG": session["ratings"][:PG] != nil,
    #       "PG-13": session["ratings"][:"PG-13"] != nil,
    #       "R": session["ratings"][:R] != nil
    #     }
    #   end
    #   if session["format"] == "title"
    #     @movies = Movie.order(:title)
    #     @hilight_field = "title"
    #   elsif session["format"] == "release_date"
    #     @movies = Movie.order(:release_date)
    #     @hilight_field = "release_date"
    #   else
    #     @movies = Movie.all
    #   end
    #   if session["ratings"] != nil
    #     @movies = @movies.where(:rating => session["ratings"].keys)
    #   end
    # end
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
