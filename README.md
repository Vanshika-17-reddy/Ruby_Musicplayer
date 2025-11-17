# Music Player - Next.js + Ruby API

A modern, Apple Music-inspired music player with a Next.js frontend and Ruby backend API.

## Architecture

- **Frontend**: Next.js 15 with TypeScript, Tailwind CSS, and React
- **Backend**: Ruby Sinatra API serving music files and metadata
- **Audio**: HTML5 Audio API for playback

## Project Structure

```
Music_Player/
├── backend/              # Ruby API server
│   ├── music_api.rb     # Sinatra API endpoints
│   └── Gemfile          # Ruby dependencies
├── frontend/            # Next.js application
│   ├── app/            # Next.js app directory
│   │   ├── page.tsx    # Main application page
│   │   ├── layout.tsx  # Root layout
│   │   └── globals.css # Global styles
│   ├── components/     # React components
│   │   ├── Sidebar.tsx
│   │   ├── AlbumsView.tsx
│   │   ├── SongsView.tsx
│   │   ├── ArtistsView.tsx
│   │   └── PlayerBar.tsx
│   └── package.json
└── Ruby_Musicplayer/   # Music files and data
    ├── albums.txt      # Album metadata
    ├── images/         # Album artwork
    └── tracks/         # Audio files
```

## Features

- 🎵 **Album View**: Grid display of albums with track listings
- 🎤 **Artists View**: Browse music by artist
- 📝 **Songs View**: Complete list of all tracks
- ⏯️ **Player Controls**: Play, pause, previous, next with progress bar
- 🎨 **Apple Music UI**: Modern dark theme with pink accents
- 📱 **Responsive**: Works on different screen sizes

## Setup Instructions

### Prerequisites

- **Node.js** (v18 or higher)
- **Ruby** (v3.0 or higher)
- **Bundler** gem installed

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install Ruby dependencies:
   ```bash
   bundle install
   ```

3. Start the Ruby API server:
   ```bash
   ruby music_api.rb
   ```

   The API will run on `http://localhost:4567`

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install Node.js dependencies:
   ```bash
   npm install
   ```

3. Start the Next.js development server:
   ```bash
   npm run dev
   ```

   The frontend will run on `http://localhost:3000`

## API Endpoints

The Ruby backend provides the following REST API endpoints:

- `GET /api/albums` - Get all albums with tracks
- `GET /api/albums/:id` - Get specific album by ID
- `GET /api/tracks` - Get all tracks from all albums
- `GET /api/artists` - Get all unique artists with album counts
- `GET /files/*` - Serve static files (images and audio)

## Usage

1. Start both backend and frontend servers (see setup instructions above)
2. Open your browser to `http://localhost:3000`
3. Click on an album to view its tracks
4. Click on a track to start playing
5. Use the player controls at the bottom to control playback
6. Navigate between views using the sidebar (Albums, Songs, Artists, Playlists)

## Color Scheme

The app uses an Apple Music-inspired dark theme:

- **Background Dark**: `#2B2D3A`
- **Sidebar**: `#23252F`
- **Cards**: `#353747`
- **Accent Pink**: `#FF2D55`
- **Player Bar**: `#4B4D5E`

## Technologies Used

### Frontend
- Next.js 15
- React 18
- TypeScript
- Tailwind CSS
- Axios (HTTP client)

### Backend
- Ruby
- Sinatra (Web framework)
- Sinatra-CORS (Cross-origin support)
- Puma (Web server)

## Development

### Frontend Development
```bash
cd frontend
npm run dev     # Start dev server
npm run build   # Build for production
npm run start   # Start production server
```

### Backend Development
```bash
cd backend
ruby music_api.rb  # Start API server
```

## Troubleshooting

### CORS Issues
If you encounter CORS errors, ensure the backend is running on port 4567 and the frontend is configured to point to `http://localhost:4567`.

### Audio Files Not Playing
- Check that audio files exist in `Ruby_Musicplayer/tracks/`
- Verify file paths in `albums.txt` are correct
- Ensure the backend server has read permissions for the files

### Port Already in Use
- Backend: Change port in `music_api.rb` (line with `set :port, 4567`)
- Frontend: Use `npm run dev -- -p 3001` to run on a different port

## Future Enhancements

- Volume controls
- Shuffle and repeat modes
- Playlist creation and management
- Search functionality
- User authentication
- Favorites/liked songs
- Queue management
- Keyboard shortcuts

## License

This project is for educational purposes.
