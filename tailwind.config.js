/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        quantum: {
          silver: '#E8ECF0',
          teal: '#5B8A9A',
          'teal-dark': '#3D6472',
          coral: '#FF9B85',
        },
      },
    },
  },
  plugins: [],
}
