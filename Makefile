define gitpush
    git add . && git commit -a -m "$1" && git push
endef

.PHONY: default
default:
	# 只有在markhtml.conf中列出的文件才会被转换
	markhtml . ../note/ markhtml.conf

push: default
	$(call gitpush,update)
	cd ../note && $(call gitpush,update) 


