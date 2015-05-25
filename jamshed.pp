$local_user = "jamshed"
$local_home = "/home/$local_user"
$paths = [ "/usr/local/bin/", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ]

user {$local_user:
     ensure => present,
     shell  => "/bin/zsh",
}

define local_package () {
  package { "$name":
    ensure  => latest,
  }
}

define local_absent () {
  package { "$name":
    ensure => absent,
  }
}

local_package {
  # Text Editors
  'vim':;

  # Languages
  'python2.7':;
  'python3':;
  'ruby':;
  'ruby1.9.1':;
  'ruby1.9.1-dev':;
  'markdown':;

  # Providers
  'python-pip':;

  # Networking
  'curl':;
  'ftp':;
  'openssh-client':;
  'openssh-server':;
  'ssh':;
  'wget':;
  'whois':;

  # Version Control
  'git':;
  'rdiff-backup':;
  'rsync':;

  # Cli
  'zsh':;

  # Searching
  'grep':;
  'ack-grep':;
  'silversearcher-ag':;

  # Processes
  'htop':;

  # Misc tools
  'bash':;
  'cron':;
  'screen':;
  'tar':;
  'tmux':;
  'xclip':;
}

# Remove apt-get packages
#local_absent {
#}

## Python Pip

define python_pip () {
  package { "$name":
    ensure   => ['installed', 'latest'],
    provider => 'pip',
  }
}

# Remove python-pip packages
define remove_python_pip () {
  package { "$name":
    ensure   => absent,
    provider => 'pip',
  }
}

python_pip {
  'cronos':;
  'ipdb':;
  'ipython':;
  'urllib3':;
}

# Remove python-pip packages
#remove_python_pip {
#}

## Ruby Gems

define ruby_gems () {
  package { "$name":
    ensure   => ['installed', 'latest'],
    provider => 'gem',
  }
}

# Remove ruby gems
define remove_ruby_gems () {
  package { "$name":
    ensure   => absent,
    provider => 'gem',
  }
}

# Remove ruby gems
ruby_gems {
  'tugboat':;
}

#remove_ruby_gems {
#}

## DotFiles

file { [ "$local_home/scripts" ]:
  ensure => "directory",
  owner  => $local_user,
}

# True if dotfiles exists
exec { "check_presence_dotfiles":
  command => "/bin/true",
  onlyif  => "/usr/bin/test -e $local_home/scripts/dotfiles",
}

file { "$local_home/scripts/dotfiles":
  owner => $local_user,
  require => Exec["download_altoduo_dotfiles"]
}

exec { "download_altoduo_dotfiles":
  require => Package['git'],
  command => "git clone https://github.com/altoduo/dotfiles.git",
  onlyif  => [
    "/usr/bin/test -e $local_home/scripts",
    "bash -c '! /usr/bin/test -e $local_home/scripts/dotfiles'",
  ],
  cwd     => "$local_home/scripts/",
  creates => "$local_home/scripts/dotfiles",
  path    => $paths,
  user    => $local_user,
}

# setup_altoduo_dotfiles will only install dotfiles iff not present
exec { "setup_altoduo_dotfiles":
  require => [ Exec["check_presence_dotfiles"], Exec["download_altoduo_dotfiles"], Package['git'] ],
  onlyif  => [
    "/usr/bin/test -e $local_home/scripts/dotfiles",
    "bash -c 'if ! grep -q DOTFILES_PATH $local_home/.bashrc ; then return 0 ; else return 1; fi'",
  ],
  command => "bash -c 'source ~/.bashrc && bash scripts/setup'",
  cwd     => "$local_home/scripts/dotfiles",
  user    => $local_user,
  path    => $paths,
  logoutput => true,
}

exec { "update_altoduo_dotfiles":
  require => [ Exec["check_presence_dotfiles"], Package['git'] ],
  command => "git fetch --all && git pull origin master && git submodule sync && git submodule update --init --recursive && git submodule foreach git pull origin master",
  cwd     => "$local_home/scripts/dotfiles",
  timeout => 1800,
  user    => $local_user,
  path    => $paths,
}
