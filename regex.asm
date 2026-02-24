# Niesha McCrory
# Final Project
# (I'm the only person)
.data

#================================
#	Buffers
#===============================
input_buffer:	.space 100
main_buffer:	.space 100
output_buffer:	.space 100
last_letter:	.space 100
first_letter:	.space 100
#=============================
#	Prompts
#===========================

intro: .asciiz "Put in requirements ex. [abc]"
intro2: .asciiz "Put in expression ex. abceabc"
outro: .asciiz "Output"

#==============================
#	Need Expressions
#============================
comma: .asciiz ","


.text

main:

#==================================
# ADDRESSES AND IMMEDIATES
#===============================
la $t0, main_buffer	 # holds the expression
la $t2, input_buffer     # holds the requirments
la $t4, output_buffer	 # holds the output
la $t5, comma
la $t7, last_letter	# holds the last letter of the requirments input
la $t9, first_letter	#holds the first letter of the requirments input

li $s1, 0		#increasing counter (Task1)(ReUSED for Task 7)( Flag for Literal ReUSEd for Task 8)
li $s0, 0		#decreasing counter (Task1)(ReUSED for Task 7)(Flag Division -> \ ReUsed for Task 8)
li $s2, 0		#Flag for Bracket (Task2)
li $s3, 0		#Flag for Asterik (Task3)
li $s4, 0		#Flag for Period (Task 4)
li $s5, 0		#Flag for Dash (Task 6)
li $s6, 0		#Flag for Negation (Task 7) (REUSED for TASK 9 OUTSIDE)
#================================
# USER INPUT
#=================================
la $a0, intro
li $v0, 4
syscall


la $a0, input_buffer
li $a1, 100
li $v0, 8
syscall

la $a0, intro2
li $v0, 4
syscall

la $a0, main_buffer
li $a1, 100
li $v0, 8
syscall
#USER INPUT
#==========================================

#=============================================
# ITERATING FINDING TRIGGERS
#=============================================

Pre_Loop:
lb $t3, 0($t2)			# Loading the requirments and looping 

beq $t3, 10, Found_Flag		# if user input for requiremnts is reach -> Found Flags

beq $t3, 91, BracketF		# Bracket -> [
beq $t3, 93, Last_Letter_Store  # Bracket -> ]
beq $t3, 42, AsterikF		# Asterik -> *
beq $t3, 46, DotF		# Dot -> .
beq $t3, 45, DashF		# Dash -> - (minus sign?)
beq $t3, 92, DivisionF		#Division -> \

addi $t2, $t2, 1
j Pre_Loop

Found_Flag:
la $t2, input_buffer
j Center_Counsel

#=====================================
#   RE-ROUTING WHERE IT GOES DEAR GOD
#===================================
Center_Counsel:

beq $s2, 1, BracketONLY
beq $s4, 1, DotONLY
beq $s3, 1, AsterikONLY
beq $s1, 1, Literal_Check2

j Loop 				# if just letters jump to normal Loop

BracketONLY:

beq $s5, 1, Dash_Check		# if Dash is inside the brackets then recheck for any other triggers
beq $s3, 1, Double_Take		# if Asterik is flagged while Brakcet is flagged go to its storing partner -> [abc]*
j BracketLoop			# if not then go to its regular storing partner -> [abc]

AsterikONLY:
j Simple_Take			# if not go to its regular storing partner ->*a

DotONLY:
beq $s3, 1, Dot_Star		# .*
j DotLoop			# if not go to its regular storing partner -> .

NegationONLY:
addi $s6, $s6, 1		# ^
j NegationLoop

LiteralONLY:
j Literal
Dash_Check:
beq $s6, 1, NegationONLY
beq $s3, 1, Literal_Check1	#if also w asterik we follow the storing partner -> [A-Z]* or [a-z]*
j DashLoop			#if not go to its regular storing partner-> [A-Z] or [a-z]

Literal_Check1:
beq $s0, 1, Literal_Check2 	# Divion sign but checking if it has a dot
j Dash_Asterik

Literal_Check2:
beq $s4, 1, Literal_Loop		# Checking if it has a dot -> 
j Literal			# If not -> Regular Loop


#==========================================
#	Iterating
#========================================
Loop:


