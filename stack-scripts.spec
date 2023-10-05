Name:           stack-scripts
Version:        0
Release:        1%{?dist}
Summary:        A collection of useful Bash scripts

License:        MIT
URL:            https://github.com/dvershinin/stack-scripts
Source0:        %{url}/archive/v%{version}.tar.gz

BuildArch:      noarch

%description
A package containing a collection of useful Bash scripts for various tasks.


%prep
%setup -q -n %{name}-%{version}


%build
# Nothing to build


%install
mkdir -p %{buildroot}%{_bindir}

for script in *.sh; do
    dest_name=$(basename "$script" .sh)
    install -m 0755 "$script" "%{buildroot}%{_bindir}/$dest_name"
done


%files
%{_bindir}/*


%changelog
* Thu Aug 15 2019 Danila Vershinin <info@getpagespeed.com>
- changelogs are not maintained
