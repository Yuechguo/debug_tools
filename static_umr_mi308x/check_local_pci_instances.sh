dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export UMR_DATABASE_PATH=${dir}/database
./umr --script instances
#./umr --script pci-bus 0
#./umr --script pci-bus 17