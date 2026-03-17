/*** asmFmax.s   ***/

.syntax unified

/* Declare the following to be in data memory */
.data  
.align

/* Define the globals so that the C code can access them */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Kristian Binauhan"  
 
.align

/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global f0,f1,fMax,signBitMax,storedExpMax,realExpMax,mantMax
.type f0,%gnu_unique_object
.type f1,%gnu_unique_object
.type fMax,%gnu_unique_object
.type sbMax,%gnu_unique_object
.type storedExpMax,%gnu_unique_object
.type realExpMax,%gnu_unique_object
.type mantMax,%gnu_unique_object

.global sb0,sb1,storedExp0,storedExp1,realExp0,realExp1,mant0,mant1
.type sb0,%gnu_unique_object
.type sb1,%gnu_unique_object
.type storedExp0,%gnu_unique_object
.type storedExp1,%gnu_unique_object
.type realExp0,%gnu_unique_object
.type realExp1,%gnu_unique_object
.type mant0,%gnu_unique_object
.type mant1,%gnu_unique_object
 
.align
/* use these locations to store f0 values */
f0: .word 0
sb0: .word 0
storedExp0: .word 0  /* the unmodified 8b exp value extracted from the float */
realExp0: .word 0
mant0: .word 0
 
/* use these locations to store f1 values */
f1: .word 0
sb1: .word 0
realExp1: .word 0
storedExp1: .word 0  /* the unmodified 8b exp value extracted from the float */
mant1: .word 0
 
/* use these locations to store fMax values */
fMax: .word 0
sbMax: .word 0
storedExpMax: .word 0
realExpMax: .word 0
mantMax: .word 0

.global nanValue 
.type nanValue,%gnu_unique_object
nanValue: .word 0x7FFFFFFF            

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/********************************************************************
 function name: initVariables
    input:  none
    output: initializes all f0*, f1*, and *Max varibales to 0
********************************************************************/
.global initVariables
 .type initVariables,%function
initVariables:
    /* YOUR initVariables CODE BELOW THIS LINE! Don't forget to follow the calling convention! */
    push {r4-r11, LR}
    
    MOV R4, 0
    
    /* f0* variables */
    LDR R5, =f0
    STR R4, [R5]
    LDR R5, =sb0
    STR R4, [R5]
    LDR R5, =storedExp0
    STR R4, [R5]
    LDR R5, =realExp0
    STR R4, [R5]
    LDR R5, =mant0
    STR R4, [R5]
    
    /* f1* variables */
    LDR R5, =f1
    STR R4, [R5]
    LDR R5, =sb1
    STR R4, [R5]
    LDR R5, =storedExp1
    STR R4, [R5]
    LDR R5, =realExp1
    STR R4, [R5]
    LDR R5, =mant1
    STR R4, [R5]
    
    /* *Max variables */
    LDR R5, =fMax
    STR R4, [R5]
    LDR R5, =sbMax
    STR R4, [R5]
    LDR R5, =storedExpMax
    STR R4, [R5]
    LDR R5, =realExpMax
    STR R4, [R5]
    LDR R5, =mantMax
    STR R4, [R5]
    
    pop {r4-r11, LR}
    
    BX LR
    /* YOUR initVariables CODE ABOVE THIS LINE! Don't forget to follow the calling convention! */

    
/********************************************************************
 function name: getSignBit
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store sign bit (bit 31).
                Store a 1 if the sign bit is negative,
                Store a 0 if the sign bit is positive
                use sb0, sb1, or signBitMax for storage, as needed
    output: [r1]: mem location given by r1 contains the sign bit
********************************************************************/
.global getSignBit
.type getSignBit,%function
getSignBit:
    /* YOUR getSignBit CODE BELOW THIS LINE! Don't forget to follow the calling convention! */
    push {r4-r11, LR}
    
    LDR R0, [R0]
    LSR R0, R0, 31
    STR R0, [R1]
    
    pop {r4-r11, LR}
    
    BX LR
    /* YOUR getSignBit CODE ABOVE THIS LINE! Don't forget to follow the calling convention! */
    

    
/********************************************************************
 function name: getExponent
    input:  r0: address of mem containing 32b float to be unpacked
      
    output: r0: contains the unpacked original STORED exponent bits,
                shifted into the lower 8b of the register. Range 0-255.
            r1: always contains the REAL exponent, equal to r0 - 127.
                It is a signed 32b value. This function does NOT
                check for +/-Inf or +/-0, so r1 ALWAYS contains
                r0 - 127.
                
********************************************************************/
.global getExponent
.type getExponent,%function
getExponent:
    /* YOUR getExponent CODE BELOW THIS LINE! Don't forget to follow the calling convention! */
    push {r4-r11, LR}
    
    LDR R0, [R0]
    LSL R0, R0, 1 /* Remove sign bit */
    LSR R0, R0, 24 /* Isolate stored exponent */
    
    SUB R1, R0, 127 /* Find real exponent, store in R1 (R0 - 127) */
    
    pop {r4-r11, LR}
    
    BX LR
    /* YOUR getExponent CODE ABOVE THIS LINE! Don't forget to follow the calling convention! */
   

    
