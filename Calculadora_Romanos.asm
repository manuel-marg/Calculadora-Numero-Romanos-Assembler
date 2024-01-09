.data
# Proyecto 1
# Nombre: Manuel Rodriguez
menu: .space 4
numRomano1: .space 8
numRomano2: .space 8
numBinario1: .space 32
numBinario2: .space 32
resultado: .space 32
resultadoRomano: .space 8
layout0: .ascii " _________________ \n"
layout1: .ascii "||_______________||   CALCULADORA NUMERO ROMANOS (Nombre: Manuel Rodriguez)\n"
layout3: .ascii "|[VII|VIII| IX][+]|      Menu:\n"
layout4: .ascii "|[ IV|  V | VI][x]|       1. Sumar\n"
layout5: .ascii "|[ I | II |III][%]|       2. Restar\n"
layout6: .ascii "|[.  |  0 |:  ][=]|       3. Multiplicar\n"
layout7: .asciiz " ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯      En el menu solo pulse el numero, no hace falta pulsar enter.\n"
escribanum1: .asciiz " \n\nIngrese el primer numero romano: "
escribanum2: .asciiz " \nIngrese el segundo numero romano: "
mensajeres: .asciiz "\nEl resultado es: "
salto: .asciiz "\n"
negativo: .asciiz "- "
I: .asciiz "I"
IV: .asciiz "IV"
V: .asciiz "V"
IX: .asciiz "IX"
X: .asciiz "X"
XL: .asciiz "XL"
L: .asciiz "L"
XC: .asciiz "XC"
C: .asciiz "C"
CD: .asciiz "CD"
D: .asciiz "D"
CM: .asciiz "CM" 
M: .asciiz "M" 
NADA: .asciiz "NADA"
.text

# $s1 Decimal primer numero
# $s2 Decimal segundo numero
# $s3 tamaño vector con el primer numero en binario
# $s4 tamaño vector con el segundo numero en binario


.macro ImprimirMenu 
# Imprimiendo el Menu
li $v0, 4
la $a0, layout0
syscall
# Recibiendo que opcion selecciono el usuario
li $v0, 8
li $a1, 2
la $a0, menu
syscall
# Obtendo el valor que selecciono en el menu en $s0 (0x31 sumar 0x32 restar 0x33 multiplicar) 
lb $s0, menu
.end_macro	

.macro ObtenerNumerosDelUsuario
# Imprimiendo el mensaje escribanum1
li $v0, 4
la $a0, escribanum1
syscall
# Recibiendo que cadena escribio
li $v0, 8
li $a1, 9
la $a0, numRomano1
syscall
# Imprimiendo el mensaje escribanum1
li $v0, 4
la $a0, escribanum2
syscall
# Recibiendo que cadena escribio
li $v0, 8
li $a1, 9
la $a0, numRomano2
syscall
#Un salto de linea
li $v0, 4
la $a0, salto
syscall 
.end_macro



.macro valorRomano (%caracter)
# Obtener el valor en romano en $t9
    bne %caracter, 73, endIFI #I 73 
        li $t9, 1
    endIFI:
    bne %caracter, 86, endIFV #V 86 
        li $t9, 5
    endIFV:
    bne %caracter, 88, endIFX #X 88 
        li $t9, 10
    endIFX:
    bne %caracter, 76, endIFL #L 76 
        li $t9, 50
    endIFL:
    bne %caracter, 67, endIFC #C 67 
        li $t9, 100
    endIFC:
    bne %caracter, 68, endIFD #D 68 
        li $t9, 500
    endIFD:
    bne %caracter, 77, endIFM #M 77
        li $t9, 1000
    endIFM:
.end_macro

