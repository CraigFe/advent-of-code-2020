#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

/* Count the number of lines in a given file */
int count_lines(FILE *fp)
{
	size_t len = 0;
	char *line = NULL;
	int count = 0;

	for (; getline(&line, &len, fp) != -1; count++);

	rewind(fp);
	free(line);
	return count;
}

void read_expenses(FILE *fp, int **ptr_expenses, int *ptr_len)
{
	int lines = count_lines(fp);
	int *expenses = (int *) malloc(sizeof(int) * lines);
	*ptr_len = lines;
	*ptr_expenses = expenses;

	size_t len = 0;
	char *line = NULL;

	for (int i = 0; getline(&line, &len, fp) != -1; i++)
	{
		expenses[i] = atoi(line);
	}
}

int compare_int(const void *a, const void *b)
{
	return (*(int*)a - *(int*)b);
}

/* Find a pair of integers that sum to the required total in a sorted array. */
void pairs_sum_to(int* values, int length, int total, int** left_ptr, int** right_ptr)
{
	/* Keep a left pointer and a right pointer, advance them towards
	 * each other according to their current total until the target is
	 * reached. */
	int small = 0;
	int large = length - 1;
	int sum;

	while ((sum = values[small] + values[large]) != total
		&& small < length
		&& large >= 0)
	{
		if (sum < total) small++;
		if (sum > total) large--;
	}

	if (small >= length || large < 0) return;

	int *left = malloc(sizeof(int));
	int *right = malloc(sizeof(int));

        *left = values[small];
	*right = values[large];

	*left_ptr = left;
	*right_ptr = right;
}

void part_one(FILE* fp, int* expenses, int nb_expenses)
{
	printf("--- Part One ---\n");

	int* small = NULL;
	int* large = NULL;
	pairs_sum_to(expenses, nb_expenses, 2020, &small, &large);

	printf("%d + %d = %d\n", *small, *large, *small + *large);
	printf("%d * %d = %d\n\n", *small, *large, *small * *large);
}

void part_two(FILE* fp, int* expenses, int nb_expenses)
{
	printf("--- Part Two ---\n");

	int* small = NULL;
	int* large = NULL;

	for (int i = 0; i < nb_expenses; i++) {
		int current = expenses[i];

		pairs_sum_to(expenses, nb_expenses, 2020 - current, &small, &large);
		if (small != NULL) {
			printf("%d + %d + %d = %d\n", *small, *large, current, *small + *large + current);
			printf("%d * %d * %d = %d\n\n", *small, *large, current, *small * *large * current);
			break;
		}
	}
}

int main(void)
{
	/* Read all expenses into a sorted array */
	FILE *fp = fopen("./input.txt", "r");
	if (fp == NULL) exit(EXIT_FAILURE);

	int nb_expenses;
	int *expenses;
	read_expenses(fp, &expenses, &nb_expenses);
	qsort(expenses, nb_expenses, sizeof(int), compare_int);

	part_one(fp, expenses, nb_expenses);
	part_two(fp, expenses, nb_expenses);
}
