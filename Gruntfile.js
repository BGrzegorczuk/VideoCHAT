//Gruntfile
module.exports = function(grunt) {

//Initializing the configuration object
    grunt.initConfig({
        // Task configuration
        copy: {
            vendor_css: {
                expand: true,
                cwd: './src/css',
                src: '**/*.css',
                dest: './public/stylesheets',
                flatten: true,
                filter: 'isFile'
            },
            vendor_js: {
                expand: true,
                cwd: './src/js/vendor',
                src: '**/*.js',
                dest: './public/javascripts/vendor',
                filter: 'isFile'
            },
        },
        coffee: {
            scripts: {
                expand: true,
                cwd: './src/coffee',
                src: '**/*.coffee',
                dest: './public/javascripts',
                ext: '.js'
            },
            routes: {
                expand: true,
                cwd: './src/routes',
                src: '*.coffee',
                dest: './routes',
                ext: '.js'
            },
            tests: {
                expand: true,
                cwd: './tests/coffee',
                src: '*.coffee',
                dest: './tests',
                ext: '.test.js'
            }
        },
        sass: {
            compile: {
                files: [{
                    expand: true,
                    cwd: './src/sass',
                    style: 'compressed',
                    src: '**/*.sass',
                    dest: './public/stylesheets',
                    ext: '.css'
                }]
            }
        },
        mocha: {
            all: {
                src: ['./tests/test-runner.html'],
                options: {
                    reporter: 'Nyan',
                }
            }
        },
        watch: {
            coffee: {
                files: ['./src/**/*.coffee'],
                tasks: ['coffee']
            },
            sass: {
                files: ['./src/sass/**/*.sass'],
                tasks: ['sass']
            },
            tests: {
                files: ['./tests/coffee/*.coffee'],
                tasks: ['coffee:tests']
            },
            // configFiles: {
            //     files: [ 'Gruntfile.js'],
            //     options: {
            //         reload: true
            //     }
            // },
            livereload: {
                options: {
                    livereload: true,
                    reload: true
                },
                files: ['./public/**/*', './templates/**/*']
            }
        }
    });

    // Load plugins
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-newer');
    grunt.loadNpmTasks('grunt-mocha');

    // Define tasks
    grunt.registerTask('compileCoffeeAndSass', ['newer:coffee', 'newer:sass']);
    grunt.registerTask('build', ['newer:copy', 'compileCoffeeAndSass', 'watch']);
    grunt.registerTask('compileTests', ['newer:coffee:tests']);

    // for running tests in the console in node env
    // (TODO: fails because of using chai.should() for some reason - FIX IT)
    // grunt.registerTask('runTests', ['compileTests', 'mocha:all']);

};


