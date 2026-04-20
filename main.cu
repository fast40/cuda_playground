__global__ void my_kernel() {
    int y = 10;
    int x;

    if (threadIdx.x % 31 == 1) {
        x = 2 * y;
    } else {
        x = 3 * y;
    }
}

int main() {
    my_kernel<<<1, 1024>>>();
    return 0;
}
