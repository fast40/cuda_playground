#include <cstdio>

__global__ void my_kernel_1() {
    __shared__ int array[1024]; // this goes in a single SM, which a single block goes on.

    int &slot = array[threadIdx.x];

    int y = 10;

    if (threadIdx.x % 31 == 1) {
        slot = 2 * y;
    } else {
        slot = 3 * y;
    }
}

__global__ void my_kernel_2() {
    __shared__ int array[1024]; // this goes in a single SM, which a single block goes on.

    int &slot = array[threadIdx.x];

    int y = 10;

    if (threadIdx.x % 31 == 1) {
        slot = 2 * y;
    } else {
        slot = 3 * y;
    }
}


int main() {
    cudaEvent_t start;
    cudaEvent_t stop;

    float ms;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // === KERNEL 1 ===

    cudaEventRecord(start); // put an event into the default stream
    my_kernel_1<<<16, 1024>>>(); // put this kernel into the default stream
    cudaEventRecord(stop); // put another event into the default stream

    cudaEventSynchronize(stop); // wait until the stop event has passed

    cudaEventElapsedTime(&ms, start, stop);
    printf("kernel completed in %fms.\n", ms);

    // === KERNEL 2 ===

    cudaEventRecord(start);
    my_kernel_2<<<16, 1024>>>();
    cudaEventRecord(stop);

    cudaEventSynchronize(stop); // wait until the stop event has passed

    cudaEventElapsedTime(&ms, start, stop);
    printf("kernel completed in %fms.\n", ms);
    
    // === DESTROY THE EVENTS??? WTF EVEN DOES THIS MEAN? ===

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
