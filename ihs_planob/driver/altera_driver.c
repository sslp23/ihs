#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/pci.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <asm/uaccess.h>

#define INBUTT 1 // a entrada é pelos botoes
#define INSWITCH 2 // a entrada é pelos switches
#define OUTLEDR 3 //saida dos leds
#define OUTHEX1 4 //saida do bcd
#define OUTHEX2 5 //saida do bcd2
#define OUTLEDG 6 //saida do led verde

MODULE_LICENSE("Dual BSD/GPL");
MODULE_DESCRIPTION("Basic Driver PCIHello");
MODULE_AUTHOR("sergio pessoa (com fortes inspiracoes!)");

//-- Hardware Handles

static void *hexport;  // handle to 32-bit output PIO (bcd 1)
static void *bcd1; //bcd 2
static void *inport;   // handle to 16-bit input PIO (switch)
static void *butt; // botoes
static void *led; // leds
static void *ledverde; //led verde

//-- Char Driver Interface
static int   access_count =  0;
static int   MAJOR_NUMBER = 91;

static int   control = 0; // faz a verificacao de escrita
static int   switch_on = 0; //pega os ultimos switches apertados
static int   butt_on = 0; //pega os ultimos botoes apertados


static int     char_device_open    ( struct inode * , struct file *);
static int     char_device_release ( struct inode * , struct file *);
static ssize_t char_device_read    ( struct file * , char *,       size_t , loff_t *);
static ssize_t char_device_write   ( struct file * , const char *, size_t , loff_t *);

static struct file_operations file_opts = {
      .read = char_device_read,
      .open = char_device_open,
     .write = char_device_write,
   .release = char_device_release 
};

static int char_device_open(struct inode *inodep, struct file *filep) {
   access_count++;
   printk(KERN_ALERT "altera_driver: opened %d time(s)\n", access_count);
   return 0;
}

static int char_device_release(struct inode *inodep, struct file *filep) {
   printk(KERN_ALERT "altera_driver: device closed.\n");
   return 0;
}

static ssize_t char_device_read(struct file *filep, char *buf, size_t opcao, loff_t *off) {
  uint32_t entrada = 0;

  switch(opcao){
    case INSWITCH:
      entrada = ioread32(inport);
      if(entrada != switch_on && entrada !=0){ //controla a leitura do switch
        control = 1;
      }
      switch_on = entrada;
      break;

    case INBUTT:
      entrada = ioread32(butt);
      if(entrada != butt_on && entrada != 15 && entrada !=0){
        control = 1;
      }
      butt_on = entrada;
      break;

    default:
      printk(KERN_ALERT "Erro!\n");
      return -1; // send error to user space
  }

  if(control == 1){//é pra ler o botao/switch
    copy_to_user(buf, &entrada, sizeof(uint32_t));  
    printk(KERN_ALERT "mandou: %d", entrada);
    control = 0;
    return 4;
  }
  else{
    return 0;
  } 

}

static ssize_t char_device_write(struct file *filep, const char *buf, size_t opcao, loff_t *off) {
  uint32_t entrada = 0;

  copy_from_user(&entrada, buf, sizeof(uint32_t)); //pega o dado do kernel

  switch(opcao){
    case OUTLEDR:
      iowrite32(entrada, led); //sai pros leds
      printk(KERN_ALERT "Escreveu Led Vermelho: %d", entrada);
      break;
    case OUTHEX1:
      printk(KERN_ALERT "Escreveu BCD1: %d", entrada);
      iowrite32(entrada, hexport); //sai pro primeiro bcd
      break;
    case OUTHEX2:
      printk(KERN_ALERT "Escreveu BCD2: %d", entrada);
      iowrite32(entrada, bcd1); //sai pro segundo bcd
      break;
    case OUTLEDG:
      printk(KERN_ALERT "Escreveu Led Verd: %d", entrada);
      iowrite32(entrada, ledverde); //sai pro led verde
      break;
    default:
      printk(KERN_ALERT "Erro!\n");
      return -1; // send error to user space
  }
  
  return 4;
}

//-- PCI Device Interface

static struct pci_device_id pci_ids[] = {
  { PCI_DEVICE(0x1172, 0x0004), },
  { 0, }
};
MODULE_DEVICE_TABLE(pci, pci_ids);

static int pci_probe(struct pci_dev *dev, const struct pci_device_id *id);
static void pci_remove(struct pci_dev *dev);

static struct pci_driver pci_driver = {
  .name     = "alterahello",
  .id_table = pci_ids,
  .probe    = pci_probe,
  .remove   = pci_remove,
};

static unsigned char pci_get_revision(struct pci_dev *dev) {
  u8 revision;

  pci_read_config_byte(dev, PCI_REVISION_ID, &revision);
  return revision;
}

static int pci_probe(struct pci_dev *dev, const struct pci_device_id *id) {
  int vendor;
  int retval;
  unsigned long resource;

  retval = pci_enable_device(dev);
  
  if (pci_get_revision(dev) != 0x01) {
    printk(KERN_ALERT "altera_driver: cannot find pci device\n");
    return -ENODEV;
  }

  pci_read_config_dword(dev, 0, &vendor);
  printk(KERN_ALERT "altera_driver: Found Vendor id: %x\n", vendor);

  resource = pci_resource_start(dev, 0);
  printk(KERN_ALERT "altera_driver: Resource start at bar 0: %lx\n", resource);

  hexport = ioremap_nocache(resource + 0XC280, 0x20);
  inport  = ioremap_nocache(resource + 0XC2C0, 0x20);
  butt = ioremap_nocache(resource + 0XC300, 0x20);
  bcd1 = ioremap_nocache(resource + 0XC340, 0x20);
  led = ioremap_nocache(resource + 0XC200, 0x20);
  ledverde = ioremap_nocache(resource + 0XC240, 0x20);
  return 0;
}

static void pci_remove(struct pci_dev *dev) {
  iounmap(hexport);
  iounmap(inport);
  iounmap(butt);
  iounmap(bcd1);
  iounmap(led);
  iounmap(ledverde);
}


//-- Global module registration

static int __init altera_driver_init(void) {
   int t = register_chrdev(MAJOR_NUMBER, "de2i150_altera", &file_opts);
   t = t | pci_register_driver(&pci_driver);

   if(t<0)
      printk(KERN_ALERT "altera_driver: error: cannot register char or pci.\n");
   else
     printk(KERN_ALERT "altera_driver: char+pci drivers registered.\n");

   return t;
}

static void __exit altera_driver_exit(void) {
  printk(KERN_ALERT "Goodbye from de2i150_altera.\n");

  unregister_chrdev(MAJOR_NUMBER, "de2i150_altera");
  pci_unregister_driver(&pci_driver);
}

module_init(altera_driver_init);
module_exit(altera_driver_exit);
