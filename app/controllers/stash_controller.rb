class StashController < ApplicationController

  def dashboard
  end

  def status
    @manager = StashMetadata::Manager.instance
  end

  def scan
    @manager = StashMetadata::Manager.instance
    @manager.scan
    head :no_content
  end

  def search
    @scenes = Scene.search_for(params[:q])
    @performers = Performer.search_for(params[:q])
    @studios = Studio.search_for(params[:q])
    @tags = Tag.search_for(params[:q])

    performers_json = [] # @performers.as_json(root: false)
    studios_json = []
    tags_json = []
    scenes_json = []

    @performers.each do |performer|
      json = {}
      json[:title] = performer.name
      json[:image] = performer_image_path(performer)
      json[:url]   = performer_path(performer)
      performers_json.push(json)
    end

    @studios.each do |studio|
      json = {}
      json[:title] = studio.name
      studios_json.push(json)
    end

    @tags.each do |tag|
      json = {}
      json[:title] = tag.name
      json[:url]   = scenes_path(filter_tags: tag.id)
      tags_json.push(json)
    end

    @scenes.each do |scene|
      json = {}
      json[:title] = scene.title || scene.path
      # json[:description] = scene.checksum
      json[:image] = screenshot_path(scene)
      json[:url]   = scene_path(scene)
      scenes_json.push(json)
      break if scenes_json.count > 10
    end

    render json: {
      success: true,
      results: {
        performers: {
          name: 'Performers',
          results: performers_json
        },
        studios: {
          name: 'Studios',
          results: studios_json
        },
        tags: {
          name: 'Tags',
          results: tags_json
        },
        scenes: {
          name: 'Scenes',
          results: scenes_json
        }
      }
    }.to_json
  end


  def stats

    render json: {
      success: true,
      results: {
        totals: {
          tags: Tag.count,
          scenes: Scene.count,
          performers: Performer.count,
          studios: Studio.count,
          markers: SceneMarker.count
        }
      }
    }.to_json
  end

end
