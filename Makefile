# Variables
PROLOG = swipl
MAIN = src/main.pl
TARGET = morpalia

# Default target
.PHONY: all
all: run

# Run the game
.PHONY: run
run:
	$(PROLOG) -s $(MAIN) -g "board."

# Start REPL with game loaded
.PHONY: repl
repl:
	$(PROLOG) -s $(MAIN)

# Clean any temporary files
.PHONY: clean
clean:
	rm -f *~
	rm -f *.out
	rm -f *.dump

# Help target
.PHONY: help
help:
	@echo "Morpalia Makefile commands:"
	@echo "  make run   - Start the game"
	@echo "  make repl  - Start Prolog REPL with game loaded"
	@echo "  make clean - Clean temporary files"
	@echo "  make help  - Show this help message"
