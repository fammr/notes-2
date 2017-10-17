# include <iostream>

using namespace std;

/*
�ϲ�����(�鲢����)

2017��3��22��12:55:20

��Ļ���˼·���ǽ�����ֳɶ���A��B�������������ڵ����ݶ�������ģ�
��ô�Ϳ��Ժܷ���Ľ���������ݽ������������������������������ˣ�

���Խ�A��B������ٷֳɶ��顣�������ƣ����ֳ�����С��ֻ��һ������ʱ��
������Ϊ���С�������Ѿ��ﵽ������Ȼ���ٺϲ����ڵĶ���С��Ϳ����ˡ�
����ͨ���ȵݹ�ķֽ����У��ٺϲ����о�����˹鲢����
 
 �鲢�����Ч���ǱȽϸߵģ������г�ΪN�������зֿ���С����һ��ҪlogN����
 ÿ������һ���ϲ��������еĹ��̣�ʱ�临�Ӷȿ��Լ�ΪO(N)����һ��ΪO(N*logN)��
 ��Ϊ�鲢����ÿ�ζ��������ڵ������н��в�����
 ���Թ鲢������O(N*logN)�ļ������򷽷����������򣬹鲢����ϣ�����򣬶�����Ҳ��Ч�ʱȽϸߵġ�
 
*/ 

//���ж�����������a[first...mid]��a[mid...last]�ϲ���  
void mergearray(int a[], int first, int mid, int last, int temp[])  
{  
    int i = first, j = mid + 1;  
    int m = mid,   n = last;  
    int k = 0;  
      
    while (i <= m && j <= n)  
    {  
        if (a[i] <= a[j])  
            temp[k++] = a[i++];  
        else  
            temp[k++] = a[j++];  
    }  
      
    while (i <= m)  
        temp[k++] = a[i++];  
      
    while (j <= n)  
        temp[k++] = a[j++];  
      
    for (i = 0; i < k; i++)     //������ŵ�a������ 
        a[first + i] = temp[i];  
}  

//������ݹ�طֳ�����2��
//����:����������� first-last  ��ʱ������ݵ����� 
void mergesort(int a[], int first, int last, int temp[])  
{  
    if (first < last)  
    {  
        int mid = (first + last) / 2;  
        mergesort(a, first, mid, temp);    //�������  
        mergesort(a, mid + 1, last, temp); //�ұ�����  
        mergearray(a, first, mid, last, temp); //�ٽ������������кϲ�  
    }  
}  

//����  ����a,����n 
bool MergeSort(int a[], int n)  
{  
    int *p = new int[n];  
    if (p == NULL)  
        return false;  
    mergesort(a, 0, n - 1, p);  
    delete[] p;  
    return true;  
}  

int main(void)
{
	int a[] = {1,12,45,78,121,45,456465,45,134,53,435,12,456}; 
	MergeSort(a,13);
	for(int i=0; i<13; i++)
	{
		cout<<a[i]<<" ";
	}
    return 0;
}

