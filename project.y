
%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <map>
	#include <vector>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
	extern int linenum;
	int tab_count = 0;

	//for types and variable names
	map<string,int> var_map;
	vector<string> vars;
	vector<int> types;

	//for tab inconsistency
	vector<int> tab_type;
	vector<int> tab_num;
	bool start = true;
	int current_ident = 0;

	//for if else consistency
	vector<int> ifelifelse;
	vector<int> ifelifelse_tab;
	vector<int> ifelifelse_num;

	//for {}
	vector<bool> opencond;

%}

%union
{
	struct pythontocpp{
		int type;
		char* var_name;

	};
	pythontocpp pythontocpp_type;

	int number;
	char * str;
	
}

%token<str> OPERATOR IF ELIF ELSE COMPR EQ COLON TAB OP CP OCB CCB STRING VARNAME FLOAT INTEGER
%left OPERATOR COMPARISON
%type<pythontocpp_type> operand oplist statement
%type<str> assign conditions tocpp if_statement elif_statement else_statement statements compare


%%
tocpp:
	statements{

		



		//TAB SEMANTIC
		for (int a = 0; a< tab_type.size(); a++){

			//cout<< "Tab type: " << tab_type[a] << endl;
			//cout<< "Tab count: " << tab_num[a] << endl;
			//cout << current_ident<< endl;

			// start case
			if(start){
				start = false;
				if(tab_num[a] != 0) { cout<< "tab inconsistency in line " << a+1 << endl; return 0;}				
			}

			else if(tab_type[a-1] == 5 && tab_num[a] <= tab_num[a-1] ){
				current_ident = tab_num[a];
				cout << "error in line " << a+1<< ": at least one line should be inside if/elif/else block " << endl;
				return 0;

			}

			else if ((tab_type[a] == 4) && (tab_num[a] != current_ident) && tab_num[a-1]==current_ident) {
    				if (tab_num[a] < current_ident) {
        				current_ident = tab_num[a];
    				} 
				else {
        				cout<< "tab inconsistency in line " << a+1 << endl; return 0;
    				}
    				continue;
			}

			
			else if ((tab_type[a] == 5) && (tab_num[a] != current_ident) && tab_num[a-1]==current_ident) {
    				if (tab_num[a] > current_ident) {
        				current_ident = tab_num[a];
    				} 
				else {
        				current_ident = tab_num[a] + 1;
    				}
    				continue;
			}

			if(tab_type[a] == 5) current_ident++;

			else if((tab_type[a] == 4 || tab_type[a] == 5) && (tab_num[a]!= current_ident) && tab_num[a-1]!=current_ident) {
				cout<< "tab inconsistency in line " << a+1 << endl;
				return 0;
			}
										
			
		}

		//IF ELSE CONTROL
    	int a = ifelifelse.size() - 1;
		bool control = false;

    	while (a > 0) {
        	if (ifelifelse[a] == 2 && ifelifelse_tab[a] == ifelifelse_tab[a - 1] && ifelifelse[a - 1] == 3 ) {
            		cout << "elif after else in line " << ifelifelse_num[a] << endl;
            		return 0;
        	}
			else if(ifelifelse[0] == 2){
				cout << "elif without if in line " << ifelifelse_num[0] << endl;
				return 0;
			}

			else if(ifelifelse[0] == 3){
				cout << "else without if in line " << ifelifelse_num[0] << endl;
				return 0;
			}
			else if (ifelifelse[a] == 3) {
            		int b = a - 1;
            		while (b > 0) {
                		if ( (ifelifelse_tab[a] == ifelifelse_tab[b]) && (ifelifelse[b] == 1 || ifelifelse[b] == 2) ) {
                   		control = true;
                		}
                	--b;
					}	

					if (control == false) {
                		cout << "else without if in line " << ifelifelse_num[a] << endl;
                		return 0;
					}
        	}

        	--a;
    	}	


		//MAIN
		cout << "void main()\n{" << endl;

		// INT FLOAT STR C++ CONVERSION
		vector<string> varsOfTypeFloat;
		vector<string> varsOfTypeInt;
		vector<string> varsOfTypeString;

		for (int i = 0; i < vars.size(); ++i) {
    
    		if (types[i] == 1) {
        		if (find(varsOfTypeFloat.begin(), varsOfTypeFloat.end(), vars[i]) != varsOfTypeFloat.end()) {
          		} 
				else {
            			varsOfTypeFloat.push_back(vars[i]);
        		}
    		} 
			else if (types[i] == 2) {
        		if (find(varsOfTypeInt.begin(), varsOfTypeInt.end(), vars[i]) != varsOfTypeInt.end()) {
				} 
				else {
            			varsOfTypeInt.push_back(vars[i]);
        		}
    		} 
			else {
        		if (find(varsOfTypeString.begin(), varsOfTypeString.end(), vars[i]) != varsOfTypeString.end()) {
        		} 
				else {
            			varsOfTypeString.push_back(vars[i]);
       			 }
   			}
		}	

		if (!varsOfTypeInt.empty()) {
    			cout << "\tint ";
    			for (int i = 0; i < varsOfTypeInt.size(); ++i) {
        			cout << varsOfTypeInt[i];
        			if (i < varsOfTypeInt.size() - 1) {
            				cout << ",";
        			}
    			}
    			cout << ";" << endl;
		}


		if (!varsOfTypeFloat.empty()) {
    			cout << "\tfloat ";
    			for (int i = 0; i < varsOfTypeFloat.size(); ++i) {
        			cout << varsOfTypeFloat[i];
        			if (i < varsOfTypeFloat.size() - 1) {
            				cout << ",";
        			}
    			}
    			cout << ";" << endl;
		}


		if (!varsOfTypeString.empty()) {
    			cout << "\tstring ";
    			for (int i = 0; i < varsOfTypeString.size(); ++i) {
        			cout << varsOfTypeString[i];
        			if (i < varsOfTypeString.size() - 1) {
            				cout << ",";
        			}
    			}
    			cout << ";" << endl;
		}

		cout << "\n";

		//PRINT
		string m = string($1);
 		cout << "\t";
		for(int x =0; m[x] != '\0'; x++) {
    		 if (m[x] != '\n') {
				cout << m[x]; }
			else cout << "\n\t";
		}

		//FOR } AT THE END
		int counter = 0;
		vector<int> end;

		for(int i=tab_type.size(); i>0; i-- ){
			if((tab_type[i]==5)&&(opencond[i]==true)){
				opencond[i]= 0;
				end.push_back(tab_num[i]);
				counter++;	
			}	
		}

		string combinedResult = "";
		int i = 0;

		while (i < counter) {
			combinedResult += "\n";
			int j = 0;
			while (j < end[i]+1) {
				combinedResult = combinedResult + "\t";
				++j;
			}
			combinedResult += "}\n";
			++i;
		}
		cout << combinedResult << endl;

		cout << "}" << endl;

	}
	;

