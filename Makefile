define gitpush
    git add .
    git commit -a -m "$1"
    git push
endef

.PHONY: default
default:
	markhtml . ../note/

push: default
	$(call gitpush,update)
	cd ../note 
	$(call gitpush,update)
	cd ../note-md