.macro RomanoADecimal
# Pasando de Romano a decimal el primer numero y guardandolo en $s1 en decimal
li $t0, 0 #Indice
li $t4, 0 #Total
.eqv indice $t0
.eqv indiceaux $t5
.eqv carac $t1
.eqv actual $t2 
.eqv siguiente $t3 
.eqv total $t4 
loop:
	lb carac, numRomano1(indice)
	beqz carac, salir
	valorRomano($t1)
	move actual, $t9
	add indiceaux, indice, 1
	lb carac, numRomano1(indiceaux)
	blt carac, 64, ultimoCaracter
	valorRomano($t1)
	move siguiente, $t9
	bge actual, siguiente, sumo
	sub total, total, actual
	li indiceaux, 0
	addi $t0, $t0, 1
	b loop
	sumo:
	add total, total, actual
	li indiceaux, 0
	addi $t0, $t0, 1
	b loop
	ultimoCaracter:	
	add total, total, actual	
	
salir:
move $s1, total

# Pasando de Romano a decimal el segundo numero y guardandolo en $s2 en decimal
li $t0, 0 #Indice
li $t4, 0 #Total
loop2:
	lb carac, numRomano2(indice)
	beqz carac, salir2
	valorRomano($t1)
	move actual, $t9
	add indiceaux, indice, 1
	lb carac, numRomano2(indiceaux)
	blt carac, 64, ultimoCaracter2
	valorRomano($t1)
	move siguiente, $t9
	bge actual, siguiente, sumo2
	sub total, total, actual
	li indiceaux, 0
	addi $t0, $t0, 1
	b loop2
	sumo2:
	add total, total, actual
	li indiceaux, 0
	addi $t0, $t0, 1
	b loop2
	ultimoCaracter2:	
	add total, total, actual	
	
salir2:
move $s2, total
.end_macro

.macro DecimalABinario ()
.eqv indice $t0
.eqv aux $t1 
.eqv num $t5
li indice, 0
# Convirtiendo a Binario el primer numero
move num, $s1
while:
    	bgt num, 0, dividir 
       	b salirWhile
       	dividir: 
        div  num, num, 2 
        mfhi $t2 
        mflo $t3
        #li $v0, 1
        #move $a0, $t2
        #syscall
        beq $t2, 1, Uno
        li $t3, 48
        b endIFUno
        Uno:
        li $t3, 49
        endIFUno:
        sb $t3, numBinario1($t0)
        addi indice, indice, 1 
        b while
salirWhile:


li indice, 0
# Convirtiendo a Binario el segundo numero
move num, $s2
while2:
    	bgt num, 0, dividir2 
       	b salirWhile2
       	dividir2: 
        div  num, num, 2 
        mfhi $t2 
        mflo $t3
        #li $v0, 1
        #move $a0, $t2
        #syscall
        beq $t2, 1, Uno2
        li $t3, 48
        b endIFUno2
        Uno2:
        li $t3, 49
        endIFUno2:
        sb $t3, numBinario2($t0)
        addi indice, indice, 1 
        b while2
salirWhile2:
.end_macro

.macro invertirCadena (%cadena)
#Contando tamaño
li $t0, 0
loopTamano: 
	lb $t1, %cadena($t0)
	beqz $t1, salirTamano
	addi $t0, $t0, 1
	bnez $t1, loopTamano 
salirTamano:
subi $t0, $t0, 1
# Invertir
li $s0, 0 #Indice inicial $t0 Final
loopInvertir:
	lb $t1, %cadena($s0)
	lb $t2, %cadena($t0)
	sb $t1, %cadena($t0)
	sb $t2, %cadena($s0)
	addi $s0, $s0, 1
	subi $t0, $t0, 1
	bgt $s0, $t0, salirInvertir
	b loopInvertir
salirInvertir:
.end_macro


.macro ObteniendoTamañoVectores
#Contando tamaño
li $t0, 0
loopTamanoPrimer: 
	lb $t1, numBinario1($t0)
	beqz $t1, salirTamanoPrimer
	addi $t0, $t0, 1
	bnez $t1, loopTamanoPrimer 
salirTamanoPrimer:
move $s3, $t0 
li $t0, 0
loopTamanoSegundo: 
	lb $t1, numBinario2($t0)
	beqz $t1, salirTamanoSegundo
	addi $t0, $t0, 1
	bnez $t1, loopTamanoSegundo 
salirTamanoSegundo:
move $s4, $t0 
.end_macro


