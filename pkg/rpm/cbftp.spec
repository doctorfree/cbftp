Name: cbftp
Version:    %{_version}
Release:    %{_release}
BuildArch:  x86_64
Requires:   ncurses, openssl
URL:        https://github.com/doctorfree/cbftp
Vendor:     Doctorwhen's Bodacious Laboratory
Packager:   ronaldrecord@gmail.com
License     : MIT
Summary     : NCurses advanced multi-purpose FTP/FXP client

%global __os_install_post %{nil}

%description

%prep

%build

%install
cp -a %{_sourcedir}/usr %{buildroot}/usr

%pre

%post

%preun

%files
%defattr(-,root,root)
%exclude %dir /usr/share/man/man1
%exclude %dir /usr/share/man
%exclude %dir /usr/share
%exclude %dir /usr/bin
/usr/bin/*
/usr/share/*

%changelog
