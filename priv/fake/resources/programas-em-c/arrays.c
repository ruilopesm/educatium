/* -----------------------------
   arrays.c - Processamento de Arrays
	 2006-03-21: Created by jcr
   ------------------------------------- */

void menu()
{
  printf("\n\n    Sequencias de inteiros: lista de operacoes\n");
  printf("A - Ler a Sequencia\n");
  printf("B - Escrever a Sequencia\n");
  printf("C - Calcular o Maximo da Sequencia\n");
  printf("D - Calcular o Minimo da Sequencia\n");
  printf("E - Determinar a subsequencia de elementos acima da media\n");
  printf("F - Determinar a subsequencia de elementos abaixo da media\n");
  printf("G - Calcular o mmc da sequencia\n");
  printf("H - Ordenar a Sequencia com o BubbleSort\n");
  printf("I - Ordenar a Sequencia com o QuickSort\n");
  printf("J - Procurar um elemento\n");
  printf("S - Sair do Programa\n");
  printf("    Opcao: ");
}

/* ---------------------------
   quick sort
	 2006-03-22: created by jcr
   ----------------------------- */

void troca( int *a, int *b )
{ int t=*a; *a=*b; *b=t; }

void quickSort( int A[], int i, int j )
{
  int pivot, l, r;

  if(j>i+1)
  {
	pivot = A[i];
	l = i+1;
	r = j;

	while(l<r)
	{
	  if(A[l]<=pivot) l++;
	  else
	  {
		troca(&A[l],&A[r]);
		r--;
	  }
	}

	troca(&A[l],&A[i]);
	l--;

	escreverSeq(A,j+1);

	quickSort(A,i,l);
	quickSort(A,r,j);
  }
}

/* ---------------------------
   bubble sort
	 2006-03-22: created by jcr
   ----------------------------- */

void bubbleSort( int A[], int nelems )
{
  int i=nelems-1, j, temp, troca=1;

  while((i>0)&&troca)
  {
	troca = 0; // Para j� n�o houve nenhuma troca

	for(j=0;i>j;j++)
	{
	  if(A[j]>A[j+1])
	  {
		troca = 1; // Houve uma troca nesta itera��o
		temp = A[j];
		A[j] = A[j+1];
		A[j+1] = temp;
	  }
	}
	i--;
  }
}

/* ---------------------------
   Pesquisa Bin�ria
	 2006-03-30: created by jcr
   ----------------------------- */

int procura( int A[], int nelems, int elem )
{
  int i, inf=0, sup=nelems-1;

  i = (sup+inf)/2;
  while( (A[i]!= elem) && (inf <= sup))
  {
	if(A[i]<elem) inf = i+1;
	else sup = i-1;

	i = (sup+inf)/2;
  }

  if(A[i]==elem) return i;
  else return -1;
}



/* -------------------------------------------------
   Minimo Multiplo Comum entre dois numeros inteiros
   -------------------------------------------------
*/
int mmc( int a, int b )
{
  int aux=a;

  if(a<b) return mmc(b,a);
  else
	if(a%b==0) return a;
	else
	{
	  do
	  { aux+=a;
	  } while((aux%a!=0)||(aux%b!=0));
	  return aux;
	}
}

/* --- Aplicando o algoritmo anterior � Seq
		 Optei por faz�-lo recursivo para fins did�cticos --- */

int mmcSeq( int A[], int nelems )
{
  if(nelems>1)
	return mmcSeqAux( A+2, nelems-2, mmc(A[0],A[1]) );
  else
	if(nelems) return A[0];
	else return 0;
}

int mmcSeqAux( int A[], int nelems, int mmcact )
{
  if(nelems==0) return mmcact;
  else return mmcSeqAux( A+1, nelems-1, mmc(mmcact,A[0]));
}

/* -------------------
   M�ximo da Sequencia
   ------------------- */

int maxSeq( int A[], int nelems )
{
  int max = A[0], i;

  for(i=1;i<nelems;i++)
	if(A[i]>max) max=A[i];

  return max;
}

