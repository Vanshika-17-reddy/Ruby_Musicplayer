import { Album, Track } from '@/app/page';

type PlayerBarProps = {
  isPlaying: boolean;
  currentAlbum?: Album;
  currentTrack?: Track;
  currentTime: number;
  duration: number;
  onPlayPause: () => void;
  onPrevious: () => void;
  onNext: () => void;
  onSeek: (time: number) => void;
  apiUrl: string;
};

export default function PlayerBar({
  isPlaying,
  currentAlbum,
  currentTrack,
  currentTime,
  duration,
  onPlayPause,
  onPrevious,
  onNext,
  onSeek,
  apiUrl,
}: PlayerBarProps) {
  const formatTime = (seconds: number) => {
    if (isNaN(seconds)) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleProgressClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const percentage = x / rect.width;
    onSeek(percentage * duration);
  };

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-player-bg h-20 border-t border-gray-800 flex items-center px-6 z-50">
      {/* Left: Now Playing Info */}
      <div className="flex items-center w-1/3">
        {currentAlbum && currentTrack && (
          <>
            <img
              src={`${apiUrl}/files/${currentAlbum.artwork}`}
              alt={currentAlbum.title}
              className="w-12 h-12 rounded object-cover"
            />
            <div className="ml-3">
              <p className="text-text-white text-sm font-medium">{currentTrack.name}</p>
              <p className="text-text-gray text-xs">{currentAlbum.artist}</p>
            </div>
          </>
        )}
      </div>

      {/* Center: Controls */}
      <div className="flex flex-col items-center w-1/3">
        <div className="flex items-center gap-6 mb-2">
          {/* Previous Button */}
          <button
            onClick={onPrevious}
            className="text-text-white hover:text-accent-pink transition-colors"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/>
            </svg>
          </button>

          {/* Play/Pause Button */}
          <button
            onClick={onPlayPause}
            className={`w-10 h-10 rounded-full flex items-center justify-center transition-all ${
              isPlaying ? 'bg-accent-pink' : 'bg-text-white'
            }`}
          >
            {isPlaying ? (
              <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/>
              </svg>
            ) : (
              <svg className="w-5 h-5 text-bg-dark" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z"/>
              </svg>
            )}
          </button>

          {/* Next Button */}
          <button
            onClick={onNext}
            className="text-text-white hover:text-accent-pink transition-colors"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M16 18h2V6h-2v12zM6 18l8.5-6L6 6v12z"/>
            </svg>
          </button>
        </div>

        {/* Progress Bar */}
        <div className="flex items-center gap-2 w-full max-w-md">
          <span className="text-text-gray text-xs">{formatTime(currentTime)}</span>
          <div
            onClick={handleProgressClick}
            className="flex-1 h-1 bg-gray-600 rounded-full cursor-pointer overflow-hidden"
          >
            <div
              className="h-full bg-accent-pink transition-all"
              style={{ width: `${duration ? (currentTime / duration) * 100 : 0}%` }}
            />
          </div>
          <span className="text-text-gray text-xs">{formatTime(duration)}</span>
        </div>
      </div>

      {/* Right: Volume/Extra Controls (placeholder) */}
      <div className="w-1/3 flex justify-end">
        {/* Add volume controls here if needed */}
      </div>
    </div>
  );
}
