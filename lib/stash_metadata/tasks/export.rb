module StashMetadata
  module Tasks
    module Export

      def self.start(args)
        FileUtils.mkdir_p(STASH_SCENES_DIRECTORY)     unless File.directory?(STASH_SCENES_DIRECTORY)
        FileUtils.mkdir_p(STASH_GALLERIES_DIRECTORY)  unless File.directory?(STASH_GALLERIES_DIRECTORY)
        FileUtils.mkdir_p(STASH_PERFORMERS_DIRECTORY) unless File.directory?(STASH_PERFORMERS_DIRECTORY)
        FileUtils.mkdir_p(STASH_STUDIOS_DIRECTORY)    unless File.directory?(STASH_STUDIOS_DIRECTORY)

        mappings = { performers: [], studios: [], galleries: [], scenes: [] }

        Scene.all.each do |scene|
          mappings[:scenes].push(path: scene.path, checksum: scene.checksum)

          json = {}
          json[:title] = scene.title if scene.title
          json[:studio] = scene.studio.name if scene.studio && scene.studio.name
          json[:url] = scene.url if scene.url
          json[:date] = scene.date.to_s if scene.date
          json[:rating] = scene.rating if scene.rating
          json[:details] = scene.details if scene.details
          json[:gallery] = scene.gallery.checksum if scene.gallery
          json[:performers] = get_names(scene.performers) unless get_names(scene.performers).empty?
          json[:tags] = get_names(scene.tags) unless get_names(scene.tags).empty?

          if scene.scene_markers.count > 0
            json[:markers] = []
            scene.scene_markers.each { |marker|
              json[:markers].push(title: marker.title, seconds: marker.seconds)
            }
          elsif !json[:markers].nil?
            json.delete(:markers)
          end

          json[:file] = {}
          json[:file][:size] = scene.size
          json[:file][:duration] = scene.duration
          json[:file][:video_codec] = scene.video_codec
          json[:file][:audio_codec] = scene.audio_codec
          json[:file][:width] = scene.width
          json[:file][:height] = scene.height

          sceneJSON = StashMetadata::JSON.scene(scene.checksum)
          next if sceneJSON == json.as_json

          if args[:dry_run]
            StashMetadata.logger.info("WRITE\nJSON: #{json}\nFILE #{sceneJSON}\n\n\n--------") # Dry run
          else
            StashMetadata::JSON.save_scene(checksum: scene.checksum, json: json)
          end
        end

        Gallery.all.each do |gallery|
          mappings[:galleries].push(path: gallery.path, checksum: gallery.checksum)

          json = {}
          json[:title] = gallery.title if gallery.title
          json[:performers] = get_names(gallery.performers) unless get_names(gallery.performers).empty?

          next if json.empty?

          galleryJSON = StashMetadata::JSON.gallery(gallery.checksum)
          next if galleryJSON == json.as_json

          if args[:dry_run]
            StashMetadata.logger.info("WRITE\nJSON: #{json}\nFILE #{galleryJSON}\n\n\n--------") # Dry run
          else
            StashMetadata::JSON.save_gallery(checksum: gallery.checksum, json: json)
          end
        end

        clean_performers
        Performer.all.each do |performer|
          mappings[:performers].push(name: performer.name, checksum: performer.checksum)

          json = {}
          json[:name] = performer.name if performer.name
          json[:url] = performer.url if performer.url
          json[:twitter] = performer.twitter if performer.twitter
          json[:instagram] = performer.instagram if performer.instagram
          json[:birthdate] = performer.birthdate if performer.birthdate
          json[:ethnicity] = performer.ethnicity if performer.ethnicity
          json[:country] = performer.country if performer.country
          json[:eye_color] = performer.eye_color if performer.eye_color
          json[:height] = performer.height if performer.height
          json[:measurements] = performer.measurements if performer.measurements
          json[:fake_tits] = performer.fake_tits if performer.fake_tits
          json[:career_length] = performer.career_length if performer.career_length
          json[:tattoos] = performer.tattoos if performer.tattoos
          json[:piercings] = performer.piercings if performer.piercings
          json[:aliases] = performer.aliases if performer.aliases
          json[:favorite] = performer.favorite
          json[:image] = Base64.encode64(performer.image)

          next if json.empty?

          performerJSON = StashMetadata::JSON.performer(performer.checksum)
          next if performerJSON && performerJSON == json.as_json

          if args[:dry_run]
            StashMetadata.logger.info("WRITE\nJSON: #{json}\nFILE #{performerJSON}\n\n\n--------") # Dry run
          else
            StashMetadata::JSON.save_performer(checksum: performer.checksum, json: json)
          end
        end

        Studio.all.each do |studio|
          mappings[:studios].push(name: studio.name, checksum: studio.checksum)

          json = {}
          json[:name] = studio.name if studio.name
          json[:url] = studio.url if studio.url
          json[:image] = Base64.encode64(studio.image)

          next if json.empty?

          studioJSON = StashMetadata::JSON.studio(studio.checksum)
          next if studioJSON && studioJSON == json.as_json

          if args[:dry_run]
            StashMetadata.logger.info("WRITE\nJSON: #{json}\nFILE #{studioJSON}\n\n\n--------") # Dry run
          else
            StashMetadata::JSON.save_studio(checksum: studio.checksum, json: json)
          end
        end

        StashMetadata::JSON.save_mappings(json: mappings)
      end

      private

        def self.get_names(objects)
          return nil unless objects

          objects.reduce([]) { |names, object|
            unless object.name.nil?
              names << object.name
            end

            names
          }
        end

        def self.clean_performers
          glob = File.join(StashMetadata::STASH_PERFORMERS_DIRECTORY, "*.json")
          Dir[glob].each do |path|
            checksum = File.basename(path, '.json')

            # Delete any old images
            image_path = File.join(STASH_PERFORMERS_DIRECTORY, "#{checksum}.jpg")
            File.delete(image_path) if File.exist?(image_path)

            next if Performer.find_by(checksum: checksum)

            StashMetadata.logger.info("Performer cleanup removing #{checksum}")
            File.delete(File.join(StashMetadata::STASH_PERFORMERS_DIRECTORY, "#{checksum}.json"))
          end
        end

    end
  end
end
