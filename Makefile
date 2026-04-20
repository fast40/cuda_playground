
main: main.cu
	nvcc -std=c++20 -o $@ $^
