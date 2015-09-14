class LinksController < ApplicationController
  before_filter :set_resently_shortened_links, only: [:new, :shorten, :redirect_to_url]

  before_filter :authenticate_user!, only: :index

  def index
    @links = current_user.links.page(params[:page])
    @link = current_user.links.new
  end

  def new
    @link = Link.new
  end

  def create
    @link = user_signed_in? ? current_user.links.new(link_params) : Link.new(link_params)
    if @link.save
      session[:recently_shortened].push(@link) unless user_signed_in?
      redirect_to shorten_path(@link.short_url)
    else
      render "new"
    end
  end

  def shorten
    @link = Link.find_by_short_url(params[:short_url])
    # show only last 5 links
    binding.pry
    @recently_shortened.shift(@recently_shortened.count - LinksHelper::RECENTLY_SHOWED) if @recently_shortened.count > LinksHelper::RECENTLY_SHOWED
    if @link
      @new_link = Link.new
    else
      redirect_to root_path
    end
  end

  def redirect_to_url
    link = Link.find_by_short_url(params[:short_url])
    if link.present? && link.long_url.present?
       Link.increment_counter(:clicks_count, link.id)
       recently_link = session[:recently_shortened].detect{|lnk| lnk['short_url'] == link.short_url}
       recently_link['clicks_count'] = link.reload.clicks_count if recently_link.present?
       redirect_to link.long_url
    else
       redirect_to root_path
    end

  end

  # Strong Parameters in rails ~> 4
  private

  def link_params
    params.require(:link).permit(:short_url, :long_url)
  end

  def set_resently_shortened_links
    @recently_shortened = user_signed_in? ? current_user.links.to_a : session[:recently_shortened] ||= []
  end

end
