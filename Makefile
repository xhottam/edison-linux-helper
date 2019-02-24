KERNEL_IMAGE=edison-linux/arch/x86/boot/bzImage

all: edison-linux/arch/x86/boot/bzImage

edison-linux/.git:
	git submodule update --init edison-linux
	./apply.sh

edison-linux/.config: edison-linux/.git edison-default-kernel.config
	cp edison-default-kernel.config edison-linux/.config

edison-linux/include/generated/utsrelease.h: edison-linux/.config
	cd edison-linux && (yes "" | make oldconfig) && make prepare

$(KERNEL_IMAGE): edison-linux/include/generated/utsrelease.h
	cd edison-linux && make

config: edison-linux/.config
	cd edison-linux && make config

xconfig: edison-linux/.config
	cd edison-linux && make xconfig

gconfig: edison-linux/.config
	cd edison-linux && make gconfig

menuconfig: edison-linux/.config
	cd edison-linux && make menuconfig

oldconfig: edison-linux/.config
	cd edison-linux && make oldconfig

prepare: edison-linux/.config
	cd edison-linux && make prepare

clean: edison-linux/.git edison-linux/.git
	cd edison-linux && make clean
	[ -e collected ] && rm -R collected || true

collected/latest: $(KERNEL_IMAGE)
	mkdir -p collected
	./collect.sh

collected: collected/latest

$(DFU)/edison-image-edison.ext4: collected/latest
	./dfu-image-install.sh "${DFU}"

$(DFU)/edison-image-edison.hddimg: collected/latest
	./dfu-image-install.sh "${DFU}"

install: $(DFU)/edison-image-edison.ext4 $(DFU)/edison-image-edison.hddimg

flashall: install
	cd "${DFU}" && ./flashall.sh

.PHONY: all
