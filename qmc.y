%{
#include <stdio.h>	
#include <stdlib.h>

#define N 17
#define NUMTYPE float

// a few sets
int succ_set[N] = {0};

int fail_set[N] = {0};

// a few matrice
float super_operator[N][N][8] = {0.0};

float init_state[4] = {0.5, 0, 0, 0.5};

// number of matrice of super operator
int n_matrix[N][N] = {0};

void algorithm_VI(int s, int step, int *target_set, float *state, float *result);

void print_matrix(float *m);

%}

%union 
{
	int  	n_val;
	float   f_val;
	int* 	array_val;
}

%token <n_val> TRUE
%token <n_val> SUCC
%token <n_val> FAIL
%token <n_val> NOT
%token <n_val> AND
%token <n_val> EOE
%token <f_val> NUMBER
%token <n_val> STEP
%token <n_val> Q
%token <n_val> GE LE
%token <n_val> L R

%nonassoc AND
%right NOT

%%

logic_list: 		/* nothing */
				|	logic_list logic EOE {
											printf("\n{ ");
											for (int i = 0; i < N; i++) 
											{
												if ($<array_val>2[i] == 1) 
													printf("s%d ", i);
											}

											printf("}\n");
										 }
				;

logic: 			TRUE 	{
							$<array_val>$ = (int *)malloc(N * sizeof(int));
							
							for (int i = 0; i < N; i++) 
								$<array_val>$[i] = 1;
						}

				|	atom {
							$<array_val>$ = (int *)malloc(N * sizeof(int));
							
							for (int i = 0; i < N; i++) 
								$<array_val>$[i] = $<array_val>1[i];
						 }

				| 	NOT logic 	{
									$<array_val>$ = (int *)malloc(N * sizeof(int));

									for (int i = 0; i < N; i++) 
										$<array_val>$[i] = 1 ^ $<array_val>2[i];
									
								}
				|	logic AND logic 	{
											$<array_val>$ = (int *)malloc(N * sizeof(int));

											for (int i = 0; i < N; i++) 
												$<array_val>$[i] = $<array_val>1[i] & $<array_val>3[i];

										}


				|	L Q GE NUMBER STEP logic R
					{

						$<array_val>$ = (int *)malloc(N * sizeof(int));

						for (int i = 0; i < N; i++)
						{
							NUMTYPE result[4] = {0.0};

							algorithm_VI(i, $<n_val>5, $<array_val>6, init_state, result);

							//printf("s%d:\n", i);
							//print_matrix(result);

							if (result[0] + result[3] >= $<f_val>4)
								$<array_val>$[i] = 1;
						}
					}

				|	L Q LE NUMBER STEP logic R 
					{

						$<array_val>$ = (int *)malloc(N * sizeof(int));

						for (int i = 0; i < N; i++)
						{
							NUMTYPE result[4] = {0.0};

							algorithm_VI(i, $<n_val>5, $<array_val>6, init_state, result);

							//printf("s%d:\n", i);
							//print_matrix(result);

							if (result[0] + result[3] <= $<f_val>4)
								$<array_val>$[i] = 1;
						}
					}
				;

atom:			SUCC 	{
							$<array_val>$ = (int *)malloc(N * sizeof(int));
							for (int i = 0; i < N; i++)
							{
								$<array_val>$[i] = succ_set[i];
							}
	
						}

				| FAIL 	{
							$<array_val>$ = (int *)malloc(N * sizeof(int));
							for (int i = 0; i < N; i++)
							{
								$<array_val>$[i] = fail_set[i];
							}
						}
				;

%%
void set_to_half_Set_zero(int i, int j)
{
	n_matrix[i][j] = 2;

	super_operator[i][j][0] = 0.707;
	super_operator[i][j][5] = 0.707;
	
}


void set_to_half_Set_plus(int i, int j)
{
	n_matrix[i][j] = 2;

	super_operator[i][j][0] = 0.5;
	super_operator[i][j][2] = 0.5;

	super_operator[i][j][5] = 0.5;
	super_operator[i][j][7] = 0.5;
}


void set_to_half_I(int i, int j)
{
	n_matrix[i][j] = 1;

	super_operator[i][j][0] = 0.707;
	super_operator[i][j][3] = 0.707;
}


void set_to_half_X(int i, int j) 
{
	n_matrix[i][j] = 1;

	super_operator[i][j][1] = 0.707;
	super_operator[i][j][2] = 0.707;
	
}

void set_to_half_Z(int i, int j)
{
	n_matrix[i][j] = 1;

	super_operator[i][j][0] = 0.707;
	super_operator[i][j][3] = -0.707;
}

void set_to_I(int i, int j)
{
	n_matrix[i][j] = 1;

	super_operator[i][j][0] = 1;
	super_operator[i][j][3] = 1;
}

void set_to_epsilon_zero(int i, int j)
{
	n_matrix[i][j] = 1;

	super_operator[i][j][0] = 1;
}

void set_to_epsilon_one(int i, int j)
{
	n_matrix[i][j] = 1;

	super_operator[i][j][3] = 1;
}

void set_to_epsilon_plus(int i, int j)
{
	n_matrix[i][j] = 1;

	super_operator[i][j][0] = 0.5;
	super_operator[i][j][1] = 0.5;
	super_operator[i][j][2] = 0.5;
	super_operator[i][j][3] = 0.5;

}