statements:
	statement{
		$$ = strdup($1.var_name);
        }
	|
	statement statements{
		$$ = strdup((string($1.var_name) + "\n" + string($2) ).c_str());
	}
	;

statement:
	assign{
		//FOR {}
		int counter = 0;
		bool finished = false;
		vector<int> end;

		for(int i=tab_type.size(); i>0; i-- ){
			if((tab_type[i]==5)&& (tab_num[i] >= tab_count)&&(opencond[i])){
				opencond[i]= 0;
				end.push_back(tab_num[i]);
				counter++;
				finished = true;	
			}
			
		}

		if (!finished) {
			$$.var_name = strdup($1);
		
		}
		else {
			string combinedResult = "";
			int i = 0;
			while (i < counter) {
				int m = end[i];
				while (m > 0) {
				combinedResult += "\t";
				 --m;
				}
				combinedResult += "}\n";
				++i;
			}

			$$.var_name = strdup((combinedResult + string($1)).c_str());
		}


		$$.type = 4; 
		tab_num.push_back(tab_count);
		opencond.push_back(false);
		tab_count = 0; 
	}
	|
	conditions{
		//FOR {}
		int counter = 0;
		bool finished = false;
		vector<int> end;

		for(int i=tab_type.size(); i>0; i-- ){
			if((tab_type[i]==5)&& (tab_num[i] >= tab_count)&&(opencond[i]==true)){
				opencond[i]= 0;
				end.push_back(tab_num[i]);
				counter++;
				finished = true;
				
			}	
		}

		string combinedResult = "";
		int i = 0;
		while (i < counter) {
			int j = end[i];
			while (j > 0) {
				combinedResult = combinedResult + "\t";
				--j;
			}
			combinedResult += "}\n";
			++i;
		}
		
		if(!finished) combinedResult = "";
		string result = combinedResult +  string($1) + "\n";
		
		int n = 0;
		while (n < tab_count) {
			result = result + "\t";
			++n;
		}
		result = result + "{";

		$$.var_name = strdup(result.c_str());
		$$.type = 5;
		tab_num.push_back(tab_count);
		opencond.push_back(true);
		ifelifelse_tab.push_back(tab_count);
		ifelifelse_num.push_back(linenum);
		tab_count = 0;

	}
	;

