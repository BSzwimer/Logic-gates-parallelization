#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <string.h>
#include <ctype.h>
#define LENGTH 7
#define MAXSIZE 1000000

__global__ void operation(int* file_cuda, int* file_output_cuda, int arrSize) {
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int new_index = index * 3;
	//printf(" index: %d", index);
	if (index < (arrSize / 3)) {
		int a = file_cuda[new_index];
		int b = file_cuda[new_index + 1];
		int opp = file_cuda[new_index + 2];
		switch (opp)
		{
		case 0:
			file_output_cuda[index] = a && b;
			break;
		case 1:
			file_output_cuda[index] = a || b;
			break;
		case 2:
			file_output_cuda[index] = !(a && b);
			//return !(a && b);
			break;
		case 3:
			file_output_cuda[index] = !(a || b);
			//return !(a || b);
			break;
		case 4:
			file_output_cuda[index] = a ^ b;
			//return a ^ b;
			break;
		case 5:
			file_output_cuda[index] = !(a ^ b);
			//return !(a ^ b);
			break;
		}

	}
}
int main(int argc, char* argv[])
{
	float memsettime;
	cudaEvent_t start, stop;
	char* file_name = argv[1];
	char* file_solution = argv[3];
	unsigned int file_length = atol(argv[2]);
	//char* file_name = "C:\\Users\\bszwim\\Downloads\\input_100000.txt";;
	//unsigned int file_length = 100000;
	//char* file_solution = "C:\\Users\\bszwim\\Downloads\\my_solution.txt";;
	FILE* file_answer = fopen(file_solution, "w");
	FILE* file_one = fopen(file_name, "r");
	if (file_one == NULL) {
		perror("unable to open file");
		exit(1);
	}

	int lines = 0;
	while (!feof(file_one))
	{
		char ch = fgetc(file_one);
		if (ch == '\n')
		{
			++lines;
		}
	}
	rewind(file_one);
	if (file_length < lines) {
		lines = file_length;
	}
	int* arr;
	arr = (int*)malloc((lines * 3) * sizeof(int));
	int counter = 0;
	int lineCounter = 0;
	while (!feof(file_one) && lineCounter < file_length) {
		char c = fgetc(file_one);
		if (c == '\n') {
			lineCounter++;
		}
		if (isdigit(c)) {
			int x = c - '0';
			arr[counter] = x;
			counter++;
		}
	}
	//arr[counter] = '\0';
	//printf("size of arr: %d \n", strlen(arr));
	//printf("%s", arr);
	int* file_cuda;
	int* file_output_cuda;
	cudaMalloc((void**)&file_cuda, (lines * 3) * sizeof(int));
	cudaMalloc((void**)&file_output_cuda, lines * sizeof(int));
	cudaMemcpy(file_cuda, arr, (lines * 3) * sizeof(int), cudaMemcpyHostToDevice);
	int* arr_output;
	arr_output = (int*)malloc(lines * sizeof(int));
	//int num_of_blocks = (lines / 1024) + 1;
	unsigned int num_of_blocks = (lines + 1024 - 1) / 1024;


	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	cudaEventSynchronize(start);
	operation << < num_of_blocks, 1024 >> > (file_cuda, file_output_cuda, counter);


	
	cudaMemcpy(arr_output, file_output_cuda, lines * sizeof(int), cudaMemcpyDeviceToHost);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&memsettime, start, stop);
	printf(" * CUDA execution time and data migration for explicit: %f * \n", memsettime);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	for (int j = 0; j < lines; j++) {
		fprintf(file_answer, "%d\n", arr_output[j]);
	}


	cudaFree(file_cuda);
	cudaFree(file_output_cuda);
	free(arr_output);
	free(arr);


	fclose(file_answer);
	fclose(file_one);
	return 0;
}