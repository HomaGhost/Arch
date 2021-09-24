// robot.cpp: определяет точку входа для консольного приложения.
//

#include "stdafx.h"
#include <iostream>
#include <windows.h>
//#include "Header.h"

using namespace std;

size_t n = 10;
int** map = new int*[n];
int markercount = 0;
int input, x = 0, y = 0;
int value = 0;

void setmap() {
	map[4][0] = 2;
	map[5][0] = 2;
	map[1][1] = 2;
	map[8][1] = 2;
	map[3][2] = 2;
	map[6][2] = 2;
	map[2][3] = 2;
	map[7][3] = 2;
	map[0][4] = 2;
    map[4][4] = 2;
	map[5][4] = 2;
	map[9][4] = 2;
	map[0][5] = 2;
	map[4][5] = 2;
	map[5][5] = 2;
	map[9][5] = 2;
	map[2][6] = 2;
	map[7][6] = 2;
	map[3][7] = 2;
	map[6][7] = 2;
	map[1][8] = 2;
	map[8][8] = 2;
	map[4][9] = 2;
	map[5][9] = 2;


	//marks
	map[2][1] = 1;
	map[2][2] = 1;
	map[1][2] = 1;
	map[1][7] = 1;
	map[2][7] = 1;
	map[2][8] = 1;
	map[7][1] = 1;
	map[7][2] = 1;
	map[8][2] = 1;
	map[7][7] = 1;
	map[8][7] = 1;
	map[7][8] = 1;

	map[0][0] = 3;
}

void print(int direction)
{
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 10; j++ )
		{
			if (map[i][j] == 0)
				cout << " ";
			else if (map[i][j] == 1)
				cout<< "*";
			else if (map[i][j] == 2)
				cout << "#";
			else if ((map[i][j] == 3) && (direction ==11)) cout  <<"^";
			else if ((map[i][j] == 3) && (direction == 12)) cout << ">";
			else if ((map[i][j] == 3) && (direction == 13)) cout << "v";
			else if ((map[i][j] == 3) && (direction == 14)) cout << "<";
			cout << " ";
		}
		cout << endl;
	}

}



int main()
{
	setlocale(LC_ALL, ".1251");
	for (int i=0; i<10; i++) 
	{
		for (int j = 0; j < 10; j++)
		{
			map[i][j] = 0;
		}
	}

	setmap();
	int direction = 13;
	do
	{
		system("cls");

		print(direction);
		cout << "Управление";
			cout << markercount << " marker count" << endl;
		cin >> input;
		switch (input)
		{
		case 6:
			if (direction < 14)
			{
				direction = direction + 1;

			}
			else
			{
				direction = 11;
			}
			break;
		case 4:
			if (direction > 11)
			{
				direction = direction - 1;

			}
			else
			{
				direction = 14;
			}
			break;
		case 8:
			if (direction == 13)
			{
				if (y < 9 && map[y + 1][x] != 2)
				{
					map[y][x] = value;
					value = map[y + 1][x];
					y = y + 1;
					map[y][x] = 3;
				}

			}

			if (direction == 11)
			{
				if (y > 0 && map[y - 1][x] != 2)
				{
					map[y][x] = value;
					value = map[y - 1][x];
					y = y - 1;
					map[y][x] = 3;
				}

			}

			if (direction == 12)
			{
				if (x < 9 && map[y][x+1] != 2)
				{
					map[y][x] = value;
					value = map[y][x+1];
					x = x + 1;
					map[y][x] = 3;
				}

			}

			if (direction == 14)
			{
				if (x>0 && map[y][x-1] != 2)
				{
					map[y][x] = value;
					value = map[y][x-1];
					x = x-1;
					map[y][x] = 3;
				}

			}
			break;
		
		case 7:
			if (value == 1)
			{
				markercount += 1;
				value = 0;
			}
			break;

		case 9:
			if(value == 0&&markercount>0)
			{
				markercount -= 1;
					value = 1;
			}
			break;
		default:
			break;

		}
	}
	while
		((map[3][3] != 1) || (map[3][4] != 1) || (map[3][5] != 1) || (map[3][6] != 1) || (map[6][3] != 1) || (map[6][4] != 1) || (map[6][5] != 1) || (map[6][6] != 1) || (map[4][3] != 1) || (map[5][3] != 1) || (map[4][6] != 1) || (map[5][6] != 1));

	cout << endl << "Пройдено!" << endl;
    return 0;
}

