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
    @all_ratings = Movie.all_ratings
    @checked_ratings = @all_ratings
    redirect_flag = false
    
    #set correct params
    if ((not params.key?(:sort_by)) and session.key?(:sort_by))
      params[:sort_by] = session[:sort_by]
      redirect_flag = true
    end
    if ((not params.key?(:ratings)) and session.key?(:ratings))
      params[:ratings] = session[:ratings]
      redirect_flag = true
    end
    
    #set correct session
    session[:sort_by] = params[:sort_by]
    session[:ratings] = params[:ratings]
    
    #redirect if needed to be restful
    if redirect_flag
      flash.keep
      redirect_to movies_path params
    end
    
    #set correct instance variables
    @checked_ratings = params[:ratings].keys if params.key?(:ratings)
    @movies = Movie.where("rating IN (?)", @checked_ratings)
    case params[:sort_by]
    when 'title'
      @movies.order!("title")
    when 'release_date'
      @movies.order!("release_date")
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
