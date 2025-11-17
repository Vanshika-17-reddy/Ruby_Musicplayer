import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        'bg-dark': '#2B2D3A',
        'bg-sidebar': '#23252F',
        'bg-card': '#353747',
        'text-white': '#FFFFFF',
        'text-gray': '#9A9AA6',
        'accent-pink': '#FF2D55',
        'accent-blue': '#007AFF',
        'player-bg': '#4B4D5E',
      },
    },
  },
  plugins: [],
};
export default config;