void set_to_epsilon_minus(int i, int j)
{
	n_matrix[i][j] = 1;

	super_operator[i][j][0] = 0.5;
	super_operator[i][j][1] = -0.5;
	super_operator[i][j][2] = -0.5;
	super_operator[i][j][3] = 0.5;
}

void print_matrix(float *m)
{
	printf("\n %f, %f\n %f, %f\n", *m, *(m + 1), *(m + 2), *(m + 3));

}

void print_qmc(void)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			if(n_matrix[i][j] > 0)
			{
				printf("s%d -> s%d:\n", i, j);

				print_matrix(super_operator[i][j]);
				printf("\n");

				if (n_matrix[i][j] > 1) 
				{
					print_matrix(super_operator[i][j] + 4);
					printf("\n");
				}
			}
		}
	}

}

void operate_on_state(int i, int j, float *state, float *next_state)
{
	for (int k = 0; k < 4; k++)
		next_state[k] = 0;

	NUMTYPE temp1[4] = {0.0};
	NUMTYPE temp2[4] = {0.0};

	temp1[0] = super_operator[i][j][0] * state[0] + super_operator[i][j][1] * state[2];
	temp1[1] = super_operator[i][j][0] * state[1] + super_operator[i][j][1] * state[3];
	temp1[2] = super_operator[i][j][2] * state[0] + super_operator[i][j][3] * state[2];
	temp1[3] = super_operator[i][j][2] * state[1] + super_operator[i][j][3] * state[3];

	next_state[0] += temp1[0] * super_operator[i][j][0] + temp1[1] * super_operator[i][j][1];
	next_state[1] += temp1[0] * super_operator[i][j][2] + temp1[1] * super_operator[i][j][3];
	next_state[2] += temp1[2] * super_operator[i][j][0] + temp1[3] * super_operator[i][j][1];
	next_state[3] += temp1[2] * super_operator[i][j][2] + temp1[3] * super_operator[i][j][3];

										
										
	// cal matrix
	temp2[0] = super_operator[i][j][0+4] * state[0] + super_operator[i][j][1+4] * state[2];
	temp2[1] = super_operator[i][j][0+4] * state[1] + super_operator[i][j][1+4] * state[3];
	temp2[2] = super_operator[i][j][2+4] * state[0] + super_operator[i][j][3+4] * state[2];
	temp2[3] = super_operator[i][j][2+4] * state[1] + super_operator[i][j][3+4] * state[3];

	next_state[0] += temp2[0] * super_operator[i][j][0+4] + temp2[1] * super_operator[i][j][1+4];
	next_state[1] += temp2[0] * super_operator[i][j][2+4] + temp2[1] * super_operator[i][j][3+4];
	next_state[2] += temp2[2] * super_operator[i][j][0+4] + temp2[3] * super_operator[i][j][1+4];
	next_state[3] += temp2[2] * super_operator[i][j][2+4] + temp2[3] * super_operator[i][j][3+4];

}

void algorithm_VI(int s, int step, int *target_set, float *state, float *result)
{
	for (int i = 0; i < 4; i++)
		result[i] = 0;

	if (target_set[s] == 1)
	{
		result[0] = 1.0 * state[0];
		result[1] = 1.0 * state[1];
		result[2] = 1.0 * state[2];
		result[3] = 1.0 * state[3];

		return;
	}

	if (step == 0)
	{
		result[0] = 0.0 * state[0];
		result[1] = 0.0 * state[1];
		result[2] = 0.0 * state[2];
		result[3] = 0.0 * state[3];

		return;
	}

	for (int i = 0; i < N; i++)
	{
		if (n_matrix[s][i] > 0)
		{
			NUMTYPE next_state[4] = {0};

			NUMTYPE temp[4] = {0};

			operate_on_state(s, i, state, next_state);

			//printf("s%d ->-> s%d", s, i);
			//print_matrix(next_state);

			algorithm_VI(i, step - 1, target_set, next_state, temp);

			for (int k = 0; k < 4; k++)
				result[k] += temp[k];

		}

	}
	
}
void init_qmc(void) 
{
	succ_set[16] = 1;

	fail_set[15] = 1;

	// configuration of QMC of BB84

	set_to_half_Set_zero(0, 1);
	set_to_half_Set_plus(0, 2);

	set_to_half_I(1, 3);
	set_to_half_X(1, 4);

	set_to_half_I(2, 5);
	set_to_half_Z(2, 6);

	for (int i = 3; i < 7; i++)
	{
		set_to_half_I(i, 2 * i + 1);
		set_to_half_I(i, 2 * i + 2);
	}

	set_to_I(8, 8);
	set_to_I(10, 10);
	set_to_I(11, 11);
	set_to_I(13, 13);
	set_to_I(15, 15);
	set_to_I(16, 16);

	set_to_epsilon_zero(7, 16);
	set_to_epsilon_one(7, 15);

	set_to_epsilon_one(9, 16);
	set_to_epsilon_zero(9, 15);

	set_to_epsilon_minus(12, 15);
	set_to_epsilon_plus(12, 16);

	set_to_epsilon_plus(14, 15);
	set_to_epsilon_minus(14, 16);

}

int main(int argc, char **argv)
{
	init_qmc();

	// print_qmc();

	yyparse();

	return 0;
}

int yyerror(char *s)
{
	return 0;
}

