

node default {


    # enforce creation of repos using puppet modules
    # https://forge.puppetlabs.com/yguenane/repoforge
    include repoforge
    # https://forge.puppetlabs.com/stahnma/epel
    include epel



    # just for convenience
    package {'screen':
        ensure => 'installed',
    }





    # FLASK

    package {'python-pip':
        ensure => 'installed',
    } ->
    # there is a bug in Puppet, it looks for pip-python instead of pip on rhel systems
    # http://grokbase.com/t/gg/puppet-users/151an5y239/puppet-installing-package-via-pip
    exec{'link_pip':
        command   => 'bash -c "if [ ! -f /usr/bin/pip-python ]; then ln -s /usr/bin/pip /usr/bin/pip-python; fi"',
        path      => [ "/usr/local/bin/", "/bin/" ],
        logoutput => true,
    } ->
    package {'flask':
        ensure   => 'installed',
        provider => 'pip',
        require  => Package['python-pip'],
    }

    # copy dir containing the application
    file {'/usr/share/nginx/website':
        source  => 'puppet:///modules/nginx-uwsgi-flask/website',
        recurse => true,
    }




    # UWSGI

    # an rpm is used rather than pip installation for 2 reasons:
    # systemd service is provided out of the box
    # no need to install devel packages such as gcc, python-devel

    package {'uwsgi':
        ensure          => 'installed',
        provider        => 'yum',
        # this fails in puppet versions <= 3.6.2, fixed in 3.7.0
        install_options => '--enablerepo=epel-testing',
    } ->
    package {'uwsgi-plugin-python':
        ensure          => 'installed',
        provider        => 'yum',
        # this fails in puppet versions <= 3.6.2, fixed in 3.7.0
        install_options => '--enablerepo=epel-testing',
    } ->
    file {'uwsgi.ini':
        path   => '/etc/uwsgi.ini',
        mode   => '0600',
        source => 'puppet:///modules/nginx-uwsgi-flask/uwsgi.ini',
    } ~>
    service {'uwsgi':
        enable => true,
        ensure => running,
    }



    # NGINX

    file {'nginx.repo':
        path   => '/etc/yum.repos.d/nginx.repo',
        mode   => '0600',
        source => 'puppet:///modules/nginx-uwsgi-flask/nginx.repo',
    } ->
    package {'nginx':
        ensure => 'installed',
    } ->
    file {'default.conf':
        path   => '/etc/nginx/conf.d/default.conf',
        ensure => 'absent',
    } ->
    file {'website.conf':
        path   => '/etc/nginx/conf.d/website.conf',
        mode   => '0600',
        source => 'puppet:///modules/nginx-uwsgi-flask/website.conf',
    } ~>
    service {'nginx':
        enable => true,
        ensure => running,
    }





    # Dynamic DNS

    package {'ddclient':
        ensure => 'installed',
    }

    file {'ddclient.conf':
        path   => '/etc/ddclient/ddclient.conf',
        mode   => '0600',
        source => 'puppet:///modules/nginx-uwsgi-flask/ddclient.conf',
    } ~>
    service {'ddclient':
        enable => true,
        ensure => running,
    }



}

