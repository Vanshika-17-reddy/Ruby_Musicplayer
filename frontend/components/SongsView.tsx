import { AllTrack } from '@/app/page';

type SongsViewProps = {
  tracks: AllTrack[];
  selectedAlbum: number;
  selectedTrack: number;
  onTrackClick: (albumId: number, trackId: number) => void;
  apiUrl: string;
};

export default function SongsView({
  tracks,
  selectedAlbum,
  selectedTrack,
  onTrackClick,
}: SongsViewProps) {
  return (
    <div className="p-8 overflow-y-auto h-full">
      <h2 className="text-3xl font-bold mb-6">All Songs</h2>

      <div className="space-y-2">
        {tracks.map((track, index) => {
          const isPlaying = selectedAlbum === track.album_id && selectedTrack === track.track_id;

          return (
            <div
              key={index}
              onClick={() => onTrackClick(track.album_id, track.track_id)}
              className={`flex items-center p-4 rounded-lg cursor-pointer transition-all ${
                isPlaying
                  ? 'bg-bg-card border-l-4 border-accent-pink'
                  : 'bg-bg-card hover:bg-opacity-80'
              }`}
            >
              <span className={`w-10 text-sm ${isPlaying ? 'text-text-white' : 'text-text-gray'}`}>
                {index + 1}
              </span>
              <div className="flex-1">
                <p className={`font-medium ${isPlaying ? 'text-text-white' : 'text-text-gray'}`}>
                  {track.name}
                </p>
                <p className="text-text-gray text-sm mt-1">{track.artist}</p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