assign:
	VARNAME EQ oplist{
		var_map[$1] = $3.type;
		
		if(var_map[$1] == 1){
			$$ = strdup((string($1) + "_" + "flt" + " = " + string($3.var_name) + ";").c_str());	
		}
		else if(var_map[$1] == 2){
			$$ = strdup((string($1) + "_" + "int" + " = " + string($3.var_name)+ ";").c_str());	
		}
		else if(var_map[$1] == 3){
			$$ = strdup((string($1) + "_" + "str" + " = " + string($3.var_name) + ";").c_str());	
		}

		bool found = false;

		for (size_t i = 0; i < vars.size(); ++i) {
    			if (vars[i] == $1) {
        		found = true;
        		break;
    		}
		}
		string op;
		if (found) {
			//empty
		} 
		else {
			if(var_map[$1] == 1){
			op = string($1) + "_" + "flt";	
		}
		else if(var_map[$1] == 2){
			op = string($1) + "_" + "int";	
		}
		else if(var_map[$1] == 3){
			op = string($1) + "_" + "str";	
		}
    			vars.push_back(strdup(op.c_str()));

		}

		types.push_back($3.type); 
		tab_type.push_back(4);
	}
	|
	TAB assign{
		tab_count = 0;
		int i = 0;
		string temp = string($1);
		while (i < temp.size()) {
    			if (temp[i] == '\t') {
       				 tab_count++;
    			} 
			else if (temp[i] == ' ') {
        			tab_count += 6;
        			i += 6; 
    			} 
			else {
       				 break; 
    		}
    		i++;
		}

		//cout << tab_count << endl;
		$$ = strdup((temp + string($2)).c_str());


	}
	;
	

oplist:
	oplist OPERATOR oplist{

		if($1.type == $3.type){
			$$.type = $3.type;
		}
		else if(($1.type == 1 && $3.type == 2) || ($1.type == 2 && $3.type == 1)){
			$$.type = 1;
		}
		else {
			cout << "type mismatch in line " << linenum << endl;
			return 0;
		}

		string operation = string($1.var_name)+ " " +string($2)+ " " +string($3.var_name);
		$$.var_name = strdup(operation.c_str());

	}
	|
	operand{
		$$.type = $1.type;
		$$.var_name = strdup(string($1.var_name).c_str());
	}
	;



conditions:
	if_statement{
		$$ = strdup($1);
		ifelifelse.push_back(1);
	}
	|
	elif_statement{
		$$ = strdup($1);
		ifelifelse.push_back(2);
	}
	|
	else_statement{
		$$ = strdup($1);
		ifelifelse.push_back(3);
	}
	;

if_statement:
	IF compare COLON {

            $$ = strdup(("if( " + string($2) + " )").c_str());
			tab_type.push_back(5);

	}
	|
	TAB if_statement{
		tab_count = 0;
		int i = 0;
		string temp = string($1);
		while (i < temp.size()) {
    			if (temp[i] == '\t') {
       				 tab_count++;
    			} 
			else if (temp[i] == ' ') {
        			tab_count += 6;
        			i += 6; 
    			} 
			else {
       				 break; 
    		}
    		i++;
		}

		//cout << tab_count << endl;
		$$ = strdup((temp + string($2)).c_str());

	}
	;

elif_statement:
	ELIF compare COLON {
		$$ = strdup(("else if ( " + string($2) + " )").c_str());
		tab_type.push_back(5);
	}
	|
	TAB elif_statement{
		tab_count = 0;
		int i = 0;
		string temp = string($1);
		while (i < temp.size()) {
    			if (temp[i] == '\t') {
       				 tab_count++;
    			} 
			else if (temp[i] == ' ') {
        			tab_count += 6;
        			i += 6; 
    			} 
			else {
       				 break; 
    		}
    		i++;
		}

		//cout << tab_count << endl;
		$$ = strdup((temp + string($2)).c_str());

	}	
	;

compare:
	operand COMPR operand{
		
			if(($1.type== 1&& $3.type==3)||($1.type==3 && $3.type==1)||($1.type==2 && $3.type==3)||($1.type==3 && $3.type==2) )
			{
				cout <<"comparison type mismatch in line " << linenum << endl; return 0;
			}
			$$ = strdup(( string($1.var_name) + " " + string($2) + " " + string($3.var_name)).c_str());
	}
	;

else_statement:
	ELSE COLON {
		
		$$ = strdup(string("else").c_str());
		tab_type.push_back(5);
	}
	|
	TAB else_statement{
		string result = string($1);
		tab_count = 0;
		int i = 0;
		while (i < result.size()) {
    			if (result[i] == '\t') {
       				 tab_count++;
    			} 
			else if (result[i] == ' ') {
        			tab_count += 6;
        			i += 6; 
    			} 
			else {
       				 break; 
    		}
    		i++;
		}

		//cout << tab_count << endl;
		$$ = strdup((result + string($2)).c_str());
	}
	;


operand:
	VARNAME{
		$$.type = var_map[$1]; 
		if(var_map[$1] == 1){
			$$.var_name = strdup((string($1) + "_" + "flt").c_str());	
		}
		else if(var_map[$1] == 2){
			$$.var_name = strdup((string($1) + "_" + "int").c_str());	
		}
		else if(var_map[$1] == 3){
			$$.var_name = strdup((string($1) + "_" + "str").c_str());	
		}
	}
	|
	FLOAT{
		$$.type = 1;
		$$.var_name = strdup(string($1).c_str());
	}
	|
	INTEGER{
		$$.type = 2;
		$$.var_name = strdup(string($1).c_str());
	}
	|
	STRING{
		$$.type = 3;
		$$.var_name = strdup(string($1).c_str());
	}
	;


%%
void yyerror(string s){
	cerr<<"Error at line: "<<linenum<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}
