# Define the phony targets
.PHONY: all code spanish

# The default target
all: code spanish

code:
	ollama create code -f ./Modelfile.code

spanish:
	ollama create spanish -f ./Modelfile.spanish
