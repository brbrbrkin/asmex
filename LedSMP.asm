;*******************************************************************************
;                                                                              *
;    Microchip licenses this software to you solely for use with Microchip     *
;    products. The software is owned by Microchip and/or its licensors, and is *
;    protected under applicable copyright laws.  All rights reserved.          *
;                                                                              *
;    This software and any accompanying information is for suggestion only.    *
;    It shall not be deemed to modify Microchip?s standard warranty for its    *
;    products.  It is your responsibility to ensure that this software meets   *
;    your requirements.                                                        *
;                                                                              *
;    SOFTWARE IS PROVIDED "AS IS".  MICROCHIP AND ITS LICENSORS EXPRESSLY      *
;    DISCLAIM ANY WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING  *
;    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS    *
;    FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL          *
;    MICROCHIP OR ITS LICENSORS BE LIABLE FOR ANY INCIDENTAL, SPECIAL,         *
;    INDIRECT OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, HARM TO     *
;    YOUR EQUIPMENT, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR    *
;    SERVICES, ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY   *
;    DEFENSE THEREOF), ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER      *
;    SIMILAR COSTS.                                                            *
;                                                                              *
;    To the fullest extend allowed by law, Microchip and its licensors         *
;    liability shall not exceed the amount of fee, if any, that you have paid  *
;    directly to Microchip to use this software.                               *
;                                                                              *
;    MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF    *
;    THESE TERMS.                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Filename: LedSMP                                                                *
;    Date: 15/04/2020                                                                    *
;    File Version: 1.0                                                             *
;    Author: H�rcules Pinheiro                                                                  *
;    Company: SENAI                                                                 *
;    Description: Ativ.                                                             *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Notes: In the MPLAB X Help, refer to the MPASM Assembler documentation    *
;    for information on assembly instructions.                                 *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Known Issues: This template is designed for relocatable code.  As such,   *
;    build errors such as "Directive only allowed when generating an object    *
;    file" will result when the 'Build in Absolute Mode' checkbox is selected  *
;    in the project properties.  Designing code in absolute mode is            *
;    antiquated - use relocatable mode.                                        *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Revision History:                                                         *
;                                                                              *
;*******************************************************************************



