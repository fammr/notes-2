# include <iostream>

using namespace std;

/*
2017��3��19��19:46:05

Ͱ����Bucket sort

1,Ͱ�������ȶ���

2,Ͱ�����ǳ�������������һ��,�ȿ��Ż�Ҫ�졭����������

3,Ͱ����ǳ���,����ͬʱҲ�ǳ��Ŀռ�,����������Ŀռ��һ�������㷨 
*/ 

int maxNumber = 95;

void bucket_sort(int a[],int n)
{
	int b[maxNumber] = {0};
	for(int i=0; i<n; i++)
	{
		b[a[i]] = a[i];
	}
	
	for(int i=0; i<maxNumber; i++)
	{
		if(b[i] > 0)
		{
			cout<<b[i]<<" ";
		} 
	}
} 

int main(void)
{
	int number[8] = {95, 45, 15, 78, 84, 51, 24, 12};
	bucket_sort(number,8);
	
	return 0;
}

