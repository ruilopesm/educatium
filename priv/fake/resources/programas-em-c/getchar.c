/* parseint.c

   Fun��o que l� um inteiro do stdin seguindo
   a defini��o dada pela express�o regular:

   inteiro = (+|-)?[0-9]+
*/

#include <stdio.h>

#define INPUTERROR -1001

int limpa_buffer()
{
  char c;
  do
  {
	c=getchar();
  } while(c!='\n');
}

int isDigit( char d )
{
  return ((d>='0')&&(d<='9'))? 1:0;
}

int parseint()
{
  char c;
  int valor=0, sinal=1;

  c = getchar();
  if(c=='+') c=getchar();
  if(c=='-')
  {
	sinal=-1;
	c=getchar();
  }

  while(isDigit(c))
  {
	valor = valor*10 + c-'0';
	c=getchar();
  }

  if(c=='\n') return (valor*sinal);
  else
  {
	limpa_buffer();
	return INPUTERROR;
  }
}

int main()
{
	int n;

	do
	{
	  printf("\n\nIntroduza um valor inteiro: ");
	  n = parseint();
	}
	 while(n==INPUTERROR);

	printf("\n\nFoi lido o inteiro: %d\n\n",n);

	return 0;
}