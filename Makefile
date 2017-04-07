run:
	lua gardener/main.lua
interactive:
	GTK_DEBUG=interactive lua gardener/main.lua
config:
	mkdir -p ~/.config/gardener
	touch ~/.config/gardener/conf.lua
	echo 'return {}' > ~/.config/gardener/conf.lua
install:
	luarocks install "gardener-dev-1.rockspec"
	cp -r images ~/.config/gardener
remove:
	luarocks remove gardener
	rm -r ~/.config/gardener