;*******************************************************************************
; Processor Inclusion
;
; TODO Step #1 Open the task list under Window > Tasks.  Include your
; device .inc file - e.g. #include <device_name>.inc.  Available
; include files are in C:\Program Files\Microchip\MPLABX\mpasmx
; assuming the default installation path for MPLAB X.  You may manually find
; the appropriate include file for your device here and include it, or
; simply copy the include generated by the configuration bits
; generator (see Step #2).
;
;*******************************************************************************

; TODO INSERT INCLUDE CODE HERE
; PIC16F877A Configuration Bit Settings

; Assembly source line config statements

#include "p16f877a.inc"

;*******************************************************************************
;
; TODO Step #2 - Configuration Word Setup
;
; The 'CONFIG' directive is used to embed the configuration word within the
; .asm file. MPLAB X requires users to embed their configuration words
; into source code.  See the device datasheet for additional information
; on configuration word settings.  Device configuration bits descriptions
; are in C:\Program Files\Microchip\MPLABX\mpasmx\P<device_name>.inc
; (may change depending on your MPLAB X installation directory).
;
; MPLAB X has a feature which generates configuration bits source code.  Go to
; Window > PIC Memory Views > Configuration Bits.  Configure each field as
; needed and select 'Generate Source Code to Output'.  The resulting code which
; appears in the 'Output Window' > 'Config Bits Source' tab may be copied
; below.
;
;*******************************************************************************

; TODO INSERT CONFIG HERE
    


; CONFIG
; __config 0x3F3A
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF



;*******************************************************************************
;
; TODO Step #3 - Variable Definitions
;
; Refer to datasheet for available data memory (RAM) organization assuming
; relocatible code organization (which is an option in project
; properties > mpasm (Global Options)).  Absolute mode generally should
; be used sparingly.
;
; Example of using GPR Uninitialized Data
;
;   GPR_VAR        UDATA
;   MYVAR1         RES        1      ; User variable linker places
;   MYVAR2         RES        1      ; User variable linker places
;   MYVAR3         RES        1      ; User variable linker places
;
;   ; Example of using Access Uninitialized Data Section (when available)
;   ; The variables for the context saving in the device datasheet may need
;   ; memory reserved here.
;   INT_VAR        UDATA_ACS
;   W_TEMP         RES        1      ; w register for context saving (ACCESS)
;   STATUS_TEMP    RES        1      ; status used for context saving
;   BSR_TEMP       RES        1      ; bank select used for ISR context saving
;
;*******************************************************************************

GPR_VAR UDATA
FT1MS RES 1
FT1S RES 1
FT250MS RES 1
FT3		RES	    1	
F EQU  H'0001'
 
; TODO PLACE VARIABLE DEFINITIONS GO HERE
#DEFINE F 1
 
BANCO0 MACRO
   BCF STATUS, RP1
   BCF STATUS, RP0
   ENDM
  
BANCO1 MACRO
   BCF STATUS, RP1
   BSF STATUS, RP0
   
   ENDM
    
BANCO2 MACRO
   BSF STATUS, RP1
   BCF STATUS, RP0
   
   ENDM
    
BANCO3 MACRO
   BSF STATUS, RP1
   BSF STATUS, RP0
   
   ENDM
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

;*******************************************************************************
; TODO Step #4 - Interrupt Service Routines
;
; There are a few different ways to structure interrupt routines in the 8
; bit device families.  On PIC18's the high priority and low priority
; interrupts are located at 0x0008 and 0x0018, respectively.  On PIC16's and
; lower the interrupt is at 0x0004.  Between device families there is subtle
; variation in the both the hardware supporting the ISR (for restoring
; interrupt context) as well as the software used to restore the context
; (without corrupting the STATUS bits).
;
; General formats are shown below in relocatible format.
;
;------------------------------PIC16's and below--------------------------------
;
; ISR       CODE    0x0004           ; interrupt vector location
;
;     <Search the device datasheet for 'context' and copy interrupt
;     context saving code here.  Older devices need context saving code,
;     but newer devices like the 16F#### don't need context saving code.>
;
;     RETFIE
;
;----------------------------------PIC18's--------------------------------------
;
; ISRHV     CODE    0x0008
;     GOTO    HIGH_ISR
; ISRLV     CODE    0x0018
;     GOTO    LOW_ISR
;
; ISRH      CODE                     ; let linker place high ISR routine
; HIGH_ISR
;     <Insert High Priority ISR Here - no SW context saving>
;     RETFIE  FAST
;
; ISRL      CODE                     ; let linker place low ISR routine
; LOW_ISR
;       <Search the device datasheet for 'context' and copy interrupt
;       context saving code here>
;     RETFIE
;
;*******************************************************************************

; TODO INSERT ISR HERE

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START

    ; TODO Step #5 - Insert Your Program Here
    
    
    BANCO1
    CLRF TRISD 
    CLRF TRISB 
 
        
    
    BANCO0
    
MOVLW B'00000000'
MOVWF PORTB

MAIN_LOOP
    MOVLW B'00000111'
    MOVWF PORTD
    CALL GREEN
    MOVLW B'00011000'
    MOVWF PORTD
    CALL YELLOW
    MOVLW B'11100000'
    MOVWF PORTD
    CALL RED
    GOTO MAIN_LOOP
    
GREEN
    MOVLW D'166'
    MOVWF FT1MS
    MOVLW D'250'
    MOVWF FT250MS
    MOVLW D'12'
    MOVWF FT1S

LOOP_GREEN
    DECFSZ FT1MS,1  
    GOTO LOOP_GREEN 

    MOVLW D'165'
    MOVWF FT1MS
    DECFSZ FT250MS,1 ;
    GOTO LOOP_GREEN
    
    MOVLW D'250'        
    MOVWF FT250MS
    DECFSZ FT1S,1 ;
    GOTO LOOP_GREEN ;
    
    RETURN
    
YELLOW
    MOVLW D'166'
    MOVWF FT1MS
    MOVLW D'250'
    MOVWF FT250MS
    MOVLW D'4'
    MOVWF FT1S

LOOP_YELLOW
    DECFSZ FT1MS,1  
    GOTO LOOP_YELLOW 

    MOVLW D'165'
    MOVWF FT1MS
    DECFSZ FT250MS,1 ;
    GOTO LOOP_YELLOW
    
    MOVLW D'250'        
    MOVWF FT250MS
    DECFSZ FT1S,1 ;
    GOTO LOOP_YELLOW ;
    
    RETURN
    
RED
    MOVLW D'166'
    MOVWF FT1MS
    MOVLW D'250'
    MOVWF FT250MS
    MOVLW D'8'
    MOVWF FT1S

LOOP_RED
    DECFSZ FT1MS,1 
    GOTO LOOP_RED 
  
    MOVLW D'165'
    MOVWF FT1MS
    DECFSZ FT250MS,1 ;
    GOTO LOOP_RED
    
    MOVLW D'250'        
    MOVWF FT250MS
    DECFSZ FT1S,1 ;
    GOTO LOOP_RED ;
    
    RETURN
    
DELAY
    MOVLW D'166'
    MOVWF FT1MS
    MOVLW D'250'
    MOVWF FT250MS
    MOVLW D'1'
    MOVWF FT1S
    
    END