/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      colors: {
        primary: {
          DEFAULT: '#8B5CF6',
          dark: '#7c3aed',
        },
        secondary: '#10B981',
        dark: {
          DEFAULT: '#000000',
          surface: '#1F2937',
        },
      },
    },
  },
  plugins: [],
}
