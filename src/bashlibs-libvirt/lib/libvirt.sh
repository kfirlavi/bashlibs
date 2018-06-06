fqdn_to_mac() {
    local domain=$1

    echo $domain \
        | md5sum \
        | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/54:\1:\2:\3:\4:\5/'
}
