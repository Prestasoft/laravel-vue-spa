const { join, resolve } = require('path')
const mix = require('laravel-mix')

mix
  .js('resources/js/app.js', 'public/dist/js')
  .vue()
  .sass('resources/sass/app.scss', 'public/dist/css')
  .disableNotifications()

mix.version()

if (!mix.inProduction()) {
  mix.sourceMaps()
}

mix.webpackConfig({
  resolve: {
    extensions: ['.js', '.json', '.vue'],
    alias: {
      '~': join(__dirname, './resources/js')
    }
  },
  output: {
    chunkFilename: 'dist/js/[chunkhash].js'
  }
})
