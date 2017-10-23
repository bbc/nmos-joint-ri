PYTHON=`which python`
DESTDIR=/
PROJECT=nmos-opensource

deb:
	make deb -C nmos-query/
	make deb -C nmos-registration/
	make deb -C nmos-common/
	make deb -C reverse-proxy/
	make deb -C nmos-node/
	make deb -C mdns-bridge
clean:
	make clean -C nmos-query/
	make clean -C nmos-registration/
	make clean -C nmos-common/
	make clean -C reverse-proxy/
	make clean -C nmos-node/
	make clean -C mdns-bridge
	rm *.tar.gz *.dsc *.deb *.build *.changes
