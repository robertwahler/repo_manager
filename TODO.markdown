TODO
====

* add "config" command to manage config file. i.e. "repo config add folder/test1 --name test1"
* add back dry-run option when adding features that can be destructive, i.e. commit, pull, copy, add, ...
* remove configatron usage from app.rb, put repos in @options hash
* status should show summary
* add feature tests for all combinations of XY result codes from 'git status --porcelain'
* need --filters switch using list option, don't treat ARGV unknown as list of filters

subcommands
----------



  list
  path
  status


  init

  remote
    <no arg>
    show origin
    add origin git@red:grape/games/saves/real_myst.git

  config
    <no arg>
    branch.master.merge refs/heads/master
    core.autocrlf false
    core.filemode false config branch.master.remote origin

    --list

  push
    <no arg>
    peach
    brown master

    --tags


  pull
    <no arg>
    origin master
    brown HEAD

  add
    <no arg>
    .

    -A
    -u

  commit
    -a
    -m

### parsing procedure

grab all general options with no error raising, this will get
all known global options both in front and behind subcommands

example:

    repo --filters test1,test2 config branch.master.merge refs/heads/master --unset
    repo config --list --filters test1,test2
    (not allowed) repo --list config --filters test1,test2

code:

    options.parse!

result ARGV:

    config branch.master.merge refs/heads/master --unset
    config --list
    (not allowed) --list config

if ARGV still there, then everything left is an action/subcommand, its args and
options, or an invalid option, then parse in order what is left of ARGV and
stop at first non option, this will be the action/subcommand

    options.order!
    subcommand = ARGV.shift if ARGV

    case subcommand
      when 'config'
        OptionParser.new do |opts|
          opts.on("--list", "config listing") do |l|
            options['config'] = {[:list] = l}
          end
        end
      end



now validate remaining options, if any


    options.parse! with execeptions

throw exception, option unknown or not permitted with action