lb $t1, 0($t0)
lb $t3, 0($t2)

# The null terminator equals the value 10


beq $t3, 10, Found 	# if user input for requiremnts is reach -> Found
beq $t1, 10, Output	# if reached end of expression string -> reset


blt $t3, 97, Skip      		#if < 'a'
bgt $t3, 122, Skip		# if > 'z'


#if it makes it pass here it is a letter
Alphabet:

beq $t1, $t3, Index	#comparing if its a match: t1 = t3? if so.. ->Index
bne $t1, $t3, Nomatch	#if not.. -> Nomatch

Skip:
addi $t0, $t0, 1
j Loop

Index:
addi $s0, $s0, 1	#increment high counter by 1
addi $t0, $t0, 1	#increment main buffer to next char
addi $t2, $t2, 1	# increment input buffer to next char
j Loop

Nomatch:
li $s0, 0	       #resets the index
la $t2, input_buffer   #resets requirement buffer
addi $t0, $t0, 1       #moves the expression along
j Loop

#==============================
#	FOUND & STORING
#===============================
Found:
sub $t0, $t0, $s0	#indexing backwards to orginal found expression

Store:
beq $s1, $s0, Tiny_Reset	#Seperate Reset
lb $t1 0($t0)
sb $t1, 0($t4)	  # storing the char from the main_buffer into the output
addi $t4, $t4, 1  # making space
addi $t0, $t0, 1
addi $s1, $s1, 1
j Store

#=================================
# RESETING AFTER STORING
#==============================
Tiny_Reset:
li $s0, 0
li $s1, 0
lb $t6, 0($t5)		# Loading in comma
sb $t6, 0($t4)		#storing a comma after the letter
addi $t4, $t4, 1
la $t2, input_buffer
j Loop

#====================================
# TASK 1 ALPHABET
#========================================
Output:
sb $zero, 0($t4)
la $a0, output_buffer
li $v0, 4
syscall
j END_PROGRAM


#================================
#	TASK 2 BRACKET
#===============================
BracketF:
addi $s2, $s2, 1
addi $t2, $t2, 1

lb $t3, 0($t2)
beq $t3, 94, NegateF	# Negation -> ^
sb $t3, 0($t9)		# Storing the last byte into First Letter buffer

j Pre_Loop

skipORNegate:
addi $t2, $t2, 1
j Pre_Loop

BracketLoop:
lb $t1, 0($t0)
lb $t3, 0($t2)

# The null terminator equals the value 10

beq $t3, 93, BReset        # If ']' is found, reset
beq $t3, 10, BReset	# if user input for requiremnts is reach -> Found
beq $t1, 10, Output	# if reached end of expression string -> reset


blt $t1, 97,  Nomatch	 #if < 'a'
bgt $t1, 122, Nomatch	# if > 'z'

#Made it through here it is an actual alphabet


Alphabet2:
beq $t1, $t3, StoringB	#comparing if its a match: t1 = t3? if so.. ->Storing
bne $t1, $t3, NomatchB	#if not.. -> Nomatch

StoringB:

lb $t6, 0($t5)		# Loading in comma
sb $t1, 0($t4)		# storing the matching char into output
addi $t4, $t4, 1 	# Moving to the next space
sb $t6, 0($t4)		#storing a comma after the letter
addi $t4, $t4, 1

addi $t0, $t0, 1	#moving to the next iteration of the expression buffer
j BracketLoop


NomatchB:
addi $t2, $t2, 1
j BracketLoop

BReset: 
li $s2, 0              # clear bracket mode
la $t2, input_buffer   # reset requirement pointer
addi $t0, $t0, 1       # advance main buffer
j BracketLoop                 # return to Bracket loop


#===========================================
#	TASK 3 ASTREIKS
#==========================================
AsterikF:
addi $s3, $s3, 1 		# Activates Asterik Flag -> 1
addi $t2, $t2, 1
j Pre_Loop

Last_Letter_Store:
addi $t2, $t2, -1	# Going back one char and grabbing the very last letter
lb $t3, 0($t2)
sb $t3, 0($t7)		# Storing the last byte into Last_Letter buffer

addi $t2, $t2, 2
j Pre_Loop


