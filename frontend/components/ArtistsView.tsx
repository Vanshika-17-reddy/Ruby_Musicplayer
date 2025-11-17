'use client';

import { useState, useEffect } from 'react';
import axios from 'axios';

type Artist = {
  name: string;
  album_count: number;
  albums: any[];
};

type ArtistsViewProps = {
  apiUrl: string;
};

export default function ArtistsView({ apiUrl }: ArtistsViewProps) {
  const [artists, setArtists] = useState<Artist[]>([]);

  useEffect(() => {
    loadArtists();
  }, []);

  const loadArtists = async () => {
    try {
      const response = await axios.get(`${apiUrl}/api/artists`);
      setArtists(response.data);
    } catch (error) {
      console.error('Error loading artists:', error);
    }
  };

  return (
    <div className="p-8 overflow-y-auto h-full">
      <h2 className="text-3xl font-bold mb-6">Artists</h2>

      <div className="space-y-3">
        {artists.map((artist, index) => (
          <div
            key={index}
            className="bg-bg-card p-5 rounded-lg hover:bg-opacity-80 transition-all cursor-pointer"
          >
            <h3 className="text-xl font-semibold text-text-white">{artist.name}</h3>
            <p className="text-text-gray text-sm mt-1">
              {artist.album_count} album{artist.album_count > 1 ? 's' : ''}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
