var path = require('path');

module.exports = {
    context: path.join(__dirname, 'src'),

    entry: {
        '': ['./index.html', './painelsocial.html', './sandbox.html'],
        painelsocial: './painelsocial.jsx',
        sandbox: './sandbox.jsx'
    },

    output: {
        filename: '[name].js',
        path: path.join(__dirname, 'build')
    },

    module: {
        loaders: [
            {test: /\.jsx?$/, exclude: /node_modules/, loader: 'babel-loader', query: {presets: ['es2015', 'react']}},
            {test: /\.html$/, loader: 'file?name=[path][name].[ext]'}
        ]
    }
};