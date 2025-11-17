require 'sinatra'
require 'sinatra/cors'
require 'json'

# Enable CORS for Next.js frontend
set :allow_origin, "http://localhost:3000"
set :allow_methods, "GET,HEAD,POST"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"
set :port, 4567

class Track
  attr_accessor :name, :location

  def initialize(name, location)
    @name = name
    @location = location
  end

  def to_hash
    {
      name: @name,
      location: @location
    }
  end
end

class Album
  attr_accessor :title, :artist, :artwork, :tracks

  def initialize(title, artist, artwork, tracks)
    @title = title
    @artist = artist
    @artwork = artwork
    @tracks = tracks
  end

  def to_hash
    {
      title: @title,
      artist: @artist,
      artwork: @artwork,
      tracks: @tracks.map(&:to_hash)
    }
  end
end

def read_track(music_file)
  track_name = music_file.gets.chomp
  track_location = music_file.gets.chomp
  Track.new(track_name, track_location)
end

def read_tracks(music_file)
  count = music_file.gets.to_i
  tracks = []
  count.times do
    tracks << read_track(music_file)
  end
  tracks
end

def read_album(music_file)
  album_title = music_file.gets.chomp
  album_artist = music_file.gets.chomp
  artwork_path = music_file.gets.chomp
  tracks = read_tracks(music_file)
  Album.new(album_title, album_artist, artwork_path, tracks)
end

def read_albums(music_file)
  count = music_file.gets.to_i
  albums = []
  count.times do
    albums << read_album(music_file)
  end
  albums
end

# Load albums data
def load_albums
  file = File.open("../albums.txt", "r")
  albums = read_albums(file)
  file.close
  albums
end

# API Routes

get '/' do
  { message: "Music Player API", version: "1.0" }.to_json
end

# Get all albums
get '/api/albums' do
  content_type :json
  albums = load_albums
  albums.map(&:to_hash).to_json
end

# Get specific album
get '/api/albums/:id' do
  content_type :json
  albums = load_albums
  album_id = params[:id].to_i

  if album_id >= 0 && album_id < albums.length
    albums[album_id].to_hash.to_json
  else
    status 404
    { error: "Album not found" }.to_json
  end
end

# Get all tracks from all albums
get '/api/tracks' do
  content_type :json
  albums = load_albums
  all_tracks = []

  albums.each_with_index do |album, album_idx|
    album.tracks.each_with_index do |track, track_idx|
      all_tracks << {
        name: track.name,
        location: track.location,
        artist: album.artist,
        album: album.title,
        album_id: album_idx,
        track_id: track_idx,
        artwork: album.artwork
      }
    end
  end

  all_tracks.to_json
end

# Get all unique artists
get '/api/artists' do
  content_type :json
  albums = load_albums
  artists = albums.map(&:artist).uniq

  artists_data = artists.map do |artist|
    artist_albums = albums.select { |a| a.artist == artist }
    {
      name: artist,
      album_count: artist_albums.length,
      albums: artist_albums.map(&:to_hash)
    }
  end

  artists_data.to_json
end

# Serve static files (images and audio)
get '/files/*' do
  file_path = File.join("..", params[:splat].first)

  if File.exist?(file_path)
    send_file file_path
  else
    status 404
    { error: "File not found" }.to_json
  end
end

# Start server
puts "🎵 Music Player API running on http://localhost:4567"
puts "📂 Serving files from parent directory"
