//#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>

int main() {

	int fd = open("/dev/de2i150_altera", O_RDWR);


	//while(1){
		uint32_t data = 0b00100100010000000111100100010000;
		write(fd, &data, 4);
	//}
	close(fd);
	return 0;
}