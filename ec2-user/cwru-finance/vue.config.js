publicPath: process.env.NODE_ENV === 'production'
module.exports = {
  devServer: {
    disableHostCheck: true
  },
  publicPath: process.env.NODE_ENV === 'production' ? '/client/': '/',
  outputDir: "../Servlet/ROOT/client"
  // ... other options
}