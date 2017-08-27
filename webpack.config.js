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

const rules = [
  
  {
    loader: 'elm-hot-loader',
    test: /\.elm$/,
    exclude: [ /elm-stuff/, /node_modules/ ],
  },
  {
   loader: 'elm-webpack-loader',
   test: /\.elm$/,
   options: {
      verbose: true,
      debug: true,
      warn: true,
    }
  },
  {
    test: /\.json$/,
    loader: 'json-loader'
  },
]
module.exports = {
  devtool: 'eval',

  entry: [
    paths.entry
  ],
  output: {

    pathinfo: true,

    path: paths.dist,

    filename: 'app',

    publicPath: '/'
  },
  resolve: {
    extensions: ['.js', '.elm']
  },
  module: {rules, noParse:  /\.elm$/},
  plugins: [
     new webpack.DefinePlugin({
      API_URL: JSON.stringify('http://localhost:8080/temperatures'),
      SOCKET_URL: JSON.stringify('ws://localhost:8080/websocket')
    }),
    new HtmlWebpackPlugin({
      inject: true,
      title: "Sensor Data | DEV",
      template: paths.template,
      favicon: paths.favicon
    }),
    new webpack.HotModuleReplacementPlugin()
  ],
   devServer: {
    contentBase: paths.dist,
    historyApiFallback: true,
    port: 9090,
    compress: false,
    inline: true,
    hot: true,
    host: '0.0.0.0',
    stats: {
      assets: true,
      children: false,
      chunks: false,
      hash: false,
      modules: false,
      publicPath: false,
      timings: true,
      version: false,
      warnings: true,
      colors: {
        green: '\u001b[32m',
      },
    },
  }
};