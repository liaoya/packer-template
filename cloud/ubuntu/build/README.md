# Build OVS on Ubuntu

- **Open vSwitch** 2.7.2 can be built on Ubuntu 16.04 if datapath-module is required (for performance purpose).
- Only **Open vSwitch** 2.8.x can be built on Ubuntu 17.04 if datapath-module is required (for performance purpose).
- **vagrant-proxyconf** must be installed for setup apt proxy correctly, run `vagrant plugin install vagrant-proxyconf`

Run `vagrant up && vagrant destroy -f`, it will build all the software.

