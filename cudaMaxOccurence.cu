#include<stdio.h>
#include<cuda.h>
__global__ void convertToCaps(char *str,int length){
    int index = threadIdx.x+blockIdx.x*blockDim.x;
    if(index<length){
        if(str[index]>=97&&str[index]<=122)
            str[index]-=32;
    }
}
__global__ void findMaxOccurence(char *str,int *count,int length){
    int index = threadIdx.x+blockIdx.x*blockDim.x;
    if(index<length){
        atomicAdd(&count[(int)str[index]-65],1);
    }
}
int countMax(int *count){
    int max=0;
    for(int i=1;i<26;i++){
        if(count[i]>count[max]){
            max=i;
        }
    }
    return max;
}
int main(){
    char *str;
    int n;
    char dummy;
    printf("\nEnter length of string:");
    scanf("%d",&n);
    scanf("%c",&dummy);
    str = (char*)malloc(n*sizeof(char));
    printf("\nEnter the String:");
    scanf("%[^\n]s",str);
    int noOfBlocks = n/1024;
    int noOfThreads;
    noOfBlocks++;
    if(noOfBlocks==1){
        noOfThreads=n;
    }
    else{
        noOfThreads=1024;
    }
    char *dev_str=NULL;int *count;
    cudaMallocManaged((void**)&dev_str,n*sizeof(char));
    cudaMallocManaged((void**)&count,26*sizeof(int));
    for(int i=0;i<26;i++){
        count[i]=0;
    }
    strcpy(dev_str,str);
    convertToCaps<<<noOfBlocks,noOfThreads>>>(dev_str,n);
    cudaDeviceSynchronize();
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    findMaxOccurence<<<noOfBlocks,noOfThreads>>>(dev_str,count,n);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    //printf("\n%s",dev_str);
    int max = countMax(count);
    printf("\nMaximum count = %d",count[max]);
    printf("\nExecution Time = %f ms",milliseconds);
    //printf("%s",str);
    //printf("\n%d",findLen(str));
    return 0;
}