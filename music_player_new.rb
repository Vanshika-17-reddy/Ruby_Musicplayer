require 'rubygems'
require 'gosu'

# Apple Music inspired dark theme
BG_DARK = Gosu::Color.new(0xFF2B2D3A)        # Dark purple-gray background
BG_SIDEBAR = Gosu::Color.new(0xFF23252F)     # Darker sidebar
BG_CARD = Gosu::Color.new(0xFF353747)        # Card background
TEXT_WHITE = Gosu::Color.new(0xFFFFFFFF)     # White text
TEXT_GRAY = Gosu::Color.new(0xFF9A9AA6)      # Gray text
ACCENT_PINK = Gosu::Color.new(0xFFFF2D55)    # Apple Music pink/red
ACCENT_BLUE = Gosu::Color.new(0xFF007AFF)    # Apple blue
PLAYER_BG = Gosu::Color.new(0xFF4B4D5E)      # Player bar background (lighter)
SHADOW = Gosu::Color.new(0x40000000)         # Shadow

module ZOrder
  BACKGROUND, GLOW, PLAYER, UI = *0..3
end

class ArtWork
  attr_accessor :bmp

  def initialize(file)
    @bmp = Gosu::Image.new(file)
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
end

class Track
  attr_accessor :name, :location

  def initialize(name, location)
    @name = name
    @location = location
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
  album_artwork = ArtWork.new(artwork_path)
  tracks = read_tracks(music_file)
  Album.new(album_title, album_artist, album_artwork, tracks)
end

def read_albums(music_file)
  count = music_file.gets.to_i
  albums = []
  count.times do
    albums << read_album(music_file)
  end
  albums
end

