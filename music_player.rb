require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

# Put your record definitions here
class Album
    # NB: you will need to add tracks to the following and the initialize()
        attr_accessor :title, :artist, :artwork, :tracks

        def initialize (title,artist,artwork,tracks)
            @title=title
            @artist=artist
            @artwork=artwork
            @tracks=tracks 
        end
    end
    
    class Track
        attr_accessor :name, :location
    
        def initialize (name, location)
            @name = name
            @location = location
        end
    end
    def read_track(music_file)
        # fill in the missing code
            track_name=music_file.gets.chomp.to_s()
            track_location=music_file.gets.chomp.to_s()
            track=Track.new(track_name,track_location)
            return track
    end
    def read_tracks(music_file)
	
        count = music_file.gets().to_i()
        tracks = Array.new()
        i=0;
        while(i<count)
            tracks[i]=read_track(music_file);
            i+=1;
        end
      # Put a while loop here which increments an index to read the tracks
        return tracks
    end
    def print_tracks(tracks)
        # print all the tracks use: tracks[x] to access each track.
        count=tracks.length
        i=0
        while(i<count)
            print((i+1).to_s+" ")
            print_track(tracks[i])
            i+=1
        end
    end
    def read_albums(music_file)
        count=music_file.gets.chomp.to_i 
        i=0
        albums=Array.new()
        while(i<count)
            albums[i]=read_album(music_file)
            i+=1
        end
        return albums
    end 
    
    # Reads in and returns a single album from the given file, with all its tracks
    
    def read_album(music_file)
    
      # read in all the Album's fields/attributes including all the tracks
      # complete the missing code
        album_title=music_file.gets.chomp.to_s()
        album_artist=music_file.gets.chomp.to_s()
        artwork=music_file.gets.chomp.to_s()
        album_artwork=ArtWork.new(artwork)
        tracks=read_tracks(music_file)
        album = Album.new(album_title, album_artist,album_artwork, tracks)
        return album 
    end
    
    
    # Takes a single album and prints it to the terminal along with all its tracks
    def print_albums(albums)
        i=0
        while(i<albums.length)
            print_album(albums[i])
            i+=1
        end
    end
    def print_album(album)
    
      # print out all the albums fields/attributes
      # Complete the missing code.
        puts(album.title);
        puts(album.artist);
        # print out the tracks
        print_tracks(album.tracks)
    
    end
    
    # Takes a single track and prints it to the terminal
    def print_track(track)
        print(track.name+"\n")
        print(track.location+"\n")
    end

class MusicPlayerMain < Gosu::Window

	def initialize
	    super 1200, 900
	    self.caption = "Music Player"
        @array=[]
        @file=File.open("albums.txt","r")
        @array=read_albums(@file)
        print_albums(@array)
        @counter=true
        @track_font=Gosu::Font.new(20)
        @selected_album=0
        @selected_track=0
        @song=0
		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
	end

  # Put in your code here to load albums and tracks

  # Draws the artwork on the screen for all the albums

  def draw_albums albums
    x = 20  # Starting x-coordinate for the artwork
    y = 30 # Starting y-coordinate for the artwork
    i = 0   # Initialize an index to iterate through albums
  
    while i < albums.length
      if(i%2==0)
        y=30
      albums[i].artwork.bmp.draw(x, y, ZOrder::UI)
      else
        y=450 
        albums[i].artwork.bmp.draw(x, y, ZOrder::UI) 
        x += 400
      end  
      i += 1
    end
  end
  #using the function below to select an album.
  def area_clicked()
    if((self.mouse_x>=20 && self.mouse_x<400) && (self.mouse_y>=30 && self.mouse_y<410))
        @selected_album=0
        playTrack(0,@array[@selected_album])
        return true
    elsif((self.mouse_x>=20 && self.mouse_x<400) && (self.mouse_y>=450 && self.mouse_y<830))#adding in height and width to make it equivalent to images height and width 
        @selected_album=1
        playTrack(0,@array[@selected_album])
        return true
    elsif((self.mouse_x>=420 && self.mouse_x<800) && (self.mouse_y>=30 && self.mouse_y<410))#adding in height and width to make it equivalent to images height and width 
        @selected_album=2
        playTrack(0,@array[@selected_album])
        return true
    elsif((self.mouse_x>=420 && self.mouse_x<800) && (self.mouse_y>=450 && self.mouse_y<830))#adding in height and width to make it equivalent to images height and width 
        @selected_album=3
        playTrack(0,@array[@selected_album])
        return true
    else
        return false
     end
  end
  # Takes a String title and an Integer ypos
  # You may want to use the following:
  def display_track(title, ypos)
  	@track_font.draw_text(title, 900, ypos, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
  end


  # Takes a track index and an Album and plays the Track from the Album

  def playTrack(track, album)
  			@song = Gosu::Song.new(album.tracks[track].location)
  			@song.play(false)
  end

# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

	def draw_background
        if(@counter==true)
        draw_quad(0,0,TOP_COLOR,0,900,TOP_COLOR,1200,0,TOP_COLOR,1200,900,TOP_COLOR,ZOrder::BACKGROUND)
        else
            draw_quad(0,0,BOTTOM_COLOR,0,900,BOTTOM_COLOR,1200,0,BOTTOM_COLOR,1200,900,BOTTOM_COLOR,ZOrder::BACKGROUND)
        end
	end

# Not used? Everything depends on mouse actions.

	def update
        
	end
    def display_list()
        i=0
        y=30
        while(i<@array[@selected_album].tracks.length)
            display_track(@array[@selected_album].tracks[i].name,y)
            y+=30
            i+=1
        end

    end

 # Draws the album images and the track list for the selected album

	def draw
		# Complete the missing code
		draw_background
        draw_albums(@array)
        display_list()
        if @selected_track < @array[@selected_album].tracks.length
            y_point = @selected_track * 30 + 30 #doing this to convert track number back into y poisition 
            highlight_track(y_point)
          end
        
	end

 	def needs_cursor?; true; end

	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	# you will learn about inheritance in the OOP unit - for now just accept that
	# these are available and filled with the latest x and y locations of the mouse click.
    def highlight_track(track_y_point)   
    draw_rect(900,track_y_point,200,20,Gosu::Color::GREEN,ZOrder::PLAYER)
    end

	def button_down(id)
        case id
        when Gosu::MsLeft
            value=area_clicked
            if(value==true)
                @counter=false
            else 
                @counter=true
            end
            if (self.mouse_x >= 900 && self.mouse_x <= 1200) && (self.mouse_y >= 30)
                track_index = ((self.mouse_y - 30) / 30).to_i#subtracting 30 to start index from 0. using this logic to select tracks.
                if track_index < @array[@selected_album].tracks.length
                  @selected_track = track_index
                  playTrack(@selected_track,@array[@selected_album])
                  @counter=false
                end
              end
	end
    
end

end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
