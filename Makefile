####
# This Makefile can be used to make a scanner for the Simple language
# (Yylex.class) and to make a program that tests the scanner (P2.class).
#
# make clean removes all generated files.
#
###

###
# define the Java compiler and flags
###
##                                                                             
JC = javac
CLASSPATH =  .:../jars/java-cup-11b-runtime.jar
FLAGS = -g -cp $(CLASSPATH)
TEST=	



###
# Here are the rules.
###

P2.class: P2.java Yylex.class sym.class
	$(JC) $(FLAGS) P2.java

Yylex.class: simple.jlex.java Errors.class sym.class
	$(JC) $(FLAGS) simple.jlex.java

simple.jlex.java: simple.jlex
	jflex simple.jlex # use jflex it is more flexible
	mv Yylex.java simple.jlex.java # rename the file produced by jflex

sym.class: sym.java
	$(JC) $(FLAGS) sym.java

Errors.class: Errors.java
	$(JC) $(FLAGS) Errors.java

lexer:	P2.class Manifest
	jar --create --file=simple-lexer.jar --manifest=Manifest *.class
clean:
	rm -f *.class simple.jlex.java  simple-lexer.jar *.zip


test:	test.sim P2.class
	@echo "If you get an error below your Scanner does not work yet!"
	@echo "Modify the simple.jlex specification to implement the language!"
	java -cp $(CLASSPATH) P2 test.sim

# Execute the compiler on a file name on the command line e.g.
# make atest TEST=mytest.sim
atest:	P2.class
	@echo "Running test ${TEST}"
	java -cp $(CLASSPATH) P2 ${TEST}

###
# handout
###

handout:
	zip handout.zip Errors.java Makefile simple.jlex P2.java test.sim test2.sim sym.java eof.sim
###
# submit
###

submit:
	zip submit.zip *.java Makefile simple.jlex test*.sim
