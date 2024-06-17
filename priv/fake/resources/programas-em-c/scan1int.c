#include <stdio.h>

int main()
{
	int n;

	/* A fun��o scanf devolve um inteiro indicando quantos dos argumentos
	pretendidos conseguiu ler. Devolve um n�mero negativo em situa��o de
	erro e EOF quando chega ao fim do buffer de input. */

	printf("\nIntroduza um inteiro: ");
	while(scanf("%d",&n)!=1) /* Conseguimos ler um inteiro? */
	  {
		scanf("%*[^\n]"); /* Se n�o, limp�mos o buffer! */
		printf("\n\nInteiro inv�lido!\n\nIntroduza-o de novo: ");
	  }

	printf("\n\nFoi lido o inteiro: %d\n\n",n);

	return 0;
}
