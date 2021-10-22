#include <iostream>

using namespace std;

void fact(int &value)
{
   if (value == 0)
   {
      value = 1;
   }
	else if (value > 1)
	{
		int buf = value;
		value--;
		fact(value);
		value *= buf;
	}
}

int main()
{
	cout << "Input value: ";
	int value;
	cin >> value;
	printf("Factorial of %d is ", value);
	fact(value);
	cout << value << endl;	
	system("pause");
	return 0;
}
