#!/bin/sh

bond=false
phone=false

while [ "$1" != "" ]; do
    case $1 in
        -b | --bond )
            bond=true;;
        -p | --phone )
            phone=true;;
        -i4 | --ip4 )
            ip4=$2
            shift;;
        -i6 | --ip6 )
            ip6=$2
            shift;;
        -g | --gateway )
            gw=$2
            shift;;
        --)
            break;;
        *)
            printf "Unknown Option %s\n" "$1"
            exit 1
    esac
    shift
done

if $bond ; then # Create bond0

    ip link set eth1 down
    ip link set eth2 down

    ip link add bond0 type bond mode 802.3ad

    ip link set eth1 master bond0
    ip link set eth2 master bond0

    # Set final 16bits of Bridge MAC to last 2 characters of hostname (i.e. HostA1 = a1, HostB1 = b1, HostC1 = c1)
    ip link set dev bond0 address c0:d6:82:00:00:$(hostname -s | tail -c 3)

    ip link set bond0 up

    ip addr add $ip4 dev bond0
    ip route add 10.0.0.0/8 via $gw dev bond0
    ip route add 224.0.0.0/4 via $gw dev bond0
    ip -6 addr add $ip6 dev bond0

elif $phone ; then

    # Create br0
    ip link add name br0 type bridge

    # Set final 16bits of Bridge MAC to last 2 characters of hostname (i.e. Phone1 = e1, PhoneA = ea, Phone10 = 10)
    ip link set br0 address 30:86:2d:00:00:$(hostname -s | tail -c 3)

    # Disable STP, provide add'l visibility
    ip link set br0 type bridge stp_state 0
    ip link set br0 type bridge vlan_stats_per_port 1

    # Bring up Bridge Interface and add eth1 & eth2 (Note: eths must be UP to add)
    ip link set dev br0 up
    ip link set eth1 master br0
    ip link set eth2 master br0

    # Add Simple Multicast Support
    #sysctl net.ipv4.conf.br0.mc_forwarding=1
    #sysctl net.ipv6.conf.br0.mc_forwarding=1
    ip link set br0 type bridge mcast_stats_enabled 1

    # Configure L3
    ip addr add $ip4 dev br0
    ip route add 10.0.0.0/8 via $gw dev br0
    ip route add 224.0.0.0/4 via $gw dev br0
    ip -6 addr add $ip6 dev br0

    # Customize LLDP
    # lldpcli configure ports eth1,eth2,br0 lldp status rx-only

else

    # Set final 16bits of Bridge MAC to last 2 characters of hostname (i.e. HostA1 = a1, HostB1 = b1, HostC1 = c1)
    ip link set dev eth1 address 94:8e:d3:00:00:$(hostname -s | tail -c 3)
    ip addr add $ip4 dev eth1
    ip route add 10.0.0.0/8 via $gw dev eth1
    ip route add 224.0.0.0/4 via $gw dev eth1
    ip -6 addr add $ip6 dev eth1
fi
