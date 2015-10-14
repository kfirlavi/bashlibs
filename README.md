# After cloning
To setup repository you should run:
`$ cd bashlibs.git`
`$ bin/setup`

# Generate bashlibs repository
`$ bin/bake-all --server a --server b -s c -s d ...`

hosts are a debian/ubuntu or a gentoo

for each host it will generate all packages.

For example:
you have 3 hosts: ubuntu32 ubuntu64 and gentoo

`$ bin/bake-all -s ubuntu32 -s ubuntu64 -s gentoo`

will generate deb repository for i386 and amd64, 
then will create a gentoo repository and source packages.

## Commands to start over at the servers
* delete all bashlibs packages on ubuntu
```
dpkg --configure -a; apt-get purge $(dpkg -l | grep bashlibs | awk '{print $2}') -y ; apt-get autoremove -y
```
* delete all bashlibs packages from gentoo
```
emerge -q -C $(eix --only-names bashlibs)
```
