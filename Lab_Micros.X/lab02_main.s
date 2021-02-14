
;-----------Laboratorio 02 Micros------------    
    
; Archivo: main.S
; Dispositivo: PIC16F887
; Autor: Brandon Garrido 
; Compilador: pic-as (v2.30), MPLABX v5.40
;
; Programa: contador en el puerto A
; Hardware: LEDs en el puerto A
;
; Creado: 02 de febrero, 2021

PROCESSOR 16F887
#include <xc.inc>
   
; configuration word 1
CONFIG FOSC=XT //Oscilador de cristal de cuarzo, externo 
CONFIG WDTE=OFF   //WDT disabled (reinicio dispositivo del pic)
CONFIG PWRTE=ON   //PWRT enabled (espera de 72ms al iniciar)
CONFIG MCLRE=OFF  //El pin de MCLR se utiliza como I/O
CONFIG CP=OFF     //Sin protección de código 
CONFIG CPD=OFF	  //Sin protección de datos

CONFIG BOREN=OFF  //Sin reinicio cuándo el voltaje de alimentacion baja de 4v
CONFIG IESO=OFF   //Reinicio sin cambio de reloj de interno a externo 
CONFIG FCMEN=OFF  //Cambio de reloj externo a interno en caso de fallo
CONFIG LVP=ON     //programacion en bajo voltaje permitida

;configuration word 2
CONFIG WRT=OFF    //Protección de autoescritura por el programa desactivada
CONFIG BOR4V=BOR40V //Reinicio abajo de 4V, (BOR21V=2.1V)
    

PSECT resVect, class=CODE, abs, delta=2
    
;---------------- vector reset --------------------

ORG 00h	    ;posición 0000h para el reset 
resetVec:
    PAGESEL main
    goto main
    
PSECT code, delta=2, abs
ORG 100h    ;posicion para el código
 

;----------- Configuración -----------------------

main:
    
    ;banksel ANSEL es un macro que realiza las instrucciones
    ;bsf/bcf STATUS, 5 
    ;bsf/bcf STATUS, 6 para cambiar de banco
    banksel ANSEL ;banco 11
    clrf ANSEL    ; habilitar pines digitales
    clrf ANSELH
    
    
    banksel TRISA ;banco 01
    movlw 11111B
    movwf TRISA	  ; primeros 5 pines en los puertos A como entradas
    
    movlw 11110000B
    movwf TRISB	 ; primeros 4 pines de B como salida
    
    movlw 11110000B
    movwf TRISC	 ; primeros 4 pines de C como salida
		   
    movlw 11100000B
    movwf TRISD	 ; primeros 4 pines de D como salida 
    
    banksel PORTA ;banco 00
    clrf PORTB
    clrf PORTC
    clrf PORTD ;limpiar los valores de los puertos
    


;----------------loop principal--------------------
    
loop:
    ;llamadas de macro contador 1
    btfsc PORTA, 0 ; si pin 0 es presionado cuenta contador 1
    call cont_1
    btfsc PORTA, 1 ; si pin 1 es presionado decrementa contador 1
    call dec_1
    
    ;llamadas de macro contador 2
    btfsc PORTA, 2 ; si pin 2 es presionado cuenta contador 2
    call cont_2
    btfsc PORTA, 3 ; si pin 3 es presionado decrementa contador 2
    call dec_2
    
    ;llamada de macro suma de contadores y carry
    btfsc PORTA, 4 ; si el pin 4 es presionado entonces suma los contadores 
    call suma_contadores
    
    goto loop  ; loop forever

    
cont_1:		; incrementar contador 1
    btfsc PORTA, 0 ; instrucción para evitar rebote del boton
    goto $-1	   ; al ser un pull down hasta que suelte el boton y cambie
		   ; de estado a 0 skipea
    incf PORTB, F
  return
   
dec_1:		; decrementar contador 1
    btfsc PORTA, 1
    goto $-1
    decf PORTB, F
  return
  
cont_2:		; incrementar contador 2
    btfsc PORTA, 2
    goto $-1
    incf PORTC, F
  return
   
dec_2:		; decrementar contador 2
    btfsc PORTA, 3
    goto $-1
    decf PORTC, F
  return

; el macro de suma y encendido de carry

suma_contadores:		
    btfsc PORTA, 4 ; primero verifica que el boton de suma se haya presionado
    goto $-1
    movf PORTB,W   ; mueve el valor del puerto B(contador 1) a W
    addwf PORTC,0; ; suma el valor del puerto C (contador 2) y se almacena en W
    movwf PORTD, F ; Muestra el valor de la suma en el puerto D y si existe 
		   ; carry enciende el led respectivo
    
  return

end