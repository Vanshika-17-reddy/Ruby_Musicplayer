import { ViewType } from '@/app/page';

type MenuItem = {
  name: string;
  view: ViewType;
};

type SidebarProps = {
  currentView: ViewType;
  onViewChange: (view: ViewType) => void;
};

export default function Sidebar({ currentView, onViewChange }: SidebarProps) {
  const menuItems: MenuItem[] = [
    { name: 'Playlists', view: 'playlists' },
    { name: 'Artists', view: 'artists' },
    { name: 'Albums', view: 'albums' },
    { name: 'Songs', view: 'songs' },
  ];

  return (
    <div className="w-52 bg-bg-sidebar h-full flex flex-col">
      <div className="p-5">
        <h2 className="text-text-gray text-sm font-semibold tracking-wider">LIBRARY</h2>
      </div>

      <nav className="flex-1 px-4">
        {menuItems.map((item) => (
          <button
            key={item.view}
            onClick={() => onViewChange(item.view)}
            className={`w-full text-left px-3 py-2 rounded-lg mb-1 transition-all ${
              currentView === item.view
                ? 'bg-bg-card text-text-white border-l-4 border-accent-pink'
                : 'text-text-gray hover:text-text-white hover:bg-bg-card/50'
            }`}
          >
            <span className="text-base">{item.name}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}
