'use client';

import { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import Sidebar from '@/components/Sidebar';
import AlbumsView from '@/components/AlbumsView';
import SongsView from '@/components/SongsView';
import ArtistsView from '@/components/ArtistsView';
import PlayerBar from '@/components/PlayerBar';

const API_URL = 'http://localhost:4567';

export type Track = {
  name: string;
  location: string;
};

export type Album = {
  title: string;
  artist: string;
  artwork: string;
  tracks: Track[];
};

export type AllTrack = {
  name: string;
  location: string;
  artist: string;
  album: string;
  album_id: number;
  track_id: number;
  artwork: string;
};

export type ViewType = 'albums' | 'songs' | 'artists' | 'playlists';

export default function Home() {
  const [currentView, setCurrentView] = useState<ViewType>('albums');
  const [albums, setAlbums] = useState<Album[]>([]);
  const [allTracks, setAllTracks] = useState<AllTrack[]>([]);
  const [selectedAlbum, setSelectedAlbum] = useState<number>(0);
  const [selectedTrack, setSelectedTrack] = useState<number>(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);

  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Load albums on mount
  useEffect(() => {
    loadAlbums();
    loadAllTracks();
  }, []);

  const loadAlbums = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/albums`);
      setAlbums(response.data);
    } catch (error) {
      console.error('Error loading albums:', error);
    }
  };

  const loadAllTracks = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/tracks`);
      setAllTracks(response.data);
    } catch (error) {
      console.error('Error loading tracks:', error);
    }
  };

  const playTrack = (albumId: number, trackId: number) => {
    setSelectedAlbum(albumId);
    setSelectedTrack(trackId);

    if (audioRef.current && albums[albumId]) {
      const track = albums[albumId].tracks[trackId];
      audioRef.current.src = `${API_URL}/files/${track.location}`;
      audioRef.current.play();
      setIsPlaying(true);
    }
  };

  const togglePlayPause = () => {
    if (audioRef.current) {
      if (isPlaying) {
        audioRef.current.pause();
        setIsPlaying(false);
      } else {
        audioRef.current.play();
        setIsPlaying(true);
      }
    }
  };

  const playPrevious = () => {
    if (selectedTrack > 0) {
      playTrack(selectedAlbum, selectedTrack - 1);
    } else if (selectedAlbum > 0) {
      const prevAlbum = selectedAlbum - 1;
      playTrack(prevAlbum, albums[prevAlbum].tracks.length - 1);
    }
  };

  const playNext = () => {
    if (albums[selectedAlbum] && selectedTrack < albums[selectedAlbum].tracks.length - 1) {
      playTrack(selectedAlbum, selectedTrack + 1);
    } else if (selectedAlbum < albums.length - 1) {
      playTrack(selectedAlbum + 1, 0);
    }
  };

  const handleTimeUpdate = () => {
    if (audioRef.current) {
      setCurrentTime(audioRef.current.currentTime);
      setDuration(audioRef.current.duration || 0);
    }
  };

  const handleSeek = (time: number) => {
    if (audioRef.current) {
      audioRef.current.currentTime = time;
      setCurrentTime(time);
    }
  };

  return (
    <div className="flex h-screen bg-bg-dark">
      <Sidebar currentView={currentView} onViewChange={setCurrentView} />

      <main className="flex-1 overflow-auto pb-20">
        {currentView === 'albums' && (
          <AlbumsView
            albums={albums}
            selectedAlbum={selectedAlbum}
            selectedTrack={selectedTrack}
            onAlbumClick={(id) => {
              setSelectedAlbum(id);
              playTrack(id, 0);
            }}
            onTrackClick={(trackId) => playTrack(selectedAlbum, trackId)}
            apiUrl={API_URL}
          />
        )}

        {currentView === 'songs' && (
          <SongsView
            tracks={allTracks}
            selectedAlbum={selectedAlbum}
            selectedTrack={selectedTrack}
            onTrackClick={(albumId, trackId) => playTrack(albumId, trackId)}
            apiUrl={API_URL}
          />
        )}

        {currentView === 'artists' && (
          <ArtistsView apiUrl={API_URL} />
        )}

        {currentView === 'playlists' && (
          <SongsView
            tracks={allTracks}
            selectedAlbum={selectedAlbum}
            selectedTrack={selectedTrack}
            onTrackClick={(albumId, trackId) => playTrack(albumId, trackId)}
            apiUrl={API_URL}
          />
        )}
      </main>

      <PlayerBar
        isPlaying={isPlaying}
        currentAlbum={albums[selectedAlbum]}
        currentTrack={albums[selectedAlbum]?.tracks[selectedTrack]}
        currentTime={currentTime}
        duration={duration}
        onPlayPause={togglePlayPause}
        onPrevious={playPrevious}
        onNext={playNext}
        onSeek={handleSeek}
        apiUrl={API_URL}
      />

      <audio
        ref={audioRef}
        onTimeUpdate={handleTimeUpdate}
        onEnded={playNext}
      />
    </div>
  );
}
