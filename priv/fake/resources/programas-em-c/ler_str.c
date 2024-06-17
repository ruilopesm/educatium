/* ler_str.c

   Fun��o que l� uma string do stdin terminada
   por '\n' ou por ter atingido o limite de caracteres:

*/

#include <stdio.h>


int ler_string(char *s, int nchars)
{
  int i=0;

  do
  {
	s[i] = getchar();
	i++;
  }while((s[i-1]!='\n')&&(i<nchars));

  if(s[i-1]=='\n')
  {
	s[i-1] = '\0';
	return i-1;
  }
  else
  {
	s[i] = '\0';
	return i;
  }
}

int main()
{
	char frase[51];

	printf("\n\nIntroduza uma frase: ");
	while( !ler_string(frase,50) )
	  printf("\n\nIntroduza uma frase: ");

	printf("\n\nFoi lida a frase: %s\n\n",frase);

	return 0;
}
