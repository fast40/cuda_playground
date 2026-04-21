#include <cstdio>
#include <memory>

__global__ void trivial() {}

__global__ void my_kernel_1(int *output) {
  int y = 0;

  if (threadIdx.x % 16 == 0) {
    for (int i = 0; i < 100000; i++) {
      y = y * threadIdx.x + i + 2;
    }
  } else {
    for (int i = 0; i < 100000; i++) {
      y = y * threadIdx.x + i + 3;
    }
  }

  output[threadIdx.x] = y;
}

__global__ void my_kernel_2(int *output) {
  int y = 0;

  for (int i = 0; i < 100000; i++) {
    if (threadIdx.x % 16 == 0) {
      y = y + threadIdx.x * i * 2;
    } else {
      y = y + threadIdx.x * i * 3;
    }
  }

  output[threadIdx.x] = y;
}

struct Result {
  float ms;
  int output[1024];
};

std::unique_ptr<Result> timeit(void (*kernel)(int *)) {
  auto result = std::make_unique<Result>();
  int *device_output;
  cudaMalloc(&device_output, 1024 * sizeof(int));

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaEventRecord(start);
  kernel<<<1, 1024>>>(device_output);
  cudaEventRecord(stop);

  cudaEventSynchronize(stop);

  cudaEventElapsedTime(&result->ms, start, stop);

  cudaEventDestroy(start);
  cudaEventDestroy(stop);

  cudaMemcpy(result->output, device_output, 1024 * sizeof(int),
             cudaMemcpyDeviceToHost);

  return result;
}

int main() {
  trivial<<<1, 1>>>();

  std::unique_ptr<Result> result_1;
  std::unique_ptr<Result> result_2;

  for (int i = 0; i < 10; i++) {
    result_1 = timeit(my_kernel_1);
    result_2 = timeit(my_kernel_2);

    printf("my_kernel_1: %fms\n", result_1->ms);
    printf("my_kernel_2: %fms\n", result_2->ms);
    printf("my_kernel_1/my_kernel_2 = %f\n", result_1->ms / result_2->ms);
  }

  return 0;
}
