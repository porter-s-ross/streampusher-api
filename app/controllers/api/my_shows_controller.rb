class Api::MyShowsController < ApplicationController
  def show
    show_series = ShowSeries.friendly.find params[:id]

    render json: show_series, include: 'episodes'
  end

  def index
    authorize! :index, :my_shows

    show_series = ShowSeries.joins("inner join show_series_hosts on show_series_hosts.user_id = #{current_user.id} and show_series_hosts.show_series_id = show_series.id")

    render json: show_series
  end

  def create
    authorize! :create, ShowSeries
    if my_show_params[:recurring_interval] === "not_recurring"
      guest_series = ShowSeries.find_by(title: "GuestFruits")
      episode = guest_series.episodes.new my_show_params.except(:recurring_interval, :start_date, :end_date, :start_time, :end_time)
      episode.start_at = my_show_params[:start_time]
      episode.end_at = my_show_params[:end_time]
      # TODO image??
      if episode.save
        render json: guest_series
      else
        render json: { errors: guest_series.errors }, status: 422
      end
    else
      if my_show_params[:image].present?
        image = Paperclip.io_adapters.for(my_show_params[:image])
        image.original_filename = my_show_params.delete(:image_filename)
        show_series = ShowSeries.new my_show_params.except(:image_filename).merge({image: image})
      else
        show_series = ShowSeries.new my_show_params.except(:image_filename).except(:image)
      end
      if users_params.has_key? :user_ids
        users_params[:user_ids].each do |user_id|
          show_series.show_series_hosts.build user_id: user_id
        end
      end
      if labels_params.has_key? :label_ids
        labels_params[:label_ids].each do |label_id|
          show_series.show_series_labels.build label_id: label_id
        end
      end
      if show_series.save
        render json: show_series
      else
        render json: { errors: [show_series.errors] }, status: 422
      end
    end
  end

  def update
    show_series = ShowSeries.friendly.find params[:id]
    authorize! :update, show_series
    if my_show_params[:image].present?
      image = Paperclip.io_adapters.for(my_show_params[:image])
      image.original_filename = my_show_params.delete(:image_filename)
      show_series = ShowSeries.new my_show_params.except(:image_filename).merge({image: image})
    else
      show_series = ShowSeries.new my_show_params.except(:image_filename).except(:image)
    end
    if show_series.save
      render json: show_series
    else
      render json: { errors: [show_series.errors] }, status: 422
    end
  end

  private
  def my_show_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [
      :title,
      :start_date,
      :end_date,
      :start_time,
      :end_time,
      :description, :image, :image_filename,
      :recurring_interval,
      :start, :end
    ])
  end

  def labels_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [
      :labels
    ])
  end

  def users_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [
      :users
    ])
  end
end
