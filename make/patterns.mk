%.o: %.asm
	@echo "NASM $@"
	$(NASM) $(NASMFLAGS) $< -o $@

%.o: %.c
	@echo "CC $@"
	$(CC) $(CFLAGS) -c $< -o $@

%.app: %.o
	@echo "LINK $@"
	$(LD) $(LDFLAGS) $^ -o $@ $(LDLIBS)
