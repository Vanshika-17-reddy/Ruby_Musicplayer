import { Album } from '@/app/page';
import Image from 'next/image';

type AlbumsViewProps = {
  albums: Album[];
  selectedAlbum: number;
  selectedTrack: number;
  onAlbumClick: (albumId: number) => void;
  onTrackClick: (trackId: number) => void;
  apiUrl: string;
};

export default function AlbumsView({
  albums,
  selectedAlbum,
  selectedTrack,
  onAlbumClick,
  onTrackClick,
  apiUrl,
}: AlbumsViewProps) {
  return (
    <div className="flex h-full">
      {/* Albums Grid - Left Half */}
      <div className="w-1/2 p-8">
        <div className="grid grid-cols-2 gap-4">
          {albums.map((album, index) => (
            <div
              key={index}
              onClick={() => onAlbumClick(index)}
              className="cursor-pointer group"
            >
              <div className="bg-bg-card p-2 rounded-lg hover:bg-opacity-80 transition-all">
                <div className="relative aspect-square mb-2">
                  <img
                    src={`${apiUrl}/files/${album.artwork}`}
                    alt={album.title}
                    className="w-full h-full object-cover rounded"
                  />
                </div>
                {index === selectedAlbum && (
                  <div className="h-1 bg-accent-pink rounded-full mt-1"></div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Track List - Right Half */}
      <div className="w-1/2 p-8 overflow-y-auto">
        <h2 className="text-2xl font-bold mb-6">
          {albums[selectedAlbum]?.title || 'Select an album'}
        </h2>

        <div className="space-y-2">
          {albums[selectedAlbum]?.tracks.map((track, index) => (
            <div
              key={index}
              onClick={() => onTrackClick(index)}
              className={`flex items-center p-3 rounded-lg cursor-pointer transition-all ${
                index === selectedTrack
                  ? 'bg-bg-card border-l-4 border-accent-pink text-text-white'
                  : 'bg-bg-card hover:bg-opacity-80 text-text-gray'
              }`}
            >
              <span className="w-8 text-sm">{index + 1}</span>
              <span className="flex-1">{track.name}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
