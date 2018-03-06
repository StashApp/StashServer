require 'fileutils'
require 'zip'
require 'naturally'

module Stash
  STASH_DIRECTORY             = File.expand_path(ENV['stash_directory'])
  STASH_METADATA_DIRECTORY    = File.expand_path(ENV['stash_metadata_directory'])
  STASH_CACHE_DIRECTORY       = File.expand_path(ENV['stash_cache_directory'])
  STASH_PERFORMERS_DIRECTORY  = File.join(STASH_METADATA_DIRECTORY, 'performers')
  STASH_SCENES_DIRECTORY      = File.join(STASH_METADATA_DIRECTORY, 'scenes')
  STASH_GALLERIES_DIRECTORY   = File.join(STASH_METADATA_DIRECTORY, 'galleries')
  STASH_STUDIOS_DIRECTORY     = File.join(STASH_METADATA_DIRECTORY, 'studios')
  STASH_SCREENSHOTS_DIRECTORY = File.join(STASH_METADATA_DIRECTORY, 'screenshots')
  STASH_VTT_DIRECTORY         = File.join(STASH_METADATA_DIRECTORY, 'vtt')
  STASH_MARKERS_DIRECTORY     = File.join(STASH_METADATA_DIRECTORY, 'markers')
  STASH_TRANSCODE_DIRECTORY   = File.join(STASH_METADATA_DIRECTORY, 'transcodes')
  STASH_MAPPINGS_FILE         = File.join(STASH_METADATA_DIRECTORY, 'mappings.json')

  VALID_HTML5_CODECS          = ['h264', 'h265', 'vp8', 'vp9']

  def self.logger
    return @logger if @logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    @logger = logger
  end
end
