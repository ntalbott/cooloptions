= CoolOptions
    by Nathaniel Talbott <nathaniel@terralien.com>
    http://cooloptions.rubyforge.org/

== DESCRIPTION:
  
CoolOptions is a simple wrapper around optparse that provides less options and more convenience.

== SYNOPSYS:

=== Declaration:

  options = CoolOptions.parse!("[options] PROJECTNAME") do |o|
    o.on :svk,              "[no-]svk",              "Use svk.",                              true
    o.on :project_path,     "project-path PATH",     "Root of project workspaces.",           File.expand_path("~/svk")
    o.on :repository,       "repository URL",        "Remote subversion repository."          
    o.on :repository_path,  "repository-path PATH",  "Remote repository path.",               "/",       "l"
    o.on :mirror_path,      "mirror-path SVKPATH",   "SVK mirror path.",                      "//"
    o.on :local_path,       "local-path SVKPATH",    "SVK local path.",                       "//local", "t"
    o.on :create_structure, "[no-]create-structure", "Create trunk/tags/branches structure.", true
    o.on :finish,           "[no-]finish"          , "Prep and commit the new project.",      true
    
    o.after do |r|
      r.project_path = File.expand_path(r.project_path)
      raise "Invalid path." unless File.exist?(r.project_path)
      r.project_name = ARGV.shift
    end
  end
  
=== Usage:

  $ ./new_rails_project --no-svk -r http://terralien.com/svn/terralien/ --no-finish
  
=== Result:
  
  p options.svk                 # => false
  p options.project_path        # => '/Users/ntalbott/svk'
  p options.repository          # => 'http://terralien.com/svn/terralien/'
  p options.finish              # => false
  p options.create_structure    # => true
  p options.project_name        # => 'myproject'

=== Also:

  $ ./new_rails_project --help                                                               
  Usage: t.rb [options] PROJECTNAME
      -s, --[no-]svk                   Use svk.
                                       Default is: true
      -p, --project-path PATH          Root of project workspaces.
                                       Default is: /Users/ntalbott/svk
      -r, --repository URL             Remote subversion repository.
      -l, --repository-path PATH       Remote repository path.
                                       Default is: /
      -m, --mirror-path SVKPATH        SVK mirror path.
                                       Default is: //
      -t, --local-path SVKPATH         SVK local path.
                                       Default is: //local
      -c, --[no-]create-structure      Create trunk/tags/branches structure.
                                       Default is: true
      -f, --[no-]finish                Prep and commit the new project.
                                       Default is: true
      -h, --help                       This help info.

== REQUIREMENTS:

optparse (included in Ruby stdlib)

== INSTALL:

  sudo gem install cooloptions

== LICENSE:

The RUBY License

Copyright (c) 2006 Nathaniel Talbott and Terralien, Inc. All Rights Reserved.