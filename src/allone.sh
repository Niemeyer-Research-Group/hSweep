nvcc solmain.cu utilities/jsoncpp.cpp -o ./bin/eulerCF -gencode arch=compute_35,code=sm_35 -O3 -restrict -std=c++11 -I/usr/include/mpi -I./utilities -I./equations -I./decomposition -lmpi -Xcompiler -fopenmp -lm -w --ptxas-options=-v