.macro RellenandoVectorMenor
#Rellenar con 0 el vector menor para que tenga la misma cantidad de digitos
.eqv TamanoBin1 $s3
.eqv TamanoBin2 $s4 
.eqv cero $t0
li $t0, 48
beq TamanoBin1, TamanoBin2 FinRelleno
	bgt TamanoBin1, TamanoBin2 Rellenar2
		loopRelleno1:
		sb $t0, numBinario1(TamanoBin1)
		addi TamanoBin1, TamanoBin1, 1
		bne TamanoBin1, TamanoBin2 loopRelleno1
		b FinRelleno
	Rellenar2:
		loopRelleno2:
		sb $t0, numBinario2(TamanoBin2)
		addi TamanoBin2, TamanoBin2, 1
		bne TamanoBin1, TamanoBin2 loopRelleno2
		b FinRelleno
FinRelleno:
.end_macro


.macro SumarBinarios
# Sumando en binario los dos numero ya con la misma longitud
.eqv tamano $t0
.eqv indiceS $t7
.eqv carry $t6
.eqv auxS $t3
.eqv DigitoCero $t4
.eqv DigitoUno $t5
li DigitoCero, 48
li DigitoUno, 49
li carry, 0
li indiceS, 0
move $t0, $s3
subi tamano, tamano,1
loopSuma:
	lb $t1, numBinario1(indiceS)
	lb $t2, numBinario2(indiceS)
	subi $t1, $t1, 0x30
	subi $t2, $t2, 0x30
	add auxS, $t1, $t2
	add auxS, auxS, carry
	li carry, 0
	beq auxS, 0, SCero
	beq auxS, 1, SUno
	beq auxS, 2, SDos
	beq auxS, 3, STres
	SCero:
	sb DigitoCero, resultado(indiceS)
	addi indiceS, indiceS, 1
	b salirDeNido	
	SUno:
	sb DigitoUno, resultado(indiceS)
	addi indiceS, indiceS, 1
	b salirDeNido	
	SDos:
	sb DigitoCero, resultado(indiceS)
	addi indiceS, indiceS, 1
	li carry, 1
	b salirDeNido	
	STres:
	sb DigitoUno, resultado(indiceS)
	addi indiceS, indiceS, 1
	li carry, 1
	b salirDeNido
	salirDeNido:
	subi tamano, tamano, 1
	bgez tamano, loopSuma
	add carry, carry, 0x30
	sb carry, resultado(indiceS)
	
#li $v0, 4
#la $a0, numBinario1
#syscall
#li $v0, 4
#la $a0, salto
#syscall
#li $v0, 4
#la $a0, numBinario2
#syscall
#li $v0, 4
#la $a0, salto
#syscall
#li $v0, 4
#la $a0, resultado
#syscall
.end_macro


.macro RestaBinarios
#Restando dos numeros binarios con la misma longitud
.eqv tamanoR $t0
.eqv indiceR $t7
.eqv borrowR $t6
.eqv auxR $t3
.eqv DigitoCero $t4
.eqv DigitoUno $t5
.eqv TempBorrow $t8
li DigitoCero, 48
li DigitoUno, 49
li borrowR, 0
li indiceR, 0
move $t0, $s3
subi tamanoR, tamanoR,1
loopResta:
	lb $t1, numBinario1(indiceR)
	lb $t2, numBinario2(indiceR)
	subi $t1, $t1, 0x30
	subi $t2, $t2, 0x30
	sub auxR, $t1, $t2
	beq auxR, -1, EsMenosUno
	b SalirEsMenosUno
	EsMenosUno:
	li auxR, 1
	li TempBorrow, 1
	SalirEsMenosUno:
	beq borrowR, 0, SinBorrow
	sub auxR, borrowR, auxR
	SinBorrow:
	beq TempBorrow, 1, ActivarBorrow
	li borrowR, 0
	li TempBorrow, 0
	b SalirActivarBorrow
	ActivarBorrow:
	li borrowR, 1
	li TempBorrow, 0
	SalirActivarBorrow:
	beq auxR, 0, RCero
	beq auxR, 1, RUno
	RCero:
	sb DigitoCero, resultado(indiceR)
	addi indiceR, indiceR, 1
	b salirDeNidoR	
	RUno:
	sb DigitoUno, resultado(indiceR)
	addi indiceR, indiceR, 1
	b salirDeNidoR		
	salirDeNidoR:
	subi tamanoR, tamanoR, 1
	bgez tamanoR, loopResta
	add borrowR, borrowR, 0x30
	sb borrowR, resultado(indiceR)


