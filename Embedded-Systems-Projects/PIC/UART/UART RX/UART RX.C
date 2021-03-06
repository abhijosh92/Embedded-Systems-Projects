#include<stdio.h>
#include<PIC.h>

void init_uart();
void clr_screen();
void home_screen();
void uart_delay(unsigned int);
void tx(unsigned char);
unsigned char rx();

unsigned char tx_data;

void main()
{

 init_uart();

 while(1)
 {
  tx_data=rx();
  uart_delay(1);

  tx(tx_data);
  uart_delay(1);
 }

}

void init_uart()
{
 TXSTA=0x24;
 SPBRG=25;
 RCSTA=0x90;
}

void clr_screen()
{
 tx(0x1b);
 uart_delay(1);
 tx('[');
 uart_delay(1);
 tx('2');
 uart_delay(1);
 tx('J');
 uart_delay(1);
}

void home_screen()
{
 tx(0x1b);
 uart_delay(1);
 tx('[');
 uart_delay(1);
 tx('H');
 uart_delay(1);
}

void tx(unsigned char tx_data1)
{
 while(TXIF!=1);
 TXREG=tx_data1;
 TXIF=0;
}

unsigned char rx()
{
unsigned char tx_data2;
 while(RCIF!=1);
 tx_data2=RCREG;

 return(tx_data2);
}


void uart_delay(unsigned int del)
{
 int j,i;
 for(i=0;i<=del;i++)
  for(j=0;j<=120;j++);

}
