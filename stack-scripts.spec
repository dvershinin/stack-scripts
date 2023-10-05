Name:           stack-scripts
Version:        0
Release:        1%{?dist}
Summary:        A collection of useful Bash scripts

License:        MIT
URL:            https://github.com/dvershinin/stack-scripts
Source0:        https://github.com/dvershinin/stack-scripts/archive/%{version}.tar.gz

BuildArch:      noarch

%description
A package containing a collection of useful Bash scripts for various tasks.


%prep
%setup -q -n %{name}-%{version}


%build
# Nothing to build


%install
mkdir -p %{buildroot}%{_bindir

for script in *.sh; do
    dest_name=$(basename "$script" .sh)
    install -m 0755 "$script" "%{buildroot}%{_bindir}/$dest_name"
done


%files
%{_bindir}/*


%changelog
# no changelog
