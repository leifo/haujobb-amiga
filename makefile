all:
	(cd wos && $(MAKE))
	(cd examples && $(MAKE))
	
clean:
	(cd wos && $(MAKE) clean)
	(cd examples && $(MAKE) clean)
