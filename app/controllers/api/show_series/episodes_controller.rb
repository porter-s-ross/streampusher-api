class Api::ShowSeries::EpisodesController < ApplicationController
  def index
    episodes = ::ShowSeries.friendly.find(params[:show_series_id]).episodes #.page(params[:page])
    # FIXME change the query param naming
    # past episodes, could be published or unpublished
    if params[:status] === "archive_published"
      episodes = episodes.where("start_at < ?", Time.now).order("start_at DESC")
    # future episodes start at ASC shouldn't be published
    elsif params[:status] === "archive_unpublished"
      episodes = episodes.where("start_at > ?", Time.now).order("start_at ASC")
    end
    episodes = episodes.page(params[:page])
    render json: episodes
  end

  def show
    episode = ::ShowSeries.friendly.find(params[:show_series_id]).episodes.friendly.find(params[:id])
    render json: episode, include: ['posts', 'labels', 'tracks', 'recording']
  end
end
