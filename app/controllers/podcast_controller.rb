class PodcastController < ApplicationController
  before_action :set_podcast,  only: [:index, :feed]
  before_action :set_episodes, only: [:index, :feed]
  before_action :set_episode,  only: [:show, :transcript]

  def index
    @html_id        = "page"
    @body_id        = "podcast"
    @latest_episode = @episodes.shift
    @editable       = @latest_episode.podcast
    @title          = @podcast.name
  end

  def show
    @html_id  = "page"
    @body_id  = "podcast"
    @editable = @episode
    @title    = @episode.name
  end

  def transcript
    @html_id  = "page"
    @body_id  = "podcast"
    @editable = @episode
    @title    = "#{@episode.name} — Transcript"

    render "podcast/show"
  end

  def feed
  end

  private

  def set_podcast
    @podcast  = Podcast.find_by(title: "The Ex-Worker")
  end

  def set_episodes
    @episodes = Episode.live.order(published_at: :desc).to_a
  end

  def set_episode
    @episode  = Episode.where(slug: params[:slug])

    if @episode.blank?
      return redirect_to [:podcast]
    else
      @episode = @episode.first
    end
  end
end
