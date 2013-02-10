CC=g++
CFLAGS=-I.
OBJ = lib/Dog.o lib/trainer.o

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

trainer: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)