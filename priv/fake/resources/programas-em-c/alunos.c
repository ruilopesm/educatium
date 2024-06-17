/* ------------------------------------------
   Ficha 4: Alunos
   ------------------------------------------
*/

#include <stdio.h>

#define MAXALUNO 100
#define MAXNUM   10
#define MAXNOME  60
#define MAXNOTA  10

typedef char Numero[MAXNUM];
typedef char Nome[MAXNOME];
typedef int Notas[MAXNOTA];

void listaAlunos(Numero X[], Nome Y[], Notas Z[])
{
  int i=0, j;

  printf("\n          LISTAGEM DOS ALUNOS\n");
  printf("------------------------------------------\n");
  while((Y[i][0]!='\0') && (i<MAXALUNO))
    {
      printf("%10s:%30s:",X[i],Y[i]);
      for(j=0;j<MAXNOTA;j++)
        printf("%2d:",Z[i][j]);
      printf("\n");
      i++;
    }
  printf("\n------------------------------------------");
}

void MediaDisc( Notas A[], Nome B[] )
{
  int i=0, j, Totais[MAXNOTA]={0};

  while((B[i][0]!='\0') && (i<MAXALUNO))
  {
    for(j=0;j<MAXNOTA;j++)
      Totais[j]+=A[i][j];
    i++;
  }
  printf("\n          MEDIA POR DISCIPLINA (%d alunos)\n",i);
  for(j=0;j<MAXNOTA;j++)
    printf("%d ",Totais[j]/i);
  printf("\n ------------------------------\n");
}

int getPos( char *nome, Nome X[] )
{
  int i=0;
  while((strcmp(nome,X[i])) && (X[i][0]!='\0'))
    i++;

  return (X[i][0]!='\0')?i:-1;
}


int main()
{
  Numero AlunoNum[MAXALUNO] = {"4140","4156","4238"};
  Nome AlunoNom[MAXALUNO] = {"Jose Alberto","Jose Carlos","Paulo Jorge","\0"};
  Notas AlunoNot[MAXALUNO] = {{12,15,0,0,12,0,0,18,17,0},
                              {13,14,11,0,0,11,10,0,0,0},
                              {15,10,0,0,0,13,12,14,0,0}};

  listaAlunos(AlunoNum,AlunoNom,AlunoNot);  
  MediaDisc(AlunoNot, AlunoNom);

  printf("\n%d : %d : %d \n\n", getPos("Jose Carlos",AlunoNom), getPos("Paulo Jorge",AlunoNom), getPos("Jose Alberto", AlunoNom));
}
