'use strict';

module.exports = function(grunt) {

  grunt.initConfig({
    browserify: {
      options: {
        transform: [require('grunt-react').browserify],
        browserifyOptions: {
          debug: true
        }
      },
      painelsocial: {
        src: 'src/painelsocial.js',
        dest: 'build/painelsocial.js'
      },
      sandbox: {
        src: 'src/sandbox.js',
        dest: 'build/sandbox.js'
      }
    },
    copy: {
      all: {
        files: [
          // makes all src relative to cwd
          {expand: true, cwd: 'src/', dest: 'build/', src: ['**', '!**/*.jsx', '!**/*.js']},
        ]
      }
    },
    watch: {
      scripts: {
        files: ['./src/**/*.js', './src/**/*.jsx'],
        tasks: ['browserify']
      },
      'everything else': {
        files: ['./src/**', '!./src/**/*.jsx', '!./src/**/*.js'],
        tasks: ['copy']
      },
      livereload: {
        files: './build/**',
        options: {
          livereload: true
        }
      }
    },
    connect: {
      server: {
        options: {
          port: 8000,
          useAvaiablePort: true,
          livereload: true,
          hostname: '*',
          base: './build'
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-react');

  grunt.registerTask('build', ['browserify', 'copy']);
  grunt.registerTask('serve', ['build', 'connect:server', 'watch']);
};
