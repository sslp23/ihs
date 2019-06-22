#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

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
	printf("\n\n  BEM VINDO AO SISTEMA DE SEGURANCA\n\n  ");
	printf("1 -  CADASTRAR NOVO USUARIO\n\n  ");
	printf("2 -  ACESSAR O SISTEMA\n\n  ");
}

int main() {
  int i, j, k, a, countUSER=0, verify=0, aux;
  char username[100];

  USUARIO u[50];

  int dev = open("/dev/de2i150_altera", O_RDWR);

  system("clear");
  menu();
  for(i=0; i>-1; i++){
	read(dev, &a, 1);

	if(a==14){
		system("clear");
		printf("Insira a senha do sistema\n");  
		for(k=0; k>-1; k++){
			read(dev, &j, 2);
			read(dev, &j, 2);
			read(dev, &j, 2); //so funciona com 3 reads???

			write(dev, &j, 3);
    		write(dev, &j, 3);
    		
    		if(j==SENHA){
    			countUSER++; //entrou novo usuario
    			break;
    		}
    	}
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
	if(a==13){
		system("clear");
		printf("Tire a foto e aperte 1\n");
		for(k=0; k>-1; k++){
			
			read(dev, &aux, 1);

    		if(aux==14){	
    			break;
    		}
    	}
		system("clear");
		printf("Foto invalida! Tente inserir a senha do sistema e aperte 1");
    	sleep(5);

		for(k=0; k>-1; k++){
			//sleep(5);
			read(dev, &j, 2);
			read(dev, &j, 2);
			read(dev, &j, 2); //so funciona com 3 reads???

			write(dev, &j, 3);
    		write(dev, &j, 3);
    		
    		read(dev, &aux, 1);
    		read(dev, &aux, 1);
    		read(dev, &aux, 1);
    		if(aux==14){	
    			break;
    		}
    	}
    	if(j == SENHA){
    		//printf("%d\n", a);
    		verify = 1;
    	}
    	else{
    		//printf("%d\n", aux);
    		verify = 1;
    		break;
    	}
		sleep(5);
	}
	if(verify == 1){
		system("clear");
		menu();
		verify = 0;
	}
  }

  printf("ERRO! TENTATIVA DE INVASAO");
  close(dev);
  return 0;
}
