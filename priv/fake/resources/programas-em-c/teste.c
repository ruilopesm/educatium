/*
 *  teste.c
 *  
 *
 *  Created by Jos� Carlos Ramalho on 08/11/03.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdio.h>
#include "aluno.h"

int main()
{
  FILE *fp;
  Aluno a1 = {"4140","Jose Carlos Ramalho","LESI"};
  Aluno a2 = {"4238","Jose Alberto Rodrigues","LESI"};
  Aluno a3 = {"4156","Paulo Jorge Domingues","LESI"};

  showAluno(a2);
  
  Turma t1;
  
  t1 = consTurma(NULL,a1);
  t1 = consTurma(t1,a2);
  t1 = consTurma(t1,a3);
  
  showTurma(t1);
  
  fp = fopen("ALUNO.TXT","w");
  saveTurma(t1,fp);
  fclose(fp);
  
}