class MusicPlayerMain < Gosu::Window

  def initialize
    super 1200, 900, resizable: true
    self.caption = "Music Player"

    # Load all albums from file
    file = File.open("albums.txt", "r")
    @albums = read_albums(file)
    file.close

    # State variables
    @selected_album = 0
    @selected_track = 0
    @album_selected = false
    @song = nil
    @is_playing = false
    @current_view = :albums  # :albums, :playlists, :artists, :songs

    # Scroll offsets for different views
    @scroll_offset = 0
    @track_list_scroll = 0

    # Fonts - clean readable sizes
    @track_font = Gosu::Font.new(20)
    @title_font = Gosu::Font.new(28)
    @small_font = Gosu::Font.new(16)

    # Will store clickable positions for each album
    @album_positions = []
  end

  def draw_background
    # Dark background
    draw_quad(0, 0, BG_DARK, width, 0, BG_DARK,
              0, height, BG_DARK, width, height, BG_DARK, ZOrder::BACKGROUND)
  end

  def draw_albums
    # Albums in left area (after sidebar)
    sidebar_width = 200
    main_x_start = sidebar_width + 30

    # Left half for albums, right half for track list
    albums_width = (width - sidebar_width) / 2.0 - 50
    available_height = height - 150

    # Calculate album size - 2x2 grid
    album_size = [albums_width / 2.1, available_height / 2.2].min.to_i
    margin = 15

    # Clear positions array
    @album_positions = []

    # Grid positions
    grid_positions = [
      [0, 0],  # Taylor Swift - top left
      [1, 0],  # James Arthur - top right
      [0, 1],  # Olivia Rodrigo - bottom left
      [1, 1]   # Arctic Monkeys - bottom right
    ]

    @albums.each_with_index do |album, index|
      col, row = grid_positions[index]

      # Calculate position
      x_pos = main_x_start + (col * (album_size + margin))
      y_pos = 40 + (row * (album_size + margin))

      # Calculate scale
      scale_x = album_size.to_f / album.artwork.bmp.width
      scale_y = album_size.to_f / album.artwork.bmp.height

      # Card background
      card_padding = 8
      draw_rect(x_pos - card_padding, y_pos - card_padding,
                album_size + card_padding * 2, album_size + card_padding * 2,
                BG_CARD, ZOrder::GLOW)

      # Draw the album artwork
      album.artwork.bmp.draw(x_pos, y_pos, ZOrder::UI, scale_x, scale_y)

      # Selection indicator - pink accent
      if index == @selected_album && @album_selected
        accent_height = 3
        draw_rect(x_pos, y_pos + album_size - accent_height,
                  album_size, accent_height, ACCENT_PINK, ZOrder::UI)
      end

      # Store position for click detection
      @album_positions << {
        index: index,
        x: x_pos,
        y: y_pos,
        width: album_size,
        height: album_size
      }
    end
  end

  def draw_track_list
    # Right half of window shows track list
    sidebar_width = 200
    track_list_x = sidebar_width + (width - sidebar_width) / 2.0 + 20
    track_list_width = (width - sidebar_width) / 2.0 - 60

    # Draw tracks with clean spacing
    track_list_y = 40
    line_height = 48

    # Calculate scrollable area
    player_bar_height = 75
    available_height = height - track_list_y - player_bar_height - 20

    @albums[@selected_album].tracks.each_with_index do |track, index|
      y_pos = track_list_y + (index * line_height) - @track_list_scroll

      # Skip if outside visible area
      next if y_pos + 38 < track_list_y
      next if y_pos > track_list_y + available_height

      # Track row
      row_padding = 12
      row_x = track_list_x - row_padding
      row_y = y_pos - 8
      row_width = track_list_width + row_padding * 2
      row_height = 38

      if index == @selected_track
        # Playing track - card with pink accent
        draw_rect(row_x, row_y, row_width, row_height, BG_CARD, ZOrder::PLAYER)
        # Pink bar on left
        draw_rect(row_x, row_y, 3, row_height, ACCENT_PINK, ZOrder::UI)

        # Track info in white
        track_num = "#{index + 1}"
        @track_font.draw_text(track_num, track_list_x, y_pos, ZOrder::UI,
                             0.8, 0.8, TEXT_GRAY)
        @track_font.draw_text(track.name, track_list_x + 30, y_pos, ZOrder::UI,
                             0.9, 0.9, TEXT_WHITE)
      else
        # Unselected track
        draw_rect(row_x, row_y, row_width, row_height, BG_CARD, ZOrder::PLAYER)

        # Track info in gray
        track_num = "#{index + 1}"
        @track_font.draw_text(track_num, track_list_x, y_pos, ZOrder::UI,
                             0.8, 0.8, TEXT_GRAY)
        @track_font.draw_text(track.name, track_list_x + 30, y_pos, ZOrder::UI,
                             0.9, 0.9, TEXT_GRAY)
      end
    end
  end

  def draw_player_bar
    # Apple Music style player bar
    bar_height = 75
    bar_y = height - bar_height

    # Lighter background
    draw_rect(0, bar_y, width, bar_height, PLAYER_BG, ZOrder::UI)

    # Left section - Now playing info
    info_x = 25
    info_y = bar_y + 12

    if @album_selected
      # Album artwork thumbnail
      thumb_size = 48
      album = @albums[@selected_album]
      thumb_scale_x = thumb_size / album.artwork.bmp.width.to_f
      thumb_scale_y = thumb_size / album.artwork.bmp.height.to_f

      album.artwork.bmp.draw(info_x, info_y, ZOrder::UI, thumb_scale_x, thumb_scale_y)

      # Track and artist name
      text_x = info_x + thumb_size + 15
      @track_font.draw_text(@albums[@selected_album].tracks[@selected_track].name,
                           text_x, info_y + 8, ZOrder::UI, 0.75, 0.75, TEXT_WHITE)
      @small_font.draw_text(@albums[@selected_album].artist,
                           text_x, info_y + 30, ZOrder::UI, 0.95, 0.95, TEXT_GRAY)
    end

    # Center controls - Previous, Play/Pause, Next buttons
    center_x = width / 2.0
    center_y = bar_y + bar_height / 2.0
    button_spacing = 50

    # Previous button (left arrow/skip)
    prev_x = center_x - button_spacing
    draw_previous_icon(prev_x, center_y, TEXT_WHITE)

    # Play/Pause button (center - bigger)
    play_button_radius = 18
    button_color = @is_playing ? ACCENT_PINK : TEXT_WHITE
    draw_circle_filled(center_x, center_y, play_button_radius, button_color, ZOrder::UI)

    # Icon color
    icon_color = @is_playing ? TEXT_WHITE : BG_DARK
    if @is_playing
      # Pause icon
      bar_width = 2.5
      bar_height_icon = 10
      bar_spacing_icon = 6
      left_bar_x = center_x - bar_spacing_icon / 2 - bar_width
      right_bar_x = center_x + bar_spacing_icon / 2
      bar_y_pos = center_y - bar_height_icon / 2

      draw_rect(left_bar_x, bar_y_pos, bar_width, bar_height_icon, icon_color, ZOrder::UI)
      draw_rect(right_bar_x, bar_y_pos, bar_width, bar_height_icon, icon_color, ZOrder::UI)
    else
      # Play icon
      draw_triangle_filled(center_x - 3, center_y - 7,
                          center_x - 3, center_y + 7,
                          center_x + 8, center_y,
                          icon_color, ZOrder::UI)
    end

    # Next button (right arrow/skip)
    next_x = center_x + button_spacing
    draw_next_icon(next_x, center_y, TEXT_WHITE)

    # Store button positions for clicking
    @play_button_pos = {
      x: center_x - play_button_radius,
      y: center_y - play_button_radius,
      width: play_button_radius * 2,
      height: play_button_radius * 2
    }

    @prev_button_pos = {
      x: prev_x - 15,
      y: center_y - 10,
      width: 30,
      height: 20
    }

    @next_button_pos = {
      x: next_x - 15,
      y: center_y - 10,
      width: 30,
      height: 20
    }
  end

  def draw_previous_icon(x, y, color)
    # Previous track icon (left arrow/skip back)
    # Left bar
    draw_rect(x - 8, y - 8, 2, 16, color, ZOrder::UI)
    # Left triangle
    draw_triangle_filled(x - 6, y, x + 5, y - 8, x + 5, y + 8, color, ZOrder::UI)
  end

  def draw_next_icon(x, y, color)
    # Next track icon (right arrow/skip forward)
    # Right triangle
    draw_triangle_filled(x - 5, y - 8, x - 5, y + 8, x + 6, y, color, ZOrder::UI)
    # Right bar
    draw_rect(x + 6, y - 8, 2, 16, color, ZOrder::UI)
  end

  def draw_circle_filled(x, y, radius, color, z)
    # Draw a circle using triangles
    segments = 32
    (0...segments).each do |i|
      angle1 = (i * 2 * Math::PI) / segments
      angle2 = ((i + 1) * 2 * Math::PI) / segments

      x1 = x + Math.cos(angle1) * radius
      y1 = y + Math.sin(angle1) * radius
      x2 = x + Math.cos(angle2) * radius
      y2 = y + Math.sin(angle2) * radius

      draw_triangle(x, y, color, x1, y1, color, x2, y2, color, z)
    end
  end

  def draw_triangle_filled(x1, y1, x2, y2, x3, y3, color, z)
    draw_triangle(x1, y1, color, x2, y2, color, x3, y3, color, z)
  end

  def draw
    draw_background
    draw_sidebar

    case @current_view
    when :albums
      draw_albums
      draw_track_list
    when :songs
      draw_all_songs
    when :artists
      draw_artists_view
    when :playlists
      draw_all_songs  # For now, playlists shows all songs
    end

    draw_player_bar
  end

  def draw_sidebar
    # Left sidebar
    sidebar_width = 200

    # Darker sidebar background
    draw_rect(0, 0, sidebar_width, height, BG_SIDEBAR, ZOrder::BACKGROUND)

    # Library text
    @small_font.draw_text("LIBRARY", 20, 30, ZOrder::UI, 1.0, 1.0, TEXT_GRAY)

    # Menu items with selection highlighting
    menu_y = 70
    menu_items = [
      { name: "Playlists", view: :playlists },
      { name: "Artists", view: :artists },
      { name: "Albums", view: :albums },
      { name: "Songs", view: :songs }
    ]

    @sidebar_menu_items = []

    menu_items.each do |item|
      # Highlight selected menu item
      if @current_view == item[:view]
        draw_rect(15, menu_y - 5, 170, 30, BG_CARD, ZOrder::PLAYER)
        draw_rect(15, menu_y - 5, 3, 30, ACCENT_PINK, ZOrder::UI)
      end

      color = @current_view == item[:view] ? TEXT_WHITE : TEXT_GRAY
      @track_font.draw_text(item[:name], 25, menu_y, ZOrder::UI, 0.85, 0.85, color)

      # Store menu item position for clicking
      @sidebar_menu_items << {
        view: item[:view],
        x: 15,
        y: menu_y - 5,
        width: 170,
        height: 30
      }

      menu_y += 35
    end
  end

  def draw_all_songs
    # Show all songs from all albums in a list
    sidebar_width = 200
    songs_x = sidebar_width + 40
    songs_y = 40
    line_height = 48

    # Calculate scrollable area
    player_bar_height = 75
    available_height = height - songs_y - player_bar_height - 20

    # Collect all songs
    all_songs = []
    @albums.each_with_index do |album, album_idx|
      album.tracks.each_with_index do |track, track_idx|
        all_songs << {
          name: track.name,
          artist: album.artist,
          album_idx: album_idx,
          track_idx: track_idx
        }
      end
    end

    # Draw all songs
    all_songs.each_with_index do |song, index|
      y_pos = songs_y + (index * line_height) - @scroll_offset

      # Skip if outside visible area
      next if y_pos + 38 < songs_y
      next if y_pos > songs_y + available_height

      row_padding = 12
      row_x = songs_x - row_padding
      row_y = y_pos - 8
      row_width = width - sidebar_width - 80
      row_height = 38

      # Check if this is the currently playing song
      is_playing = (@selected_album == song[:album_idx] && @selected_track == song[:track_idx])

      if is_playing
        draw_rect(row_x, row_y, row_width, row_height, BG_CARD, ZOrder::PLAYER)
        draw_rect(row_x, row_y, 3, row_height, ACCENT_PINK, ZOrder::UI)

        @track_font.draw_text("#{index + 1}", songs_x, y_pos, ZOrder::UI, 0.8, 0.8, TEXT_GRAY)
        @track_font.draw_text(song[:name], songs_x + 35, y_pos, ZOrder::UI, 0.9, 0.9, TEXT_WHITE)
        @small_font.draw_text(song[:artist], songs_x + 35, y_pos + 20, ZOrder::UI, 1.0, 1.0, TEXT_GRAY)
      else
        draw_rect(row_x, row_y, row_width, row_height, BG_CARD, ZOrder::PLAYER)

        @track_font.draw_text("#{index + 1}", songs_x, y_pos, ZOrder::UI, 0.8, 0.8, TEXT_GRAY)
        @track_font.draw_text(song[:name], songs_x + 35, y_pos, ZOrder::UI, 0.9, 0.9, TEXT_GRAY)
        @small_font.draw_text(song[:artist], songs_x + 35, y_pos + 20, ZOrder::UI, 1.0, 1.0, TEXT_GRAY)
      end
    end
  end

  def draw_artists_view
    # Show artists with their album count
    sidebar_width = 200
    artists_x = sidebar_width + 40
    artists_y = 40
    line_height = 60

    # Calculate scrollable area
    player_bar_height = 75
    available_height = height - artists_y - player_bar_height - 20

    # Get unique artists
    artists = @albums.map { |a| a.artist }.uniq

    artists.each_with_index do |artist, index|
      y_pos = artists_y + (index * line_height) - @scroll_offset

      # Skip if outside visible area
      next if y_pos + 45 < artists_y
      next if y_pos > artists_y + available_height

      row_padding = 12
      row_x = artists_x - row_padding
      row_y = y_pos - 8
      row_width = width - sidebar_width - 80
      row_height = 45

      draw_rect(row_x, row_y, row_width, row_height, BG_CARD, ZOrder::PLAYER)

      @title_font.draw_text(artist, artists_x, y_pos, ZOrder::UI, 0.85, 0.85, TEXT_WHITE)

      # Count albums for this artist
      album_count = @albums.count { |a| a.artist == artist }
      @small_font.draw_text("#{album_count} album#{album_count > 1 ? 's' : ''}",
                           artists_x, y_pos + 28, ZOrder::UI, 1.0, 1.0, TEXT_GRAY)
    end
  end

  def update
    # Nothing needed here
  end

  def needs_cursor?
    true
  end

  def play_track(album_index, track_index)
    @song.stop if @song
    track = @albums[album_index].tracks[track_index]
    @song = Gosu::Song.new(track.location)
    @song.play(false)
    @selected_track = track_index
    @is_playing = true
  end

  def toggle_play_pause
    if @song
      if @is_playing
        @song.pause
        @is_playing = false
      else
        @song.play(false)
        @is_playing = true
      end
    end
  end

  def play_previous_track
    if @selected_track > 0
      @selected_track -= 1
      play_track(@selected_album, @selected_track)
    elsif @selected_album > 0
      # Go to previous album's last track
      @selected_album -= 1
      @selected_track = @albums[@selected_album].tracks.length - 1
      play_track(@selected_album, @selected_track)
    end
  end

  def play_next_track
    if @selected_track < @albums[@selected_album].tracks.length - 1
      @selected_track += 1
      play_track(@selected_album, @selected_track)
    elsif @selected_album < @albums.length - 1
      # Go to next album's first track
      @selected_album += 1
      @selected_track = 0
      play_track(@selected_album, @selected_track)
    end
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      mx = mouse_x
      my = mouse_y

      puts "\n=== CLICK at x=#{mx.to_i}, y=#{my.to_i} (Window: #{width}x#{height}) ==="

      # Check if play/pause button was clicked (with scaling)
      clicked_play_button = false
      if @play_button_pos
        [2.0, 1.75, 1.5, 1.25, 1.0].each do |scale|
          scaled_x = @play_button_pos[:x] * scale
          scaled_y = @play_button_pos[:y] * scale
          scaled_width = @play_button_pos[:width] * scale
          scaled_height = @play_button_pos[:height] * scale

          if mx >= scaled_x && mx <= scaled_x + scaled_width &&
             my >= scaled_y && my <= scaled_y + scaled_height
            puts ">>> PLAY/PAUSE BUTTON CLICKED at scale #{scale}x <<<"
            toggle_play_pause
            clicked_play_button = true
            break
          end
        end
      end

      return if clicked_play_button

      # Check if previous button was clicked
      clicked_prev_button = false
      if @prev_button_pos
        [2.0, 1.75, 1.5, 1.25, 1.0].each do |scale|
          scaled_x = @prev_button_pos[:x] * scale
          scaled_y = @prev_button_pos[:y] * scale
          scaled_width = @prev_button_pos[:width] * scale
          scaled_height = @prev_button_pos[:height] * scale

          if mx >= scaled_x && mx <= scaled_x + scaled_width &&
             my >= scaled_y && my <= scaled_y + scaled_height
            puts ">>> PREVIOUS BUTTON CLICKED at scale #{scale}x <<<"
            play_previous_track
            clicked_prev_button = true
            break
          end
        end
      end

      return if clicked_prev_button

      # Check if next button was clicked
      clicked_next_button = false
      if @next_button_pos
        [2.0, 1.75, 1.5, 1.25, 1.0].each do |scale|
          scaled_x = @next_button_pos[:x] * scale
          scaled_y = @next_button_pos[:y] * scale
          scaled_width = @next_button_pos[:width] * scale
          scaled_height = @next_button_pos[:height] * scale

          if mx >= scaled_x && mx <= scaled_x + scaled_width &&
             my >= scaled_y && my <= scaled_y + scaled_height
            puts ">>> NEXT BUTTON CLICKED at scale #{scale}x <<<"
            play_next_track
            clicked_next_button = true
            break
          end
        end
      end

      return if clicked_next_button

      # Check sidebar menu items
      if @sidebar_menu_items
        clicked_menu = false
        @sidebar_menu_items.each do |item|
          [2.0, 1.75, 1.5, 1.25, 1.0].each do |scale|
            scaled_x = item[:x] * scale
            scaled_y = item[:y] * scale
            scaled_width = item[:width] * scale
            scaled_height = item[:height] * scale

            if mx >= scaled_x && mx <= scaled_x + scaled_width &&
               my >= scaled_y && my <= scaled_y + scaled_height
              puts ">>> MENU #{item[:view]} CLICKED at scale #{scale}x <<<"
              @current_view = item[:view]
              # Reset scroll when switching views
              @scroll_offset = 0
              @track_list_scroll = 0
              clicked_menu = true
              break
            end
          end
          break if clicked_menu
        end

        return if clicked_menu
      end

      # Check albums (only in albums view)
      if @current_view == :albums
        clicked_album = false
        [2.0, 1.75, 1.5, 1.25, 1.0].each do |scale|
          next if clicked_album

          @album_positions.each do |pos|
            scaled_x = pos[:x] * scale
            scaled_y = pos[:y] * scale
            scaled_width = pos[:width] * scale
            scaled_height = pos[:height] * scale

            if mx >= scaled_x && mx <= scaled_x + scaled_width &&
               my >= scaled_y && my <= scaled_y + scaled_height
              puts ">>> ALBUM #{pos[:index]} (#{@albums[pos[:index]].artist}) at scale #{scale}x <<<"
              @selected_album = pos[:index]
              @selected_track = 0
              @album_selected = true
              play_track(@selected_album, 0)
              clicked_album = true
              break
            end
          end
        end

        # Check track list (only in albums view)
        unless clicked_album
          sidebar_width = 200
          [2.0, 1.75, 1.5, 1.25, 1.0].each do |scale|
            track_list_x = (sidebar_width + (width - sidebar_width) / 2.0 + 20) * scale
            track_list_y = 40 * scale
            line_height = 48 * scale

            if mx >= track_list_x && my >= track_list_y
              track_index = ((my - track_list_y) / line_height).to_i
              if track_index >= 0 && track_index < @albums[@selected_album].tracks.length
                puts ">>> TRACK #{track_index} at scale #{scale}x <<<"
                play_track(@selected_album, track_index)
                break
              end
            end
          end
        end
      end
    when Gosu::KbSpace
      # Spacebar also toggles play/pause
      toggle_play_pause
    end
  end

  def button_up(id)
    case id
    when Gosu::MsWheelUp
      # Scroll up
      scroll_amount = 40

      # Determine which scroll offset to adjust based on current view and mouse position
      if @current_view == :albums
        # In albums view, check if mouse is on the track list side
        sidebar_width = 200
        track_list_x = sidebar_width + (width - sidebar_width) / 2.0

        if mouse_x >= track_list_x
          # Scrolling track list
          @track_list_scroll = [@track_list_scroll - scroll_amount, 0].max
        end
      else
        # For other views, use main scroll offset
        @scroll_offset = [@scroll_offset - scroll_amount, 0].max
      end

    when Gosu::MsWheelDown
      # Scroll down
      scroll_amount = 40

      # Determine which scroll offset to adjust based on current view and mouse position
      if @current_view == :albums
        # In albums view, check if mouse is on the track list side
        sidebar_width = 200
        track_list_x = sidebar_width + (width - sidebar_width) / 2.0

        if mouse_x >= track_list_x
          # Scrolling track list
          max_scroll = [@albums[@selected_album].tracks.length * 48 - (height - 150), 0].max
          @track_list_scroll = [@track_list_scroll + scroll_amount, max_scroll].min
        end
      else
        # For other views, calculate max scroll based on content
        player_bar_height = 75
        available_height = height - 40 - player_bar_height - 20

        case @current_view
        when :songs, :playlists
          # Count total songs
          total_songs = @albums.sum { |album| album.tracks.length }
          total_height = total_songs * 48
          max_scroll = [total_height - available_height, 0].max
          @scroll_offset = [@scroll_offset + scroll_amount, max_scroll].min

        when :artists
          # Count unique artists
          artist_count = @albums.map { |a| a.artist }.uniq.length
          total_height = artist_count * 60
          max_scroll = [total_height - available_height, 0].max
          @scroll_offset = [@scroll_offset + scroll_amount, max_scroll].min
        end
      end
    end
  end
end

MusicPlayerMain.new.show if __FILE__ == $0
