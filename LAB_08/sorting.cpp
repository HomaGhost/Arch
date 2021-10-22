#include <iostream>

using namespace std;

struct polygon
{ // size is 16 bytes
	float numberOfSides = 0;
	float lengthOfSide = 0;
}

void swap(polygon &polygon_1, polygon &polygon_2)
{
	polygon buf = polygon_1;
	polygon_1 = polygon_2;
	polygon_2 = buf;
}

void sorting()
{
	
}

int main()
{
	
	
	char chExit;
	cin >> chExit;
	return 0;
}