/********************************************************************
 function name: getMantissa
    input:  r0: address of mem containing 32b float to be unpacked
      
    output: r0: contains the mantissa WITHOUT the implied 1 bit added
                to bit 23. The upper bits must all be set to 0.
            r1: contains the mantissa WITH the implied 1 bit added
                to bit 23. Upper bits are set to 0. 
********************************************************************/
.global getMantissa
.type getMantissa,%function
getMantissa:
    /* YOUR getMantissa CODE BELOW THIS LINE! Don't forget to follow the calling convention! */
    push {r4-r11, LR}
    
    LDR R0, [R0]
    LSL R0, R0, 10
    LSR R0, R0, 10 /* Isolate mantissa without bit 23 */
    
    ORR R1, R0, 0x400000 /* Set bit 23 to 1, store in R1 */
    
    pop {r4-r11, LR}
    
    BX LR
    /* YOUR getMantissa CODE ABOVE THIS LINE! Don't forget to follow the calling convention! */
   


    
/********************************************************************
 function name: asmIsZero
    input:  r0: address of mem containing 32b float to be checked
                for +/- 0
      
    output: r0:  0 if floating point value is NOT +/- 0
                 1 if floating point value is +0
                -1 if floating point value is -0
      
********************************************************************/
.global asmIsZero
.type asmIsZero,%function
asmIsZero:
    /* YOUR asmIsZero CODE BELOW THIS LINE! Don't forget to follow the calling convention! */
    push {r4-r11, LR}
    
    LDR R4, [R0]
    CMP R4, 0
    MOVNE R0, 0 /* Set to 0 if value is not +/- 0 */
    MOVEQ R0, 1 /* Set to 1 if value is +0 */
    CMP R4, 0x80000000
    MOVEQ R0, -1 /* Set to -1 if value is -0 */
    
    pop {r4-r11, LR}
    
    BX LR
    /* YOUR asmIsZero CODE ABOVE THIS LINE! Don't forget to follow the calling convention! */
   


    
/********************************************************************
 function name: asmIsInf
    input:  r0: address of mem containing 32b float to be checked
                for +/- infinity
      
    output: r0:  0 if floating point value is NOT +/- infinity
                 1 if floating point value is +infinity
                -1 if floating point value is -infinity
      
********************************************************************/
.global asmIsInf
.type asmIsInf,%function
asmIsInf:
    /* YOUR asmIsInf CODE BELOW THIS LINE! Don't forget to follow the calling convention! */
    push {r4-r11, LR}
    
    LDR R4, [R0]
    CMP R4, 0x7F800000
    MOVNE R0, 0 /* Set to 0 if not +/- infinity */
    MOVEQ R0, 1 /* Set to 1 if +infinity */
    CMP R4, 0xFF800000
    MOVEQ R0, -1 /* Set to -1 if -infinity */
    
    pop {r4-r11, LR}
    
    BX LR
    /* YOUR asmIsInf CODE ABOVE THIS LINE! Don't forget to follow the calling convention! */
   


    
