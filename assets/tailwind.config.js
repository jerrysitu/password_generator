module.exports = {
  purge: {
    enabled: process.env.MIX_ENV === "prod",
    content: ["../lib/**/*.eex", "../lib/**/*.leex", "../lib/**/*.ex"],
    options: {
      whitelist: [/phx/, /nprogress/],
    },
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