#invertirCadena(numBinario1)
#invertirCadena(numBinario2)
#invertirCadena(resultado)
#li $v0, 4
#la $a0, salto
#syscall
#li $v0, 4
#la $a0, numBinario1
#syscall
#li $v0, 4
#la $a0, salto
#syscall
#li $v0, 4
#la $a0, numBinario2
#syscall
#li $v0, 4
#la $a0, salto
#syscall
#li $v0, 4
#la $a0, resultado
#syscall
#li $v0, 4
#la $a0, salto
#syscall
#invertirCadena(numBinario1)
#invertirCadena(numBinario2)
#invertirCadena(resultado)

# Imprimiendo si el numero es negativo
blt $s1, $s2, ImprimirNegativo
b SalirImprimirNegativo
ImprimirNegativo:
invertirCadena(resultado)
#Contando tamaño resultado
li $t0, 0
loopTamanoResultado: 
	lb $t1, resultado($t0)
	beqz $t1, salirTamanoResultado
	addi $t0, $t0, 1
	bnez $t1, loopTamanoResultado 
salirTamanoResultado:

subi $t0, $t0, 1
li $t2, 0
loopComp:
	lb $t1, resultado($t0)
	bge $t2, 1, Cambiar
		b salirCambiar
		Cambiar:
		beq $t1, 0x31, CambiarACero
			li $t1, 0x31
			sb $t1, resultado($t0)
			b salirCambiarACero
			CambiarACero:
			li $t1, 0x30
			sb $t1, resultado($t0)
		salirCambiarACero:
	salirCambiar:
	beq $t1, 0x31 conseguiUno
		b salirConseguiUno
	conseguiUno:
 		addi $t2, $t2, 1
 	salirConseguiUno:
 	subi $t0, $t0, 1
 	bgez $t0, loopComp
 	
li $v0, 4
la $a0, negativo
syscall
invertirCadena(resultado)
SalirImprimirNegativo:

.end_macro


.macro MultiplicacionBinarios
# Haciendo multiplicacion pero con el codigo de suma que ya hice solo que un poco modificado
.eqv tamano $t0
.eqv indiceS $t7
.eqv carry $t6
.eqv auxS $t3
.eqv DigitoCero $t4
.eqv DigitoUno $t5
li DigitoCero, 48
li DigitoUno, 49
li carry, 0
li indiceS, 0
.eqv control $t8
move $t0, $s3
subi tamano, tamano,1
li $t8, 0

Multiplicacion:
	bnez control, NoPrimeraVez
	li carry, 0
	li indiceS, 0
	loopSumaP:
		lb $t1, numBinario1(indiceS)
		lb $t2, numBinario1(indiceS)
		subi $t1, $t1, 0x30
		subi $t2, $t2, 0x30
		add auxS, $t1, $t2
		add auxS, auxS, carry
		li carry, 0
		beq auxS, 0, SPCero
		beq auxS, 1, SPUno
		beq auxS, 2, SPDos
		beq auxS, 3, SPTres
		SPCero:
		sb DigitoCero, numBinario2(indiceS)
		addi indiceS, indiceS, 1
		b salirDeNidoP	
		SPUno:
		sb DigitoUno, numBinario2(indiceS)
		addi indiceS, indiceS, 1
		b salirDeNidoP	
		SPDos:
		sb DigitoCero, numBinario2(indiceS)
		addi indiceS, indiceS, 1
		li carry, 1
		b salirDeNidoP	
		SPTres:
		sb DigitoUno, numBinario2(indiceS)
		addi indiceS, indiceS, 1
		li carry, 1
		b salirDeNidoP
		salirDeNidoP:
		subi tamano, tamano, 1
		bgez tamano, loopSumaP
		add carry, carry, 0x30
		sb carry, numBinario2(indiceS)
	addi control, control, 1
	subi $s2, $s2, 2
	
	ObteniendoTamañoVectores
	RellenandoVectorMenor

	
	bnez $s2, Multiplicacion
	b SalirNoPrimeraVez
	
	NoPrimeraVez:
	