/********************************************************************
function name: asmFmax
function description:
     max = asmFmax ( f0 , f1 )
     
where:
     f0, f1 are 32b floating point values passed in by the C caller
     max is the ADDRESS of fMax, where the greater of (f0,f1) must be stored
     
     if f0 equals f1, return either one
     notes:
        "greater than" means the most positive number.
        For example, -1 is greater than -200
     
     The function must also unpack the greater number and update the 
     following global variables prior to returning to the caller:
     
     signBitMax: 0 if the larger number is positive, otherwise 1
     realExpMax: The REAL exponent of the max value, adjusted for
                 (i.e. the STORED exponent - (127 o 126), see lab instructions)
                 The value must be a signed 32b number
     mantMax:    The lower 23b unpacked from the larger number.
                 If not +/-INF and not +/- 0, the mantissa MUST ALSO include
                 the implied "1" in bit 23! (So the student's code
                 must make sure to set that bit).
                 All bits above bit 23 must always be set to 0.     

********************************************************************/    
.global asmFmax
.type asmFmax,%function
asmFmax:   

    /* DON'T FORGET TO FOLLOW THE CALLING CONVENTION!  */

    /* YOUR asmFmax CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11, LR}
    
    /* Unpacking f0 */
    LDR R4, =f0
    STR R0, [R4]
    
    /* f0 Sign Bit */
    LDR R0, =f0
    LDR R1, =sb0
    BL getSignBit
    
    /* f0 Exponent */
    LDR R0, =f0
    BL getExponent
    LDR R4, =storedExp0
    STR R0, [R4]
    LDR R4, =realExp0
    CMP R0, 0
    MOVEQ R1, -126
    STR R1, [R4]
    
    /* f0 Mantissa */
    LDR R0, =f0
    BL getMantissa
    LDR R4, =mant0
    LDR R5, =storedExp0
    LDR R5, [R5]
    CMP R5, 0
    STREQ R0, [R4]
    CMP R5, 255
    STREQ R0, [R4] /* If storedExp0 = 0 or 255, bit 23 is NOT set */
    STRNE R1, [R4] /* Otherwise, store with bit 23 set */
    
    /* Unpacking f1 */
    LDR R4, =f1
    STR R1, [R4]
    
    /* f1 Sign Bit */
    LDR R0, =f1
    LDR R1, =sb1
    BL getSignBit
    
    /* f1 Exponent */
    LDR R0, =f1
    BL getExponent
    LDR R4, =storedExp1
    STR R0, [R4]
    LDR R4, =realExp1
    CMP R0, 0
    MOVEQ R1, -126
    STR R1, [R4]
    
    /* f1 Mantissa */
    LDR R0, =f1
    BL getMantissa
    LDR R4, =mant1
    LDR R5, =storedExp1
    LDR R5, [R5]
    CMP R5, 0
    STREQ R0, [R4]
    CMP R5, 255
    STREQ R0, [R4]
    STRNE R1, [R4]
    
    /* Check for +/-infinity in f0 */
    LDR R0, =f0
    BL asmIsInf
    
    /* If f0 is +infinity */
    CMP R0, 1
    BEQ f0_is_larger
    
    /* If f0 is -infinity */
    CMP R0, -1
    BEQ f1_is_larger
    
    /* Check for +/-infinity in f1 */
    LDR R0, =f1
    BL asmIsInf
    
    /* If f1 is +infinity */
    CMP R0, 1
    BEQ f1_is_larger
    
    /* If f1 is -infinity */
    CMP R0, -1
    BEQ f0_is_larger
    
    /* Check sign bits */
    LDR R4, =sb0
    LDR R4, [R4]
    LDR R5, =sb1
    LDR R5, [R5]
    EOR R6, R4, R5 /* Check if matching bits */
    CMP R6, 1 /* 1 = bits are not matching and must find the positive value */
    BEQ find_positive_sign
    
    /* Check realExp */
    LDR R4, =realExp0
    LDR R4, [R4]
    LDR R5, =realExp1
    LDR R5, [R5]
    CMP R4, R5
    BNE find_larger_exp
    
    /* Check mantissa */
    LDR R4, =mant0
    LDR R4, [R4]
    LDR R5, =mant1
    LDR R5, [R5]
    CMP R4, R5
    BNE find_larger_mant
    
    /* Both values are equal */
    BL f0_is_larger
    
find_positive_sign:
    CMP R4, 0 /* 0 = positive */
    BEQ f0_is_larger
    BNE f1_is_larger
    
find_larger_exp:
    CMP R4, R5
    BGT f0_is_larger
    BLT f1_is_larger
    
find_larger_mant:
    CMP R4, R5
    BGT f0_is_larger
    BLT f1_is_larger
    
f0_is_larger:
    /* Set all f0 fields to fMax */
    LDR R4, =f0
    LDR R4, [R4]
    LDR R5, =fMax
    STR R4, [R5]
    LDR R4, =sb0
    LDR R4, [R4]
    LDR R5, =sbMax
    STR R4, [R5]
    LDR R4, =storedExp0
    LDR R4, [R4]
    LDR R5, =storedExpMax
    STR R4, [R5]
    LDR R4, =realExp0
    LDR R4, [R4]
    LDR R5, =realExpMax
    STR R4, [R5]
    LDR R4, =mant0
    LDR R4, [R4]
    LDR R5, =mantMax
    STR R4, [R5]
    
    LDR R0, =fMax
    pop {r4-r11, LR}
    
    BX LR
    
f1_is_larger:
    /* Set all f1 fields to fMax */
    LDR R4, =f1
    LDR R4, [R4]
    LDR R5, =fMax
    STR R4, [R5]
    LDR R4, =sb1
    LDR R4, [R4]
    LDR R5, =sbMax
    STR R4, [R5]
    LDR R4, =storedExp1
    LDR R4, [R4]
    LDR R5, =storedExpMax
    STR R4, [R5]
    LDR R4, =realExp1
    LDR R4, [R4]
    LDR R5, =realExpMax
    STR R4, [R5]
    LDR R4, =mant1
    LDR R4, [R4]
    LDR R5, =mantMax
    STR R4, [R5]
    
    LDR R0, =fMax
    pop {r4-r11, LR}
    
    BX LR
    
    /* YOUR asmFmax CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           



