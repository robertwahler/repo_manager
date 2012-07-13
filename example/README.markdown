Repoman Example
===============

This is a simple example demonstrating the following features.

* relative paths (not absolute) in config/repo.conf making the folder portable
* extending Repoman tasks, see tasks/update.rb


Generating this example
-----------------------

    mkdir example && cd example

create config structure with the built-in generate:init task

    repo generate:init config


change the generate path from absolute to relative

      diff --git a/example/config/repo.conf b/example/config/repo.conf
      index ed80bc6..e28637d 100644
      --- a/example/config/repo.conf
      +++ b/example/config/repo.conf
      @@ -11,7 +11,7 @@ options:
       folders:

         # main repo configuration files
      -  assets  : /home/robert/workspace/repoman/example/config/assets
      +  assets  : assets

         #
         # repo user tasks, file extentions can be '.rb' or '.thor'
      @@ -26,7 +26,7 @@ folders:
         #
         #         c:/dat/condenser/tasks
         #
      -  tasks        : /home/robert/workspace/repoman/example/config/tasks
      +  tasks        : tasks

       logging:
         loggers:
      @@ -46,7 +46,7 @@ logging:
             name          : logfile
             level         : debug
             truncate      : true
      -      filename      : '/home/robert/workspace/repoman/example/config/repo.log'
      +      filename      : 'repo.log'
             layout:
               type        : Pattern
               pattern     : '[%d] %l %c : %m\n'


