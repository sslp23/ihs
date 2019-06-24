#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <omp.h>
#include <time.h>

#define SENHA 69905

typedef struct {
	char cpf[50];
	int nr_user;
	char nome[100];
} USUARIO;

unsigned char hexdigit[] = {0x3F, 0x06, 0x5B, 0x4F,
                            0x66, 0x6D, 0x7D, 0x07, 
                            0x7F, 0x6F, 0x77, 0x7C,
			                      0x39, 0x5E, 0x79, 0x71};

void menu(){
	uint32_t x =0;
	int dev = open("/dev/de2i150_altera", O_RDWR);
	write(dev, &x, 3);
	write(dev, &x, 3);
	write(dev, &x, 6);
	write(dev, &x, 6);

	printf("\n\n  BEM VINDO AO SISTEMA DE SEGURANCA\n\n  ");
	printf("1 -  CADASTRAR NOVO USUARIO\n\n  ");
	printf("2 -  ACESSAR O SISTEMA\n\n  ");
	printf("3 -  SAIR DO SISTEMA\n\n  ");
}

int main() {
  int i=0, k=0, countUSER=0, verify=0, nthreads, tid, invade=0, t=0, t0=0, not_invade=0, countINVADER = 0;
  double time_taken;
  uint32_t aux, j, a, xd;
  char username[100];

  USUARIO u[50];

  int dev = open("/dev/de2i150_altera", O_RDWR);

  system("clear");
  menu();
  for(i=0; i>-1; i){
	read(dev, &a, 1);

	if(a==14){
		system("clear");
		printf("Insira a senha do sistema\n");  
		#pragma omp parallel num_threads(2) private(nthreads, tid)
		{
			#pragma omp sections
			{
				#pragma omp section 
				{
					for(k=0; k>-1; k){
						read(dev, &j, 2);
						read(dev, &j, 2);
						read(dev, &j, 2); //so funciona com 3 reads???

						write(dev, &j, 3);
			    		write(dev, &j, 3);
			    		
			    		if(invade==1){
			    			break;
			    		}

			    		if(j==SENHA){
			    			not_invade = 1;
			    			countUSER++; //entrou novo usuario
			    			break;
			    		}
			    	}
		    	}
		    	#pragma omp section
		    	{
		    		t0 = clock();
		    		while(1){
		    			t = clock() - t0;
		    			time_taken = ((double)t)/CLOCKS_PER_SEC;
		    			if(time_taken >= 30.0){
		    				invade = 1;
		    				break;
		    			}
		    			if(not_invade == 1)
		    				break;
		    		}
		    	}
		    }
		}
		if(invade == 1){
			//system("clear");
			//printf("Tentativa de invasao! Voce sera redirecionado para o menu...");
			verify = 1;
		}
		else{
	    	u[countUSER].nr_user = countUSER;
	    	system("clear");
	    	printf("Voce e o usuario #%d do sistema\n", countUSER);		
	    	printf("Digite seu nome de usuario: ");
	    	scanf("%s", u[countUSER].nome);  
	    	
	    	system("clear");
	    	printf("Voce e o usuario #%d do sistema\n", countUSER);		
	    	printf("Digite seu CPF: ");
	    	scanf("%s", u[countUSER].cpf);
			verify = 1;
		}
	}
	if(a==13){
		system("clear");
		printf("Tire a foto e aperte 1\n");
		
		for(k=0; k>-1; k){
			
			read(dev, &aux, 1);

    		if(aux==14){
    			aux=0;	
    			system("clear");
    			break;
    		}
    	}
		
		printf("Foto invalida! Tente inserir a senha do sistema\n");
		#pragma omp parallel num_threads(2) private(nthreads, tid)
		{
			#pragma omp sections
			{
				#pragma omp section 
				{
					for(k=0; k>-1; k){ 
						read(dev, &j, 2);
						read(dev, &j, 2);
						read(dev, &j, 2); //so funciona com 3 reads???

						write(dev, &j, 3);
			    		write(dev, &j, 3);

			    		if(invade == 1){
			    			break;
			    		}

			    		if(j==SENHA){	
			    			verify = 1;
			    			not_invade = 1;
			    			break;
			    		}
			    	}
			    }
				#pragma omp section
		    	{
		    		t0 = clock();
		    		while(1){
		    			t = clock() - t0;
		    			time_taken = ((double)t)/CLOCKS_PER_SEC;
		    			if(time_taken >= 30.0){
		    				invade = 1;
		    				break;
		    			}
		    			if(not_invade == 1){
		    				verify = 1;
		    				break;
		    			}
		    		}
		    	}
			}
		}
		verify = 1;
	}
	if(a == 11){
		break;
	}
	
	if(invade == 1){
		countINVADER++;
		xd = hexdigit[countINVADER & 0xF]
			| (hexdigit[(countINVADER >> 4) & 0xF] << 8)
			| (hexdigit[(countINVADER >> 8) & 0xF] << 16)
			| (hexdigit[(countINVADER >> 12) & 0xF] << 24);
		xd = ~xd;
		write(dev, &xd, 4);
		write(dev, &xd, 4);
	}
	
	if(verify == 1){ //reinicia o menu
		time_taken = 0;
		t = 0;
		t0 = 0;
		invade = 0;
		not_invade = 0;
		system("clear");
		menu();
		verify = 0;
	}
  }
  countINVADER=0;
		xd = hexdigit[countINVADER & 0xF]
			| (hexdigit[(countINVADER >> 4) & 0xF] << 8)
			| (hexdigit[(countINVADER >> 8) & 0xF] << 16)
			| (hexdigit[(countINVADER >> 12) & 0xF] << 24);
		xd = ~xd;
  write(dev, &xd, 4);
  write(dev, &xd, 4);
  close(dev);
  return 0;
}