Double_Take:
#====================================
#	Requiremnts: [abc]*
#==================================
lb $t1, 0($t0)
lb $t3, 0($t2)
lb $t8, 0($t7)	# Last Letter
# The null terminator equals the value 10

beq $t3, 93, DReset        # If ']' is found, reset
beq $t1, $t8, CommaD
beq $t1, 10, Output	# if reached end of expression string -> reset


blt $t1, 97,  NomatchD	 #if < 'a'
bgt $t1, 122, NomatchD	# if > 'z'

#Made it through here it is an actual alphabet


Alphabet3:
beq $t1, $t3, StoringD	#comparing if its a match: t1 = t3? if so.. ->Storing
bne $t1, $t3, NomatchD	#if not.. -> Nomatch

StoringD:

sb $t1, 0($t4)		# storing the matching char into output
addi $t4, $t4, 1 	# Moving to the next space
addi $t0, $t0, 1	#moving to the next iteration of the expression buffer
j Double_Take


NomatchD:

addi $t2, $t2, 1
j Double_Take

CommaD:
sb $t1, 0($t4)		# storing the matching char into output
addi $t4, $t4, 1 	# Moving to the next space
lb $t6, 0($t5)
sb $t6, 0($t4)
addi $t4, $t4, 1

DReset: 
li $s2, 0              # clear bracket mode
li $s3, 0 
la $t2, input_buffer   # reset requirement pointer
addi $t0, $t0, 1       # advance main buffer
j Double_Take                # return to Bracket loop

Simple_Take:
# Will complete later

#=============================================
#	TASK 4 THE DOT
#=============================================
DotF:
addi $s4, $s4, 1
addi $t2, $t2, 1
j Pre_Loop

DotLoop:
# Printing Everything w commas
lb $t1, 0($t0)

beq $t1, 10, Output


lb $t6, 0($t5)		# Loading in comma
sb $t1, 0($t4)		# storing the matching char into output
addi $t4, $t4, 1 	# Moving to the next space
sb $t6, 0($t4)		#storing a comma after the letter
addi $t4, $t4, 1

addi $t0, $t0, 1	#moving to the next iteration of the expression buffer
j DotLoop

#====================================== i'm entering the flow state
#	Task 5 Dot+Asterik
#=========================================
Dot_Star:

lb $t1, 0($t0)

beq $t1, 10, Output

sb $t1, 0($t4)		# storing the matching char into output
addi $t4, $t4, 1 	# Moving to the next space

addi $t0, $t0, 1	#moving to the next iteration of the expression buffer
j Dot_Star

#===============================================
#	Task 6 Dash + UpperCase 
#=============================================
DashF:
addi $s5, $s5, 1 		# Activates Dash Flag -> 1
addi $t2, $t2, 1
j Pre_Loop

DashLoop:
# Coding Later

Dash_Asterik:
beq $s6, 1, Negation_Star

lb $t1, 0($t0)

lb $s7, 0($t9)	# First Letter
lb $t8, 0($t7)	# Last letter

# The null terminator equals the value 10

beq $t1, 10, Output	# if user input for expression is reach -> Found

blt $t1, $s7,  NomatchDash	 #if < 'a'
bgt $t1, $t8, NomatchDash	# if > 'z'

# Made it through here it is in the dash requirments
		
StoringDash:

lb $t6, 0($t5)		# Loading in comma
sb $t1, 0($t4)		# storing the matching char into output
addi $t4, $t4, 1 	# Moving to the next space
sb $t6, 0($t4)		#storing a comma after the letter
addi $t4, $t4, 1

addi $t0, $t0, 1	#moving to the next iteration of the expression buffer
j Dash_Asterik


NomatchDash:
addi $t0, $t0, 1
j Dash_Asterik

#==========================================
#	Task 7 Negation
#========================================
NegateF:
addi $s6, $s6, 1
addi $t2, $t2, 1

lb $t3, 0($t2)
sb $t3, 0($t9)		#Storing the first letter if negate is there
j Pre_Loop

NegationLoop: 
# Added On

Negation_Star:
lb $t1, 0($t0)

lb $s7, 0($t9)	# First Letter
lb $t8, 0($t7)	# Last letter

beq $t1, 10, Output	# if user input for expression is reach -> Found