/* -------------------
   M�nimo da Sequencia
   ------------------- */

int minSeq( int A[], int nelems )
{
  int min = A[0], i;

  for(i=1;i<nelems;i++)
	if(A[i]<min) min=A[i];

  return min;
}


int lerSeq( int A[], int nelems )
{
  int i=0, cont=0, n;

  do
  {
	printf("\nIntroduza o elemento %d: ", i+1);
	cont += scanf("%d",&n);
	if(n) A[i]=n;
	i++;
  }
	while((i<nelems) && n);

  if(n)
	return cont;
  else
	return cont-1;
}

int escreverSeq( int A[], int nelems )
{
  int i;

  printf("\n\n");
  for(i=0;i<nelems;i++)
	printf("%d ",A[i]);
  printf("\n\n");

  return 0;
}

int somaSeq( int A[], int nelems )
{
  if(!nelems) return 0;
  else return A[0] + somaSeq(A+1,nelems-1);
}

int acimaMedia( int A[], int nelems , int subA[], float media)
{
  int i, j=0, cont=0;

  for(i=0;i<nelems;i++)
	if(A[i]>media)
	{  subA[j++]=A[i];
	   cont++;
	}
  return cont;
}

int abaixoMedia( int A[], int nelems , int subA[], float media)
{
  int i, j=0, cont=0;

  for(i=0;i<nelems;i++)
	if(A[i]<media)
	{  subA[j++]=A[i];
	   cont++;
	}
  return cont;
}

#define MAX 10 // numero maximo de elementos na sequencia

int main()
{
  char op;
  int sequencia[MAX] = {0}; // inicializacao a 0
  int subseq[MAX] = {0};    // vector para guardar as subseqs
  int lidos;   // numero de posicoes ocupadas na sequencia
  int nsubseq; // numero de elementos na subseq
  int soma;    // soma dos elementos lidos para a sequencia
  float media;
  int elem;    // elemento a procurar
  int res;     // resultado da procura

  menu();
  op = getchar();

  while(op!='S')
  {
	switch(op)
	{
	  case 'A' : lidos = lerSeq(sequencia,MAX);
				 soma = somaSeq(sequencia,lidos);
				 media = soma / lidos;
				 printf("\n\nForam lidos %d elementos.\n",lidos);
				 printf("    Soma: %d\n",soma);
				 printf("    Media: %f\n",media);
				 break;
	  case 'B' : escreverSeq(sequencia,lidos);
				 break;
	  case 'C' : printf("\n\nMax: %d\n\n", maxSeq(sequencia,lidos));
				 break;
	  case 'D' : printf("\n\nMin: %d\n\n", minSeq(sequencia,lidos));
				 break;
	  case 'E' : nsubseq = acimaMedia(sequencia, lidos, subseq, media);
				 escreverSeq(subseq,nsubseq);
				 break;
	  case 'F' : nsubseq = abaixoMedia(sequencia, lidos, subseq, media);
				 escreverSeq(subseq,nsubseq);
				 break;
	  case 'G' : escreverSeq(sequencia,lidos);
				 printf("\n\nMMC: %d\n\n", mmcSeq(sequencia,lidos));
				 break;
	  case 'H' : bubbleSort(sequencia,lidos);
				 escreverSeq(sequencia,lidos);
				 break;
	  case 'I' : quickSort(sequencia,0,lidos-1);
				 escreverSeq(sequencia,lidos);
				 break;
	  case 'J' : printf("\nIntroduza o elemento a procurar: ");
				 scanf("%d",&elem);
				 res = procura(sequencia,lidos,elem);
				 if(res>=0)
				   printf("\nElemento encontrado na posi��o %d\n",res);
				 else
				   printf("\n\nElemento Inexistente!\n\n");
				 break;
	}
	getchar(); // limpar o \n do buffer de entrada
	menu();
	op = getchar();
  }

  return 0;
}
