const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require( 'path' );

const paths = {
  entry: path.resolve('./src/index'),
  dist: path.resolve('./dist'),
  template: path.resolve('./src/index.html'),
  favicon: path.resolve('./src/fav.ico'),
  elmMake: path.resolve(__dirname, './node_modules/.bin/elm-make')
}

module.exports = {

  devtool: 'eval',

   entry: [
    paths.entry
  ],
  output: {

    pathinfo: true,

    path: paths.dist,

    filename: 'app-[hash]',

    publicPath: '/'
  },
  resolve: {
    extensions: ['', '.js', '.elm']
  },
  module: {
    noParse: /\.elm$/,
    loaders: [
        {
        test: /\.elm$/,
        exclude: [ /elm-stuff/, /node_modules/ ],

        // Use the local installation of elm-make
        loader: 'elm-webpack',
        query: {
          pathToMake: paths.elmMake
        }
      },
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      API_URL: JSON.stringify('http://46.101.41.13:8080/api/temperatures'),
      SOCKET_URL: JSON.stringify('ws://46.101.41.13:8080/socket/websocket')
    }),
    new HtmlWebpackPlugin({
      inject: true,
      title: "Sensor Data",
      template: paths.template,
      favicon: paths.favicon
    })
  ]
};