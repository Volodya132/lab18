#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <stdio.h>

using namespace std;


__global__ void DijkstraAlgo(int* graph, int src, int* res, bool* Tset, int size)
{

	for (int k = 0; k < size; k++)
	{
		
		int minimum = INT_MAX, ind;

		for (int m = 0; m < size; m++)
		{
			if (Tset[m] == false && res[m] <= minimum)
			{
				minimum = res[m];
				ind = m;
			}
		}
		int m = ind;
		Tset[m] = true;
		for (int j = 0; j < size; j++)
		{

			if (!Tset[j] && graph[m* size +j] && res[m] != INT_MAX && res[m] + graph[m* size +j] < res[j])
				res[j] = res[m] + graph[m* size +j];
		}
	}

}

int main()
{
	const int src = 0;
	const int size = 6;
	const int memSize = sizeof(int) * size * size;
	int graph[size][size] = {
		{0, 1, 2, 0, 0, 0},
		{1, 0, 0, 5, 1, 0},
		{2, 0, 0, 2, 3, 0},
		{0, 5, 2, 0, 2, 2},
		{0, 1, 3, 2, 0, 1},
		{0, 0, 0, 2, 1, 0} };

	int distance[size];
	bool Tset[size];
	for (int i= 0; i < size; i++) {
		distance[i] = INT_MAX;
		Tset[i] = false;
	}
	distance[src] = 0;

	int* gpu_graph, * gpu_distance;
	bool *gpuTset;
	cudaMalloc((void**)&gpu_graph, memSize);
	cudaMalloc((void**)&gpu_distance, sizeof(int)* size);
	cudaMalloc((void**)&gpuTset, sizeof(int) * size);

	cudaMemcpy(gpu_graph, graph, memSize, cudaMemcpyKind::cudaMemcpyHostToDevice);
	cudaMemcpy(gpu_distance, distance, sizeof(int)*size, cudaMemcpyKind::cudaMemcpyHostToDevice);
	cudaMemcpy(gpuTset, Tset, sizeof(int) * size, cudaMemcpyKind::cudaMemcpyHostToDevice);

	DijkstraAlgo << <1, 1 >> > (gpu_graph, 0, gpu_distance, gpuTset, size);
	cout << "Vertex\t\tDistance from source vertex" << endl;

	cudaMemcpy(distance, gpu_distance, sizeof(int)*size, cudaMemcpyKind::cudaMemcpyDeviceToHost);
	for (int k = 0; k < size; k++)
	{
		char str = 65 + k;
		cout << str << "\t\t\t" << distance[k] << endl;
	}
	return 0;
}
