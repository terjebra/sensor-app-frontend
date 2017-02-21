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
    'webpack-dev-server/client',
    paths.entry
  ],
  output: {

    pathinfo: true,

    path: paths.dist,

    filename: 'app',

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
        loader: 'elm-hot!elm-webpack?verbose=true&warn=true&debug=true&pathToMake=' + paths.elmMake
      }
    ]
  },
  plugins: [
     new webpack.DefinePlugin({
      API_URL: JSON.stringify('http://localhost:4000/api/temperatures'),
      SOCKET_URL: JSON.stringify('ws://localhost:4000/socket/websocket')
    }),
    new HtmlWebpackPlugin({
      inject: true,
      title: "Sensor Data | DEV",
      template: paths.template,
      favicon: paths.favicon
    }),
    new webpack.HotModuleReplacementPlugin()
  ]
};