blt $t1, $s7,  MatchN	 #if < 'a'
bgt $t1, $t8, MatchN	# if > 'z'

# If it made it down here its Nomatch

NomatchN:
addi $s1, $s1, 1     
bgt $s0, 0, Store_CommaN   #storing comma 
addi $t0, $t0, 1
j Negation_Star

Store_CommaN:
li $s1, 0	#Resetting the Counters for Nomatch
li $s0, 0	#Resetting the Counters for Match
lb $t6, 0($t5)
sb $t6, 0($t4)
addi $t4, $t4, 1
j Negation_Star

MatchN:
addi $s0, $s0, 1
sb $t1, 0($t4)		# storing the matching char into output
addi $t4, $t4, 1 	# Moving to the next space
addi $t0, $t0, 1	#moving to the next iteration of the expression buffer
j Negation_Star

#===================================
#	Task 8 Division
#==================================
DivisionF:
addi $s0, $s0, 1
addi $t2, $t2, 1
j Pre_Loop

#=====================================================================================
#	WHOLE FUNCTION IS TO MOVE THE INPUT BUFFER TO THE ACTUAL START OF THE LITERAL
# 	I DON'T WANT TO USE ANY MORE REGISTERS DUDE D:
#=====================================================================================
Literal_Loop:

lb $t3, 0($t2)			# Loading in the requirements buffer

beq $t3, 64, Literal		# if it equals an @ in the requirment buffer @
beq $t3, 92, Literal_check	# seeing if the loaded char is a -> \

addi $t2, $t2, 1		# incrementing
j Literal_Loop

Literal_check:
addi $t2, $t2, 1		# incrementing again to get to '.'

j Literal


#Starting the loop
Literal:
lb $t1, 0($t0)	# expression buffer
lb $t3, 0($t2)  #input buffer
lb $s7, 0($t9)	# First Letter
lb $t8, 0($t7)	# Last letter

beq $t1, 10, Backspace_Literal		# if the expression buffer reaches the end then we go and store the actual expression
blt $t1, $s7, NomatchLiteral	 #if < 'a' # First letter
bgt $t1, $t8, NomatchLiteral	# if > 'z' # Last Letter

# If it gets past here it is a Match Literal

Match_Literal: 
addi $s1, $s1, 1
addi $t0, $t0, 1
j Literal


NomatchLiteral:	
beq $t1, 64, Match_checker
beq $t1, 46, Match_Literal
li $s1, 0	# reloading back to 0 when we get to the @ sign...
addi $t0, $t0, 1      # move to next character in main buffer
j Literal

Backspace_Literal:
sub $t0, $t0, $s1	# Going to reverse back the matching chars we required in the expression buffer
# nothing down here because this will not be a part of the Loop to Store
j Storing_Literal

Storing_Literal:
lb $t1, 0($t0)		# Now reload the expression to get the char to start on which should be
lb $t3, 0($t2)

beq $t3, 10, Output	# We are now relying on the input buffer to reach the null terminator instead of the expression.
beq $t3, 92, Skip_Literal	# Encountering a \
beq $t1, $t3, StoringACE	# if we are now matching up together with the requirements and expression

sb $t1, 0($t4)		# Store the byte of t1 (expression) into the output buffer
addi $t4, $t4, 1	# Giving room to the output buffer
addi $t0, $t0, 1 	# incrementing expression buffer 
j Storing_Literal

StoringACE:

sb $t1, 0($t4)		# Store the byte into te output buffer
addi $t4, $t4, 1	# Making space for the output buffer
addi $t2, $t2, 1	# incrementing the requirment buffer
addi $t0, $t0, 1	# Incrementing the expression buffer
j Storing_Literal

Skip_Literal:
addi $t2, $t2, 1
j Storing_Literal

#=============================================
#	Task 9 OUTSIDE ALPHABETS
#=============================================
#Checking it differently because we recognized it as a full fledge email!

Match_checker:
beq $t3, 64, Match_Literal

#if it makes it passed here t3 isn't equal to the -> @
NoMatchyyyy:
li $s1, 0	# reloading back to 0 when we get to the @ sign...
addi $t0, $t0, 1      # move to next character in main buffer
j Literal
#===========================================
#	END OF PROGRAM
#============================================
END_PROGRAM:
li $v0, 10
syscall
