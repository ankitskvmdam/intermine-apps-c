fs = require "fs"
cs = require 'coffee-script'
eco = require "eco"


# --------------------------------------------


# Main input/output.
MAIN =
    INPUT: "src/widgets.coffee"
    OUTPUT: "js/widgets.js"
# Test input/output.
SPEC =
    INPUT: "tests/spec.coffee"
    OUTPUT: "tests/spec.js"
# Templates dir.
TEMPLATES = "src/templates"
# Which folders to watch for changes?
WATCH = [ "src", "src/templates" ]

# ANSI Terminal colors.
COLORS =
    BOLD: '\033[0;1m'
    RED: '\033[0;31m'
    GREEN: '\033[0;32m'
    BLUE: '\033[0;34m'
    DEFAULT: '\033[0m'

# --------------------------------------------


option '-m', '--minify', 'should we minify main library for production?'
option '-w', '--watch', 'should we watch source directories for changes?'

# Compile widgets.coffee and .eco templates into one output. Do not use globals for JST.
task "compile:main", "compile widgets library and templates together", (options) ->
    main options.minify, ->

    # Watch for changes?
    if options.watch
        done = true # Have we finished with main compilation step?
        for dir in WATCH
            console.log "#{COLORS.BOLD}Watching #{dir}#{COLORS.DEFAULT}"
            fs.watch dir, (event, file) ->
                if event in [ "rename", "change" ]
                    console.log "#{COLORS.BLUE}Change detected in #{file}#{COLORS.DEFAULT}"
                    if done
                        done = false
                        main options.minify, -> done = true

# Compile tests spec.coffee.
task "compile:tests", "compile tests spec", (options) ->
    console.log "#{COLORS.BOLD}Compiling tests#{COLORS.DEFAULT}"

    # Clean.
    fs.unlink SPEC.OUTPUT

    # CoffeeScript compile.
    write SPEC.OUTPUT, cs.compile fs.readFileSync SPEC.INPUT, "utf-8"

    # Done.
    console.log "#{COLORS.GREEN}Tests compilation a success#{COLORS.DEFAULT}"


# --------------------------------------------


main = (minify, callback) ->
    console.log "#{COLORS.BOLD}Compiling main#{COLORS.DEFAULT}"

    # Clean.
    fs.unlink MAIN.OUTPUT

    # Head.
    head = (cb) -> cb "(function() {"

    # Compile templates.
    templates = (cb) ->
        tmpl = [ "var JST = {};" ]
        walk TEMPLATES, (err, files) ->
            if err then throw new Error('problem walking templates')
            else
                # Only take eco files.
                match = /\.eco$/
                for file in files
                    if file.match match
                        # Read in, precompile & compress.
                        js = eco.precompile fs.readFileSync file, "utf-8"
                        name = file.split('/').pop()
                        tmpl.push uglify "JST['#{name}'] = #{js}"
                cb tmpl

    # Compile main library (and optionally minify).
    widgets = (cb) ->
        compiled = cs.compile fs.readFileSync(MAIN.INPUT, "utf-8"), bare: "on"
        if minify then cb uglify compiled else cb compiled

    # Close.
    close = (cb) -> cb "}).call(this);"

    done = (results) ->
        output = []

        # Combine them all.
        for result in results
            for index, item of result
                if item instanceof Array then output.push sub for sub in item else output.push item
        
        # Write them all at once
        write MAIN.OUTPUT, output.join "\n"
        
        # We are done.
        console.log "#{COLORS.GREEN}Main compilation a success#{COLORS.DEFAULT}"

    # This is the queue order.
    queue [ head, templates, widgets, close ], done

# A serial queue that waits until all resources have returned and then calls back.
queue = (calls, callback) ->
    make = (index) ->
      ->
        counter--
        all[index] = arguments
        callback(all) unless counter

    # How many do we have?
    counter = calls.length
    # Store results here.
    all = []

    i = 0
    for call in calls
        call make i++

# Traverse a directory and return a list of files (async, recursive).
walk = (path, callback) ->
    results = []
    # Read directory.
    fs.readdir path, (err, list) ->
        # Problems?
        return callback err if err
        
        # Get listing length.
        pending = list.length
        
        return callback null, results unless pending # Done already?
        
        # Traverse.
        list.forEach (file) ->
            # Form path
            file = "#{path}/#{file}"
            fs.stat file, (err, stat) ->
                # Subdirectory.
                if stat and stat.isDirectory()
                    walk file, (err, res) ->
                        # Append result from sub.
                        results = results.concat(res)
                        callback null, results unless --pending # Done yet?
                # A file.
                else
                    results.push file
                    callback null, results unless --pending # Done yet?

# Append to existing file.
write = (path, text) ->
    fs.open path, "a", 0666, (e, id) ->
        if e then throw new Error(e)
        fs.write id, text, null, "utf8"

# Compress using `uglify-js`.
uglify = (input) ->
    jsp = require("uglify-js").parser
    pro = require("uglify-js").uglify

    pro.gen_code pro.ast_squeeze pro.ast_mangle jsp.parse input