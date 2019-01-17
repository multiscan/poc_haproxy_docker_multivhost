vhosts := $(wildcard config/apps/*.cfg)
certs  := $(patsubst %.cfg,%.pem,$(vhosts))
vhostlist := $(notdir $(basename $(vhosts)))

all: docker-compose.yml haproxy/haproxy.cfg haproxy/certs.pem

up: all
	docker-compose up -d

down:
	docker-compose down

ps:
	docker-compose ps

restart:
	docker-compose down
	sleep 5
	make up

docker-compose.yml: config/docker-compose.yml.head tmp/docker-compose.yml.network_lines tmp/docker-compose.yml.networks
	sed '/^    networks:/ r tmp/docker-compose.yml.network_lines' $< | sed '/^networks:/ r tmp/docker-compose.yml.networks' > $@

tmp/docker-compose.yml.network_lines: $(vhost)
	for app in $(vhostlist) ; do echo "      - $${app}_default" ; done > $@

tmp/docker-compose.yml.networks: $(vhosts)
	for app in $(vhostlist) ; do  echo "  $${app}_default:\n    external: true" ; done > $@

haproxy/haproxy.cfg: config/haproxy_common.cfg tmp/haproxy_apps.cfg
	cat $^ > $@

tmp/haproxy_apps.cfg: $(vhosts)
	for f in $^ ; do app=$$(basename $$f .cfg); vhost=$$(head -n 1 $$f | sed 's/^[# ]*//'); echo "\nuse_backend bk_$$app if { hdr_beg(host) -i $$vhost }" ; done | sed 's/^/    /' > $@
	for f in $^ ; do echo "\n" >> $@ ; cat $$f >> $@ ; done

haproxy/certs.pem: $(certs)
	cat $^ > $@

# Note I use order only prerequisite so that pem file is generated ONLY if it does not exist and not whenever the habk file is newer
%.pem: | %.cfg
	vhost=$$(head -n 1 $| | sed 's/^[# ]*//')
	openssl req -config config/openssl_req.cfg -subj /CN=$(vhost) -new -x509 -sha256 -newkey rsa:2048 -nodes -keyout tmp/key.pem -days 365 -out tmp/cert.pem
	cat tmp/cert.pem tmp/key.pem > $@
	rm -f tmp/cert.pem tmp/key.pem

clean:
	rm -f tmp/* haproxy/certs.pem haproxy/haproxy.cfg docker-compose.yml

veryclean: clean
	rm config/apps/*.pem
