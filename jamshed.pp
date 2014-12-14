$local_user = "jamshed"
$local_home = "/home/$local_user"
$paths = [ "/usr/local/bin/", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ]

user {'jamshed':
     ensure => present,
     shell  => "/bin/bash",
}

exec {'apt-install':
  command => '/usr/bin/apt-get install',
}

exec { "apt-update":
    command => "/usr/bin/apt-get update",
}

define local_package () {
  package { "$name":
    ensure  => present,
    require => Exec['apt-update'],
  }
}

define local_absent () {
  package { "$name":
    ensure => absent,
  }
}

local_package {
  ## Text Editors
  'vim':;

  ## Languages
  'python2.7':;
  'python3':;
  'ruby':;
  'ruby1.9.1':;
  'ruby1.9.1-dev':;

  ## Providers
  'python-pip':;

  ## Networking
  'curl':;
  'ftp':;
  'openssh-client':;
  'openssh-server':;
  'ssh':;
  'wget':;
  'whois':;

  ## Version Control
  'git':;
  'rdiff-backup':;
  'rsync':;

  ## Misc tools
  'ack-grep':;
  'bash':;
  'cron':;
  'screen':;
  'tar':;
  'tmux':;
  'xclip':;

  ## Searching
  'grep':;
  'silversearcher-ag':;

  ## Passwords and Access
  #'keepassx':;
  #'keychain':;

  ## Virtual
  #'virtualbox':;
  #'vagrant':;

  ## Music
  #'spotify-client':
    #require => Apt_line['spotify'];

  ## File Syncing
  #'dropbox':
    #require => [
      #Apt_line['dropbox'],
      #Package['python-gpgme'],
      #Package['libappindicator1']
    #];
}

#local_absent {
#}


### Ruby Gems

define ruby_gems () {
  package { "$name":
    ensure   => ['installed', 'latest'],
    provider => 'gem',
  }
}

define remove_ruby_gems () {
  package { "$name":
    ensure   => absent,
    provider => 'gem',
  }
}

ruby_gems {
  'tugboat':;
}

#remove_ruby_gems {
#}

### DotFiles

file { [ "$local_home/scripts" ]:
  ensure => "directory",
  owner  => $local_user,
}

exec { "check_presence_dotfiles":
  command => "/bin/true",
  onlyif  => "/usr/bin/test -e /home/$local_user/dotfiles",
}

exec { "download_altoduo_dotfiles":
  require => Package['git'],
  command => "git clone https://github.com/altoduo/dotfiles.git",
  cwd     => "$local_home/scripts/",
  creates => "$local_home/scripts/dotfiles",
  path    => $paths,
}

#exec { "setup_altoduo_dotfiles":
  #require => [ Exec["check_presence_dotfiles"], Package['git'] ],
  #command => "bash scripts/setup",
  #cwd     => "$local_home/scripts/dotfiles",
  #user    => $local_user,
  #path    => $paths,
#}

exec { "update_altoduo_dotfiles":
  require => [ Exec["check_presence_dotfiles"], Package['git'] ],
  command => "git pull origin master && git submodule sync && git submodule update --init --recursive && git submodule foreach git pull origin master",
  cwd     => "$local_home/scripts/dotfiles",
  user    => $local_user,
  path    => $paths,
}
