#include <iostream>
using namespace std;

size_t n = 10;
int** map = new int* [n];
int marker_count = 0;		//Кол-во собранных маркеров
int input, x = 0, y = 0;	//x, y - корды робота
int value = 0;				//Значение ячейки, в которую стал робот, чтобы после его движения вернуть ей её значение

void setMap() {
	//Размечаем поле:

//Препятствия
	map[0][6] = 2;
	map[1][2] = 2;
	map[1][5] = 2;
	map[1][7] = 2;
	map[2][1] = 2;
	map[2][2] = 2;
	map[2][4] = 2;
	map[2][7] = 2;
	map[2][8] = 2;
	map[3][0] = 2;
	map[3][5] = 2;
	map[4][1] = 2;
	map[4][3] = 2;
	map[4][7] = 2;
	map[5][2] = 2;
	map[5][6] = 2;
	map[5][8] = 2;
	map[6][4] = 2;
	map[6][9] = 2;
	map[7][1] = 2;
	map[7][2] = 2;
	map[7][5] = 2;
	map[7][7] = 2;
	map[7][8] = 2;
	map[8][2] = 2;
	map[8][4] = 2;
	map[8][7] = 2;
	map[9][3] = 2;

	//Маркеры
	map[1][6] = 1;
	map[2][5] = 1;
	map[2][6] = 1;
	map[3][1] = 1;
	map[3][2] = 1;
	map[4][2] = 1;
	map[5][7] = 1;
	map[6][7] = 1;
	map[6][8] = 1;
	map[7][3] = 1;
	map[7][4] = 1;
	map[8][3] = 1;

	//Начальная точка робота [0][0]

	map[0][0] = 3;
}

void print(int direction) {
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			if (map[i][j] == 0) cout << " ";
			else if (map[i][j] == 1) cout << "*";
			else if (map[i][j] == 2) cout << "#";
			else if ((map[i][j] == 3) && (direction == 11)) cout << "^";
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
	//Создаем поле (двумерный массив из клеточек)
	for (int i = 0; i < n; i++) {
		map[i] = new int[n];
	}

	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			map[i][j] = 0;
		}
	}

	setMap();
	
	int direction = 13; //Направление: 11 - верх, 12 - право, 13 - низ, 14 - лево
	do
	{
		system("cls");	//Очищает консоль

		print(direction);

		cout << "Команды для управления роботом: вправо(6), влево(4), вперед(8), поднять маркер(7), положить маркер(9)" << endl;
		cout << marker_count << " - кол-во собранных маркеров" << endl;
		cin >> input;
		switch (input)
		{
		case 6:	//Поворот вправо
			if (direction < 14)
			{
				direction = direction + 1;
			}
			else
			{
				direction = 11;
			}
			break;
		case 4:	//Поворот влево
			if (direction > 11)
			{
				direction = direction - 1;
			}
			else
			{
				direction = 14;
			}
			break;
		case 8:	//Шаг вперед
			if (direction == 13)	//Движение вниз
			{
				if (y < 9 && map[y + 1][x] != 2)
				{
					map[y][x] = value;
					value = map[y + 1][x];
					y = y + 1;
					map[y][x] = 3;
				}
			}
			if (direction == 11)	//Движение вверх
			{
				if (y > 0 && map[y - 1][x] != 2)
				{
					map[y][x] = value;
					value = map[y - 1][x];
					y = y - 1;
					map[y][x] = 3;
				}
			}
			if (direction == 12)	//Движение вправо
			{
				if (x < 9 && map[y][x + 1] != 2)
				{
					map[y][x] = value;
					value = map[y][x + 1];
					x = x + 1;
					map[y][x] = 3;
				}
			}
			if (direction == 14)	//Движение влево
			{
				if (x > 0 && map[y][x - 1] != 2)
				{
					map[y][x] = value;
					value = map[y][x - 1];
					x = x - 1;
					map[y][x] = 3;
				}
			}
			break;
		case 7:	//Поднять маркер
			if (value == 1)
			{
				marker_count += 1;
				value = 0;
			}
			break;
		case 9:	//Положить маркер
			if (value == 0 && marker_count > 0)
			{
				marker_count -= 1;
				value = 1;
			}
			break;
		default:
			break;
		}
	} while ((map[0][0] != 1) || (map[0][2] != 1) || (map[0][4] != 1) || (map[0][9] != 1) || (map[2][9] != 1) || (map[4][9] != 1) ||
		(map[5][0] != 1) || (map[7][0] != 1) || (map[9][0] != 1) || (map[9][5] != 1) || (map[9][7] != 1) || (map[9][9] != 1));
	cout << endl << "Вы победили!" << endl;

	return 0;
}