ObteniendoTamañoVectores
li carry, 0
li indiceS, 0
loopSumaS:
	lb $t1, numBinario1(indiceS)
	lb $t2, numBinario2(indiceS)
	subi $t1, $t1, 0x30
	subi $t2, $t2, 0x30
	add auxS, $t1, $t2
	add auxS, auxS, carry
	li carry, 0
	beq auxS, 0, SSCero
	beq auxS, 1, SSUno
	beq auxS, 2, SSDos
	beq auxS, 3, SSTres
	SSCero:
	sb DigitoCero, resultado(indiceS)
	addi indiceS, indiceS, 1
	b salirDeNidoS	
	SSUno:
	sb DigitoUno, resultado(indiceS)
	addi indiceS, indiceS, 1
	b salirDeNidoS	
	SSDos:
	sb DigitoCero, resultado(indiceS)
	addi indiceS, indiceS, 1
	li carry, 1
	b salirDeNidoS	
	SSTres:
	sb DigitoUno, resultado(indiceS)
	addi indiceS, indiceS, 1
	li carry, 1
	b salirDeNidoS
	salirDeNidoS:
	subi tamano, tamano, 1
	bgez tamano, loopSumaS
	add carry, carry, 0x30
	sb carry, resultado(indiceS)
	
	#invertirCadena(numBinario2)
	#invertirCadena(numBinario1)
	#li $v0, 4
	#la $a0, salto
	#syscall
	#li $v0, 4
	#la $a0, numBinario1
	#syscall
	#li $v0, 4
	#la $a0, salto
	#syscall
	#li $v0, 4
	#la $a0, numBinario2
	#syscall
	#li $v0, 4
	#la $a0, salto
	#syscall
	#li $v0, 4
	#la $a0, resultado
	#syscall
	#invertirCadena(numBinario2)
	#invertirCadena(numBinario1)
	
	#Respaldo de la suma
	li $t9, 0
	loopTamanoResultadoM: 
	lb $t1, resultado($t9)
	beqz $t1, salirTamanoResultadoM
	sb $t1, numBinario2($t9)
	addi $t9, $t9, 1
	bnez $t1, loopTamanoResultadoM 
	salirTamanoResultadoM:
	
subi $s2, $s2, 1
bnez $s2, Multiplicacion
SalirNoPrimeraVez:
	
#li $v0, 4
#la $a0, numBinario1
#syscall
#li $v0, 4
#la $a0, salto
#syscall
#li $v0, 4
#la $a0, numBinario2
#syscall
#li $v0, 4
#la $a0, salto
#syscall
#li $v0, 4
#la $a0, resultado
#syscall
.end_macro


.macro ConvertirBinarioADecimal
#Contando tamaño
li $t0, 0
loopTamanoResultado: 
	lb $t1, resultado($t0)
	beqz $t1, salirTamanoResultado
	addi $t0, $t0, 1
	bnez $t1, loopTamanoResultado 
salirTamanoResultado:
subi $t0, $t0, 1
li $t9, 0
li $t4, 0
li $t2, 1
# usando la "base" como pasarlo a decimal
.eqv tamaResultado $t0
.eqv indiceCBD $t4
.eqv base $t2
.eqv valorDec $t9
.eqv auxCBD $t3
loopCBD:
	lb $t1, resultado(indiceCBD)
	subi $t1, $t1, 0x30
	mul auxCBD, $t1, base
	add valorDec, valorDec, auxCBD
	mul base, base, 2
	addi indiceCBD, indiceCBD, 1
	ble indiceCBD, tamaResultado, loopCBD
