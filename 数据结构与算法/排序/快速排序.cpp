# include <iostream>

using namespace std;

/*
2017��3��22��08:58:20

�������� 
 ���ȶ�����
 ��������Quicksort���� O(nlogn) ����ʱ��,
  O(n2) ����; ���ڴ�ġ���������һ��������������֪����.
  
  ���ŵ�˼��

���µ����������������ŵ����̣�

1.�����������ȡһ��ֵ��Ϊ���
2.�Ա�����ҵ�������л���(���ȱ����������ڱ�������棬
�ȱ��С�������ڱ�������棬�������ͷ�����)
3.�ظ������������̣�ֱ��ѡȡ�����еı��������(��ʱÿ�����������������ֻ��һ��ֵ��
������)
*/ 

//���������һ��ѭ��
//�㷨����һ����������С�ķŵ�������ǰ�棬������ķŵ������ĺ���   
//����Ļ�׼�����ͳ��ѡ��,ֱ�ӽ���һ����Ϊ��׼��
int Partition(int a[],int low,int high)
{
	int pivotkey = a[low];  //��׼��
	 while(low<high)
	 {
	 	while(low<high && a[high]>=pivotkey)
	 	{
	 		high--;
		 }
		 a[low] = a[high];  //��������Ȼ�׼��С��,����ŵ�a[low]λ�� 
		 while(low<high && a[low]<=pivotkey)
		 {
		 	low++;
		 }
		 a[high] = a[low];  //��������Ȼ�׼�����,����ŵ�a[high]λ�� 
	 } 
	 a[low] =  pivotkey;   //����׼���ŵ��÷ŵ�λ�� 
	 return low;   //������һ���Ѿ��ź�λ���˵Ļ�׼����λ�� 
} 

//�����������
void Sort(int a[],int low,int high)
{
	if(low<high)
	{
		int pivotloc = Partition(a,low,high);    //��׼����λ�� 
		Sort(a,low,pivotloc-1);   //���η� 
		Sort(a,pivotloc+1,high);
	}
} 

int main(void)
{
	int a[] = {4,45,12,6,45,78,124,52,15,45,12};
	
	Sort(a,0,10);
	
	//�������
	for(int i=0; i<11; i++)
	{
		cout<<a[i]<<" ";
	}

	cout<<endl<<" ";
   return 0;
}

