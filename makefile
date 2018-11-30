all:
	(cd wos && $(MAKE))
	(cd demo && $(MAKE))
	
clean:
	(cd wos && $(MAKE) clean)
	(cd demo && $(MAKE) clean)