salirloppCBD:

.end_macro


.macro ConvertirDecimalARomano
.eqv nume $t9
.eqv indi $t0

#li $v0, 4
#la $a0, mensajeres
#syscall

bnez $t9, ImprimirRomano
#Imprimir NADA
li $v0, 4
la $a0, NADA
syscall 
ImprimirRomano:

loopCBR: # while(num != 0)
       bge nume, 1000, Mayor1000 
        b salirMayor1000
        Mayor1000:
           li $v0, 4
	   la $a0, M
           syscall 
           subi nume, nume, 1000
           j loopCBR
       salirMayor1000:

       bge nume, 900, Mayor900 
        b salirMayor900
        Mayor900:
           li $v0, 4
	   la $a0, CM
           syscall 
           subi nume, nume, 900
           j loopCBR
       salirMayor900:
       
       bge nume, 500, Mayor500 
        b salirMayor500
        Mayor500:
           li $v0, 4
	   la $a0, D
           syscall 
           subi nume, nume, 500
           j loopCBR
       salirMayor500:

       bge nume, 400, Mayor400 
        b salirMayor400
        Mayor400:
           li $v0, 4
	   la $a0, CD
           syscall 
           subi nume, nume, 400
           j loopCBR
       salirMayor400:
      
       bge nume, 100, Mayor100 
        b salirMayor100
        Mayor100:
           li $v0, 4
	   la $a0, C
           syscall 
           subi nume, nume, 100
           j loopCBR
       salirMayor100:
       
       bge nume, 90, Mayor90 
        b salirMayor90
        Mayor90:
           li $v0, 4
	   la $a0, C
           syscall 
           subi nume, nume, 90
           j loopCBR
       salirMayor90:

       bge nume, 50, Mayor50 
        b salirMayor50
        Mayor50:
           li $v0, 4
	   la $a0, L
           syscall 
           subi nume, nume, 50
           j loopCBR
       salirMayor50:

       bge nume, 40, Mayor40 
        b salirMayor40
        Mayor40:
           li $v0, 4
	   la $a0, XL
           syscall 
           subi nume, nume, 40
           j loopCBR
       salirMayor40:

       bge nume, 10, Mayor10 
        b salirMayor10
        Mayor10:
           li $v0, 4
	   la $a0, X
           syscall 
           subi nume, nume, 10
           j loopCBR
       salirMayor10:

       bge nume, 9, Mayor9 
        b salirMayor9
        Mayor9:
           li $v0, 4
	   la $a0, IX
           syscall 
           subi nume, nume, 9
           j loopCBR
       salirMayor9:

       bge nume, 5, Mayor5 
        b salirMayor5
        Mayor5:
           li $v0, 4
	   la $a0, V
           syscall 
           subi nume, nume, 5
           j loopCBR
       salirMayor5:

       bge nume, 4, Mayor4 
        b salirMayor4
        Mayor4:
           li $v0, 4
	   la $a0, IV
           syscall 
           subi nume, nume, 4
           j loopCBR
       salirMayor4:
       
       bge nume, 1, Mayor1 
        b salirMayor1
        Mayor1:
           li $v0, 4
	   la $a0, I
           syscall 
           subi nume, nume, 1
           j loopCBR
       salirMayor1:
       

.end_macro


ImprimirMenu
ObtenerNumerosDelUsuario
RomanoADecimal
DecimalABinario
#invertirCadena (numBinario1)
#invertirCadena (numBinario2)
ObteniendoTamañoVectores
RellenandoVectorMenor
#Dependiendo de la opcion selecciona en el menu se hace algo diferente
li $t0, 0
lb $s6, menu($t0)

beq $s6, 0x31, sumar
b salirSumar
sumar:
SumarBinarios
salirSumar:

beq $s6, 0x32, restar
b salirRestar
restar:
RestaBinarios
salirRestar:

beq $s6, 0x33, multi
b salirMulti
multi:
MultiplicacionBinarios
salirMulti:

ConvertirBinarioADecimal
ConvertirDecimalARomano
