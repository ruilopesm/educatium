/*
 *  teste2.c
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
    
  Turma t1;
  
  fp = fopen("ALUNO.TXT","r");
  t1 = readTurma(fp);
  fclose(fp);
  
  showTurma(t1);
  
}
