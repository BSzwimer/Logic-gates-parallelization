#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

int operation(int a, int b, int opp) {
switch (opp)
{
case 0:
return a && b;
break;
case 1:
return a || b;
break;
case 2:
return !(a && b);
break;
case 3:
return !(a || b);
break;
case 4:
return a ^ b;
break;
case 5:
return !(a ^ b);
break;
}
}
int main(int argc, char* argv[])
{
char* file_name = argv[1];
char* file_solution = argv[3];
unsigned int file_length = atol(argv[2]);
//char* file_name = "C:\\Users\\bszwim\\Downloads\\input_10000.txt";
//char* file_solution = "C:\\Users\\bszwim\\Downloads\\my_solution.txt";
//unsigned int file_length = 10000;
FILE* file_answer = fopen(file_solution, "w");
FILE* file_one = fopen(file_name, "r");
if (file_one == NULL) {
perror("unable to open file");
exit(1);
}

char line[256];
int lineCounter = 0;
float memsettime;
cudaEvent_t start, stop;
//clock_t t;

//t = clock();

cudaEventCreate(&start);
cudaEventCreate(&stop);
cudaEventRecord(start, 0);
cudaEventSynchronize(start);
while (fgets(line, sizeof(line), file_one) && lineCounter < file_length) {
lineCounter++;
int a = line[0] - '0';
int b = line[2] - '0';
int opp = line[4] - '0';
int solution = operation(a, b, opp);
fprintf(file_answer, "%d\n", solution);


}
//t = clock() - t;
//double time_taken = ((double)t) / CLOCKS_PER_SEC; // in seconds 
//printf("%f seconds to execute \n", time_taken);
cudaEventRecord(stop, 0);
cudaEventSynchronize(stop);
cudaEventElapsedTime(&memsettime, start, stop);
printf(" * Sequential execution time : %f * \n", memsettime);
cudaEventDestroy(start);
cudaEventDestroy(stop);


fclose(file_answer);
fclose(file_one);
return 0;
}