up: proxyconf
	docker-compose -f app1/docker-compose.yml  up -d
	docker-compose -f app2/docker-compose.yml  up -d
	cd ../ && make up

down:
	cd ../ && make down
	docker-compose -f app1/docker-compose.yml  down
	docker-compose -f app2/docker-compose.yml  down

ps:
	docker-compose -f app1/docker-compose.yml  ps
	docker-compose -f app2/docker-compose.yml  ps
	cd ../ && make ps

config: ../config/apps/app1.cfg ../config/apps/app2.cfg 
	cd ../ && make all

../config/apps/%.cfg: apps_config/%.cfg
	cp $< $@

clean:
	cd ../ && make clean
	rm -f ../config/apps/app1.cfg ../config/apps/app2.cfg