# dotfiles
my zsh, starship, git, etc config files. Also instructions for setting up my compy. good stuff.

## Setting Up Ruby & Rails on MacOS
Make sure you have xcode w/ command line tools & homebrew
```
$ brew install chruby
  # Add the following to the ~/.zshrc file:
  # source /usr/local/opt/chruby/share/chruby/chruby.sh
  # source /usr/local/opt/chruby/share/chruby/auto.sh
$ brew install ruby-install
$ ruby-install ruby x.y.z #check version against the readme & make a cup of coffee...
$ brew install postgres@14
$ brew services start postgresql@14
$ brew install node@18
  # export PATH="/opt/homebrew/opt/node@18/bin:$PATH" #add to PATH, because in homebrew the node install is only a keg
$ cd to rails_webapp_project/
$ chruby x.y.z #make sure to check project
$ which ruby  #should NOT be /usr/bin/ruby
$ gem install bundler
$ gem install foreman
$ brew install yarn
  # set your .env file
  # follow further project specific steps, e.g. initializing the DB etc.
```
