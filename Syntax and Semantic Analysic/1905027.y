%{
#include<bits/stdc++.h>

#include "1905027_SymbolInfo.h"
#include "1905027_ScopeTable.h"
#include "1905027_SymbolTable.h"
// #define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;
int error_lineno=-1;

int error_count;

// ofstream cout("1905027_log_smaple.txt");
ofstream errorout("1905027_error.txt");
ofstream parseTree("1905027_ParseTree.txt");
vector<Symbol_Info*> function_parameter_list;
int  parameter_list_line_no;


Symbol_Table symbol_table(11);



void yyerror(char *s)
{
	//write your code
    printf("%s\n",s);
}


void DEFINE_FUNCTION(string func_name,string ret_type,int line,vector<Symbol_Info*> params)
{
	Symbol_Info* syminfo=symbol_table.Lookup(func_name);
	if(syminfo==nullptr)
	{
		symbol_table.Insert(func_name,"FUNCTION");
		syminfo=symbol_table.Lookup(func_name);
	}
	else{

		if(syminfo->get_info_type()=="FUNCTION_DECLARATION")
		{
			if(syminfo->get_return_type()!=ret_type)
			{
				errorout<<"Line# "<<line<<": Conflicting types for \'"<<syminfo->getName()<<"\'\n";
				error_count++;
				return;
			}

			vector<Symbol_Info*> real_param=syminfo->get_Params();
			if(real_param.size()!=params.size())
			{
				errorout<<"Line# "<<line<<": Conflicting types for \'"<<syminfo->getName()<<"\'\n";
				error_count++;
				return;
				
			}
			if(params.size()!=0)
			{
				for(int i=0;i<real_param.size();i++)
				{
					if(real_param[i]->getType()!=params[i]->get_data_type())
					{
						errorout<<"Line# "<<line<<": Type mismatch for argument "<<i+1<<" of \'"<<syminfo->getName()<<"\'\n";
						error_count++;
						return;
					}
				}
			}
		}
		else{
			errorout<<"Line# "<<line<<": \'"<<syminfo->getName()<<"\' redeclared as different kind of symbol\n";
			error_count++;
			return;
		}
	}

	if(syminfo->get_info_type()=="FUNCTION_DEFINITION")
	{
		errorout<<"Line# "<<line<<": Redefinition of function  \'"<<syminfo->getName()<<"\'\n";
		error_count++;
		return;
	}
	syminfo->set_info_type("FUNCTION_DEFINITION");
	syminfo->set_return_type(ret_type);
	syminfo->set_Param(vector<Symbol_Info*>());
	for(int i=0;i<params.size();i++)
	{
		syminfo->add_Param(new Symbol_Info( params[i]->getName(),params[i]->get_data_type()));
	}

}

string StringFromSymbol(vector<Symbol_Info*> temp)
{
	string code_text="";
	for(Symbol_Info* syminfo:temp)
	{
		code_text+=syminfo->get_data_type()+" "+syminfo->getName()+",";
	}
	int n=code_text.length();
	if(!n)
	{
		code_text=code_text.substr(0,n-1);
	}
	return code_text;
}


void FUNCTION_CALL(Symbol_Info* &functionSymbol,vector<Symbol_Info*> arguments,int line)
{
	string func_name=functionSymbol->getName();
	Symbol_Info* syminfo=symbol_table.Lookup(func_name);
	if(syminfo==nullptr)
	{
		errorout<<"Line# "<<line<<": Undeclared function \'"<<func_name<<"\'\n";
		error_count++;
		return;
	}

	if(!syminfo->is_Func())
	{
		errorout<<"Line# "<<line<<": \'"<<func_name<<"\' is not a function\n";
		error_count++;
		return;
	}

	functionSymbol->set_return_type(syminfo->get_return_type());
	if(syminfo->get_info_type()!="FUNCTION_DEFINITION")
	{
		errorout<<"Line# "<<line<<": Undeclared function \'"<<func_name<<"\'\n";
		error_count++;
		return;
	}

	vector<Symbol_Info*> real_params=syminfo->get_Params();
	int param_count=arguments.size();
	if(real_params.size()>param_count)
	{
		// //debug
		// for(int i=0;i<arguments.size();i++)
		// {
		// 	errorout<<"debug  --->  given arguments  "<<arguments[i]->get_data_type()<<"   name   "<<arguments[i]->getName()<<endl;
		// }

		// for(int i=0;i<real_params.size();i++)
		// {
		// 	errorout<<"debug  --->   actual arguments  "<<real_params[i]->getType()<<"   name   "<<real_params[i]->getName()<<endl;
		// }

		errorout<<"Line# "<<line<<": Too few arguments to function \'"<<func_name<<"\'\n";
		error_count++;
		return;
	}
	else if(real_params.size()<param_count){

		// //debug
		// for(int i=0;i<arguments.size();i++)
		// {
		// 	errorout<<"debug  --->  given arguments  "<<arguments[i]->get_data_type()<<"   name   "<<arguments[i]->getName()<<endl;
		// }

		// for(int i=0;i<real_params.size();i++)
		// {
		// 	errorout<<"debug  --->   actual arguments  "<<real_params[i]->getType()<<"   name   "<<real_params[i]->getName()<<endl;
		// }


		errorout<<"Line# "<<line<<": Too many arguments to function \'"<<func_name<<"\'\n";
		error_count++;
		return;
	}
	if(arguments.size()){
	for(int i=0;i<real_params.size();i++)
	{
		if(real_params[i]->getType()!=arguments[i]->get_data_type())
		{
			errorout<<"Line# "<<line<<": Type mismatch for argument "<<to_string(i+1)<<" of \'"<<func_name<<"\'\n";
			error_count++;
			// return;
		}
	}
	}


}

void VOID_FUNC_CHECK(Symbol_Info* i,Symbol_Info* j,int line)
{
	if(i->get_data_type()=="void"||j->get_data_type()=="void")
	{
		errorout<<"Line# "<<line<<": Void cannot be used in expression \n";

		error_count++;
	}
}

string Type_Cast_Auto(Symbol_Info* i,Symbol_Info* j)
{
	if(i->get_data_type()==j->get_data_type())return j->get_data_type();

	if(i->get_data_type()=="float"&&j->get_data_type()=="int")
	{
		j->set_data_type("float");
		return "float";
	}
	else if(i->get_data_type()=="int"&&j->get_data_type()=="float")
	{
		i->set_data_type("float");
		return "float";
	}

	if(i->get_data_type()!="void")return i->get_data_type();
	return j->get_data_type();

}

void DECLARE_FUNCTION_PARAMETER(string name,string data_type,int line=yylineno)
{
	if(data_type=="void")
	{
		errorout<<"Line# "<<line<<": Function parameter can't be void \n";
		error_count++;
	}
	if(symbol_table.Insert(name,"ID"))
	{
		Symbol_Info* syminfo=symbol_table.Lookup(name);
		syminfo->set_data_type(data_type);
		return;
	}
		errorout<<"Line# "<<line<<": Redefinition of parameter \'"<<name<<"\'\n";
		error_count++;

}



void DECLARE_FUNCTION_PARAMETER_LIST(vector<Symbol_Info*> &params,int line=yylineno)
{
	if(params.size()==0)return;
	for(Symbol_Info* syminfo:params)
	{
		DECLARE_FUNCTION_PARAMETER(syminfo->getName(),syminfo->getType(),line);
	}
	params.clear();
}

%}

%union{
    TreeNode* treeNode;
}

%token <treeNode> IF ELSE FOR WHILE DO VOID SWITCH CASE DEFAULT BREAK CONTINUE RETURN MAIN
%token <treeNode> ADDOP INCOP DECOP RELOP LOGICOP ASSIGNOP NOT MULOP BITOP 
%token <treeNode> ID INT FLOAT CONST_INT CONST_FLOAT DOUBLE CONST_CHAR CHAR
%token <treeNode> LTHIRD RTHIRD LCURL RCURL LPAREN RPAREN COMMA SEMICOLON PRINTLN


%type <treeNode> variable factor term unary_expression simple_expression rel_expression logic_expression expression
%type <treeNode> expression_statement statement statements compound_statement
%type <treeNode> type_specifier var_declaration func_declaration func_definition unit program 
%type <treeNode>  declaration_list parameter_list argument_list arguments start





%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
		//write your code in this block in all the similar blocks below

		$$=new TreeNode(nullptr,"start : program");

		$$->is_Terminal = false;

		$$->childlist.push_back($1);

		$$->first_line=$1->first_line;

		$$->last_line=$1->last_line;

		cout<<"start : program "<<endl;

		$$->printchildren(1,parseTree);
		cout<<"Total Lines: "<<yylineno<<endl;
		cout<<"Total Errors: "<<error_count<<endl;
		delete $$;


	}
	;

program : program unit 
	{
		
		$$=new TreeNode(nullptr,"program : program unit");

		$$->is_Terminal = false;

		$$->childlist.push_back($1);
		
		$$->childlist.push_back($2);

		$$->first_line=$1->first_line;

		$$->last_line=$2->last_line;

		cout<<"program : program unit "<<endl;
	}
	| unit
	{
			
		$$=new TreeNode(nullptr,"program : unit");

		$$->is_Terminal = false;

		$$->childlist.push_back($1);

		$$->first_line=$1->first_line;

		$$->last_line=$1->last_line;

		cout<<"program : unit "<<endl;
	}
	;
	
unit : var_declaration
	{
		
		$$=new TreeNode(nullptr,"unit : var_declaration");

		$$->is_Terminal = false;

		$$->childlist.push_back($1);

		$$->first_line=$1->first_line;

		$$->last_line=$1->last_line;

		cout<<"unit : var_declaration  "<<endl;
	}
     | func_declaration
	 	{
		
		$$=new TreeNode(nullptr,"unit : func_declaration");

		$$->is_Terminal = false;

		$$->childlist.push_back($1);

		$$->first_line=$1->first_line;

		$$->last_line=$1->last_line;

		cout<<"unit : func_declaration "<<endl;
	}
     | func_definition
	 	{
		
		$$=new TreeNode(nullptr,"unit : func_definition");

		$$->is_Terminal = false;

		$$->childlist.push_back($1);

		$$->first_line=$1->first_line;

		$$->last_line=$1->last_line;

		cout<<"unit : func_definition  "<<endl;
	}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		{
			
			$$=new TreeNode(nullptr,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			

			$$->first_line=$1->first_line;

			$$->last_line=$6->last_line;

			cout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  "<<endl;
			//change
			// DECLARE_FUNCTION($2->symbol->getName(),$1->symbol->getName(),$4->Nodes_param_list);
			bool inserted=symbol_table.Insert($2->symbol->getName(),"FUNCTION");
			Symbol_Info* temp=symbol_table.Lookup($2->symbol->getName());

			if(inserted)
			{
				temp->set_info_type("FUNCTION_DECLARATION");
				temp->set_return_type($1->symbol->getName());

				for(Symbol_Info* syminfo: $4->Nodes_param_list)
				{
					temp->add_Param(new Symbol_Info(syminfo->getName(),syminfo->get_data_type()));
				}

			}
			else
			{
				if(temp->get_info_type()=="FUNCTION_DECLARATION")
				{
					errorout<<"Line# "<<$$->first_line<<": Redeclaration of function \'"<<$2->symbol->getName()<<"\'\n";
					error_count++;
				}
			}

		
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			
			$$=new TreeNode(nullptr,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			
			

			$$->first_line=$1->first_line;

			$$->last_line=$5->last_line;

			cout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "<<endl;
			//change
			// DECLARE_FUNCTION($2->symbol->getName(),$1->symbol->getName());
			bool inserted=symbol_table.Insert($2->symbol->getName(),"FUNCTION");
			Symbol_Info* temp=symbol_table.Lookup($2->symbol->getName());

			if(inserted)
			{
				temp->set_info_type("FUNCTION_DECLARATION");
				temp->set_return_type($1->symbol->getName());

			}
			else
			{
				if(temp->get_info_type()=="FUNCTION_DECLARATION")
				{
					errorout<<"Line# "<<$$->first_line<<": Redeclaration of function \'"<<$2->symbol->getName()<<"\'\n";
					error_count++;
				}
			}

		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN{DEFINE_FUNCTION($2->symbol->getName(),$1->symbol->getName(),$1->first_line,$4->Nodes_param_list);} compound_statement
		{
			
			$$=new TreeNode(nullptr,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($7);

			$$->first_line=$1->first_line;

			$$->last_line=$7->last_line;

			cout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl;
		}
		| type_specifier ID LPAREN RPAREN{DEFINE_FUNCTION($2->symbol->getName(),$1->symbol->getName(),$1->first_line,vector<Symbol_Info*>());} compound_statement
		{
			
			$$=new TreeNode(nullptr,"func_definition : type_specifier ID LPAREN RPAREN compound_statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($6);

			$$->first_line=$1->first_line;

			$$->last_line=$6->last_line;

			cout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
		}
		| type_specifier ID LPAREN error{if(error_lineno<0)
		{	//errorrecover
			error_lineno=yylineno;
			errorout<<"Line# "<<$3->first_line<<": Syntax error at parameter list of function definition\n";
			error_count++;
			cout<<"Error at line no "<<error_lineno<<" :syntax error\n";
		}
		
		} RPAREN{} compound_statement
		{
			$$=new TreeNode(nullptr,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
			$$->is_Terminal=false;
			TreeNode* errorNode=new TreeNode(nullptr,"parameter_list : error");
			errorNode->is_Terminal=true;
			errorNode->first_line=$3->last_line;
			errorNode->last_line=$6->first_line;
			errorNode->output_text+="\t<Line: "+to_string(error_lineno)+">";
			error_lineno=-1;
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back(errorNode);
			$$->childlist.push_back($6);
			$$->childlist.push_back($8);
			$$->first_line=$1->first_line;
			$$->last_line=$8->last_line;
			cout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n";
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
		{
			
			$$=new TreeNode(nullptr,"parameter_list : parameter_list COMMA type_specifier ID");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);

			$$->first_line=$1->first_line;

			$$->last_line=$4->last_line;

			cout<<"parameter_list  : parameter_list COMMA type_specifier ID"<<endl;
			//change
			$1->Nodes_param_list.push_back(new Symbol_Info($4->symbol->getName(),"",$3->symbol->getName()));
			$$->Nodes_param_list=$1->Nodes_param_list;
			function_parameter_list=$$->Nodes_param_list;
			parameter_list_line_no=$$->first_line;



		}
		| parameter_list COMMA type_specifier
		{
			
			$$=new TreeNode(nullptr,"parameter_list : parameter_list COMMA type_specifier");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"parameter_list : parameter_list COMMA type_specifier "<<endl;

			//change
			$1->Nodes_param_list.push_back(new Symbol_Info($3->symbol->getName(),""));
			$$->Nodes_param_list=$1->Nodes_param_list;
			function_parameter_list=$$->Nodes_param_list;
			parameter_list_line_no=$$->first_line;


		}
 		| type_specifier ID
		{
			
			$$=new TreeNode(nullptr,"parameter_list : type_specifier ID");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);

			$$->first_line=$1->first_line;

			$$->last_line=$2->last_line;

			cout<<"parameter_list  : type_specifier ID"<<endl;

			//change
			$$->Nodes_param_list.push_back(new Symbol_Info($2->symbol->getName(),"",$1->symbol->getName()));
			function_parameter_list=$$->Nodes_param_list;
			parameter_list_line_no=$$->first_line;



		}
		| type_specifier
		{
			
			$$=new TreeNode(nullptr,"parameter_list : type_specifier");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"parameter_list : type_specifier "<<endl;

			//change
			$$->Nodes_param_list.push_back(new Symbol_Info($1->symbol->getName(),"",$1->symbol->getName()));

		}
 		;

 		
compound_statement : LCURL{symbol_table.Enter_Scope();DECLARE_FUNCTION_PARAMETER_LIST(function_parameter_list,parameter_list_line_no);} statements RCURL
		{
			
			$$=new TreeNode(nullptr,"compound_statement : LCURL statements RCURL");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);

			$$->first_line=$1->first_line;

			$$->last_line=$4->last_line;

			cout<<"compound_statement : LCURL statements RCURL  "<<endl;
			//change
			symbol_table.PrintAllScope();
			symbol_table.Exit_Scope();
		}
 		    | LCURL{symbol_table.Enter_Scope();} RCURL
		{
			
			$$=new TreeNode(nullptr,"compound_statement : LCURL RCURL");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"compound_statement : LCURL RCURL "<<endl;
			//change
			symbol_table.PrintAllScope();
			symbol_table.Exit_Scope();
		}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			
			$$=new TreeNode(nullptr,"var_declaration : type_specifier declaration_list SEMICOLON");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"var_declaration : type_specifier declaration_list SEMICOLON  "<<endl;


			//change
			for(Symbol_Info *syminfo: $2->Nodes_param_list)
			{
				if($1->symbol->getName()=="void")
				{
					errorout<<"Line# "<<$2->first_line<<": Variable or field \'"<<syminfo->getName()<<"\' declared void\n";
					error_count++;
					continue;
				}
				bool inserted = symbol_table.Insert(syminfo->getName(),syminfo->getType());
				if(!inserted)
				{
					errorout<<"Line# "<<$2->first_line<<": Conflicting types for\'"<<syminfo->getName()<<"\'\n";
					error_count++;

				}else{
					Symbol_Info* temp=symbol_table.Lookup(syminfo->getName());
					temp->set_data_type($1->symbol->getName());
					if(syminfo->is_array())temp->set_array_length(syminfo->get_array_length());
				}
			}



		}

		| type_specifier error{if(error_lineno<0)
		{
			error_lineno=yylineno;
			cout<<"Error at line no "<<error_lineno<<": syntax error\n";
			errorout<<"Line# "<<error_lineno<<": Syntax error at declaration list of variable declaration"<<endl;
			error_count++;

		}} SEMICOLON
		{	//errorrecover
						
			$$=new TreeNode(nullptr,"var_declaration : type_specifier declaration_list SEMICOLON");

			$$->is_Terminal = false;

			TreeNode* errorNode=new TreeNode(nullptr,"declaration_list : error");
			errorNode->is_Terminal=true;
			errorNode->first_line=errorNode->last_line=error_lineno;
			errorNode->output_text+="\t<Line: "+to_string(error_lineno)+">";

			error_lineno=-1;


			$$->childlist.push_back($1);
			$$->childlist.push_back(errorNode);
			$$->childlist.push_back($4);

			$$->first_line=$1->first_line;

			$$->last_line=$4->last_line;

			cout<<"var_declaration : type_specifier declaration_list SEMICOLON "<<endl;
		}
 		 ;
 		 
type_specifier	: INT
		{
			//change
			Symbol_Info* symbol=new Symbol_Info("int","INT");
			$$=new TreeNode(symbol,"type_specifier : INT");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"type_specifier	: INT "<<endl;
		}
 		| FLOAT
		{
			//change
			Symbol_Info* symbol=new Symbol_Info("float","FLOAT");
			$$=new TreeNode(symbol,"type_specifier : FLOAT");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"type_specifier	: FLOAT "<<endl;
		}
 		| VOID
		{
			//change
			Symbol_Info* symbol=new Symbol_Info("void","VOID");

			$$=new TreeNode(symbol,"type_specifier : VOID");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"type_specifier	: VOID"<<endl;
		}
 		;
 		
declaration_list : declaration_list COMMA ID
		{
			
			$$=new TreeNode(nullptr,"declaration_list : declaration_list COMMA ID");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"declaration_list : declaration_list COMMA ID  "<<endl;

			//change
			$1->Nodes_param_list.push_back($3->symbol);
			$$->Nodes_param_list=$1->Nodes_param_list;

		}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		{
			
			$$=new TreeNode(nullptr,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);

			$$->first_line=$1->first_line;

			$$->last_line=$6->last_line;

			cout<<"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<<endl;
			//change
			$3->symbol->set_array_length($5->symbol->getName());
			$1->Nodes_param_list.push_back($3->symbol);
			$$->Nodes_param_list=$1->Nodes_param_list;
		
		
		}
 		  | ID
		{
			
			$$=new TreeNode(nullptr,"declaration_list : ID");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"declaration_list : ID "<<endl;
			//change

			// $$->Nodes_param_list=new vector<Symbol_Info*>();
			$$->Nodes_param_list.push_back($1->symbol);


		}
 		| ID LTHIRD CONST_INT RTHIRD

		{
			
			$$=new TreeNode(nullptr,"declaration_list : ID LSQUARE CONST_INT RSQUARE");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);

			$$->first_line=$1->first_line;

			$$->last_line=$4->last_line;

			cout<<"declaration_list : ID LSQUARE CONST_INT RSQUARE "<<endl;

			//creating list for the first symbol
			//change
			// $$->Nodes_param_list=new vector<Symbol_Info*>();
			$1->symbol->set_array_length($3->symbol->getName()); 
			$$->Nodes_param_list.push_back($1->symbol);



		}
 		  ;
 		  
statements : statement
		{
			
			$$=new TreeNode(nullptr,"statements : statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"statements : statement  "<<endl;
			//change
		}


	   | statements statement
		{
			
			$$=new TreeNode(nullptr,"statements : statements statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);

			$$->first_line=$1->first_line;

			$$->last_line=$2->last_line;

			cout<<"statements : statements statement  "<<endl;
			//change
		}
	   ;
	   
statement : var_declaration
		{
			
			$$=new TreeNode(nullptr,"statement : var_declaration");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"statement : var_declaration "<<endl;
			//change
		}
	  | expression_statement
	  		{
			
			$$=new TreeNode(nullptr,"statement : expression_statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"statement : expression_statement  "<<endl;
			//change
		}
	  | compound_statement
	  		{
			
			$$=new TreeNode(nullptr,"statement : compound_statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"statement : compound_statement "<<endl;
			//change
		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  		{
			
			$$=new TreeNode(nullptr,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			$$->childlist.push_back($7);

			$$->first_line=$1->first_line;

			$$->last_line=$7->last_line;

			cout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl;
			//change
		}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  		{
			
			$$=new TreeNode(nullptr,"statement : IF LPAREN expression RPAREN statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);

			$$->first_line=$1->first_line;

			$$->last_line=$5->last_line;

			cout<<"statement : IF LPAREN expression RPAREN statement "<<endl;
			//change
		}
	  | IF LPAREN expression RPAREN statement ELSE statement
	  		{
			
			$$=new TreeNode(nullptr,"statement : IF LPAREN expression RPAREN statement ELSE statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			$$->childlist.push_back($7);

			$$->first_line=$1->first_line;

			$$->last_line=$7->last_line;

			cout<<"statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl;
			//change
		}
	  | WHILE LPAREN expression RPAREN statement
	  		{
			
			$$=new TreeNode(nullptr,"statement : WHILE LPAREN expression RPAREN statement");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);

			$$->first_line=$1->first_line;

			$$->last_line=$5->last_line;

			cout<<"statement : WHILE LPAREN expression RPAREN statement "<<endl;
			//change

		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  		{
			
			$$=new TreeNode(nullptr,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);

			$$->first_line=$1->first_line;

			$$->last_line=$5->last_line;

			cout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON  "<<endl;
			//change

			if(!symbol_table.Lookup($3->symbol->getName()))
			{
				errorout<<"Line# "<<$$->first_line<<": Undeclared variable \'"<<$3->symbol->getName()<<"\'\n";
				error_count++;
			}



		}
	  | RETURN expression SEMICOLON
	  		{
			
			$$=new TreeNode(nullptr,"statement : RETURN expression SEMICOLON");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"statement : RETURN expression SEMICOLON"<<endl;
			//change
		}
	  ;
	  
expression_statement : SEMICOLON	
		{
			
			$$=new TreeNode(nullptr,"expression_statement : SEMICOLON");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"expression_statement : SEMICOLON "<<endl;
			//change
		}		
			| expression SEMICOLON 
		{
			
			$$=new TreeNode(nullptr,"expression_statement : expression SEMICOLON");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);

			$$->first_line=$1->first_line;

			$$->last_line=$2->last_line;

			cout<<"expression_statement : expression SEMICOLON \t\t "<<endl;

			//change

		}

		|error {if(error_lineno<0)
		{	//errorrecover
			error_lineno=yylineno;
			// error_lineno=yylineno;
			// cout<<"Error at line no "<<error_lineno<<": syntax error\n";
			errorout<<"Line# "<<error_lineno<<": Syntax error at expression of expression statement"<<endl;
			error_count++;
			cout<<"var_declaration : type_specifier declaration_list SEMICOLON\n";

		}} SEMICOLON
		{
			TreeNode* errorNode=new TreeNode(nullptr,"expression : error");
			errorNode->is_Terminal=true;
			errorNode->first_line=errorNode->last_line=error_lineno;
			errorNode->output_text+="\t<Line: "+to_string(error_lineno)+">";

			error_lineno=-1;
			$$=new TreeNode(nullptr,"expression_statement : expression SEMICOLON");
			
			$$->is_Terminal = false;

			$$->childlist.push_back(errorNode);
			$$->childlist.push_back($3);

			$$->first_line=$3->first_line;

			$$->last_line=$3->last_line;


		}
			;
	  
variable : ID
		{
			
			$$=new TreeNode(nullptr,"variable : ID");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"variable : ID \t "<<endl;
			//change

			Symbol_Info *syminfo=symbol_table.Lookup($1->symbol->getName());
			if(syminfo==nullptr)
			{
				errorout<<"Line# "<<$$->first_line<<": Undeclared variable \'"<<$1->symbol->getName()<<"\'\n";
				error_count++;
				$$->symbol=$1->symbol;
			}
			else
			{
				if(syminfo->is_array())
				{
					// errorout<<"Line# "<<$$->first_line<<": Type mismatch for array \'"<<syminfo->getName()<<"\'\n";
					// error_count++;
				}
				$$->symbol=new Symbol_Info(*syminfo);
			}


		} 		
	 | ID LTHIRD expression RTHIRD
	 		{
			
			$$=new TreeNode(nullptr,"variable : ID LSQUARE expression RSQUARE");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);

			$$->first_line=$1->first_line;

			$$->last_line=$4->last_line;

			cout<<"variable : ID LSQUARE expression RSQUARE  \t "<<endl;

			//change
			Symbol_Info* syminfo=symbol_table.Lookup($1->symbol->getName());
			if(syminfo!=nullptr)
			{
				$1->symbol->set_data_type(syminfo->get_data_type());
				if(!syminfo->is_array())
				{
					errorout<<"Line# "<<$$->first_line<<": \'"<<syminfo->getName()<<"\' is not an array\n";
					error_count++;
				}
				if($3->symbol->get_data_type()!="int")
				{
					errorout<<"Line# "<<$$->first_line<<": Array subscript is not an integer\n";
					error_count++;
				}
			} 
			else
			{
				errorout<<"Line# "<<$$->first_line<<": Undeclared variable \'"<<syminfo->getName()<<"\'\n";
				error_count++;
			}

			$1->symbol->setName($1->symbol->getName()+"["+$3->symbol->getName()+"]");
			$$->symbol=$1->symbol;

		} 
	 ;
	 
 expression : logic_expression
 		{
			
			$$=new TreeNode(nullptr,"expression : logic_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"expression \t: logic_expression\t "<<endl;
			//change
			$$->symbol=$1->symbol;
		}	
	   | variable ASSIGNOP logic_expression
	   		{
			
			$$=new TreeNode(nullptr,"expression : variable ASSIGNOP logic_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"expression \t: variable ASSIGNOP logic_expression \t\t "<<endl;
			//change
			

			string code_text=$1->symbol->getName()+"="+$3->symbol->getName();
			// Symbol_Info* syminfo=symbol_table.Lookup($1->symbol->getName());

			//debug
			// if(syminfo==nullptr)
			// {
			// 	errorout<<"------------->line no : "<<$$->first_line<<"   this should not be null\n";
			// 	errorout<<$1->symbol->getName()<<endl;
			// 	errorout<<$1->symbol->get_data_type()<<endl;
			// 	errorout<<$1->symbol->getType()<<endl;

			// }
			// else
			// {
			// 	errorout<<"-------------> line no : "<<$$->first_line<<"     "<<$3->symbol->getName() <<" logics data type "<<$3->symbol->get_data_type()<<"   and    type"<<$3->symbol->getType()<<endl;
			// }





			


			// if(syminfo!=nullptr)
			// {
			// 	if((syminfo->get_data_type()=="int"&& $3->symbol->get_data_type()=="float")||(syminfo->get_data_type()=="int"&& $3->symbol->getType()=="float"))
			// 	{
			// 		errorout<<"Line# "<<$$->first_line<<": Warning: possible loss of data in assignment of FLOAT to INT\n";
			// 		error_count++;
			// 	}
			// }

			
			
			if($1->symbol->get_data_type()=="int"&& $3->symbol->get_data_type()=="float")
			{
				errorout<<"Line# "<<$$->first_line<<": Warning: possible loss of data in assignment of FLOAT to INT\n";
				error_count++;
			}
			
			if($3->symbol->get_data_type()=="void")
			{
				errorout<<"Line# "<<$$->first_line<<": Void cannot be used in expression \n";
				error_count++;
			}
			$$->symbol=new Symbol_Info(code_text,"expression",$1->symbol->getType());


		} 	
	   ;
			
logic_expression : rel_expression
		{
			
			$$=new TreeNode(nullptr,"logic_expression : rel_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"logic_expression : rel_expression \t "<<endl;
			//change
			$$->symbol=$1->symbol;
		} 	
		 | rel_expression LOGICOP rel_expression
		 		{
			
			$$=new TreeNode(nullptr,"logic_expression : rel_expression LOGICOP rel_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"logic_expression : rel_expression LOGICOP rel_expression \t \t "<<endl;
			//change
			string code_text=$1->symbol->getName()+$2->symbol->getName()+$3->symbol->getName();
			$$->symbol=new Symbol_Info(code_text,"logic_expression","int");




		} 	
		 ;
			
rel_expression	: simple_expression
		{
			
			$$=new TreeNode(nullptr,"rel_expression : simple_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"rel_expression	: simple_expression "<<endl;
			//change
			$$->symbol=$1->symbol;
		} 
		| simple_expression RELOP simple_expression
				{
			
			$$=new TreeNode(nullptr,"rel_expression : simple_expression RELOP simple_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"rel_expression\t: simple_expression RELOP simple_expression	  "<<endl;
			//change
			string code_text=$1->symbol->getName()+$2->symbol->getName()+$3->symbol->getName();
			Type_Cast_Auto($1->symbol,$3->symbol);
			$$->symbol=new Symbol_Info(code_text,"rel_expression","int");


		}	
		;
				
simple_expression : term 
		{
			
			$$=new TreeNode(nullptr,"simple_expression : term");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"simple_expression : term "<<endl;

			//change
			$$->symbol=$1->symbol;

		}
		  | simple_expression ADDOP term
		  		{
			
			$$=new TreeNode(nullptr,"simple_expression : simple_expression ADDOP term");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"simple_expression : simple_expression ADDOP term  "<<endl;
			//change
			
			string code_text=$1->symbol->getName()+$2->symbol->getName()+$3->symbol->getName();
			VOID_FUNC_CHECK($1->symbol,$3->symbol,$$->first_line);
			$$->symbol=new Symbol_Info(code_text,"simple_expression",Type_Cast_Auto($1->symbol,$3->symbol));

		} 
		  ;
					
term :	unary_expression
		{
			
			$$=new TreeNode(nullptr,"term : unary_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"term :	unary_expression "<<endl;
			//change
			$$->symbol=$1->symbol;
		}
     |  term MULOP unary_expression
	 		{
			
			$$=new TreeNode(nullptr,"term : term MULOP unary_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"term :\tterm MULOP unary_expression "<<endl;
			//change
			string code_text=$1->symbol->getName()+$2->symbol->getName()+$3->symbol->getName();
		
			VOID_FUNC_CHECK($1->symbol,$3->symbol,$$->first_line);
			if($2->symbol->getName()=="%")
			{
				if($3->symbol->getName()=="0")
				{
					errorout<<"Line# "<<$$->first_line<<": Warning: division by zero i=0f=1Const=0\n";
					error_count++;
				}

				if($1->symbol->get_data_type()!="int"||$3->symbol->get_data_type()!="int")
				{
					errorout<<"Line# "<<$$->first_line<<": Operands of modulus must be integers \n";
					error_count++;
				}
				$1->symbol->set_data_type("int");
				$3->symbol->set_data_type("int");

			}
			$$->symbol=new Symbol_Info(code_text,"term",Type_Cast_Auto($1->symbol,$3->symbol));


		}
     ;

unary_expression : ADDOP unary_expression
		{
			
			$$=new TreeNode(nullptr,"unary_expression : ADDOP unary_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);

			$$->first_line=$1->first_line;

			$$->last_line=$2->last_line;

			cout<<"unary_expression : ADDOP unary_expression "<<endl;
			//change
			$$->symbol=new Symbol_Info($1->symbol->getName()+$2->symbol->getName(),"unary_ecpression",$2->symbol->get_data_type());




		}  
		 | NOT unary_expression
		 		{
			
			$$=new TreeNode(nullptr,"unary_expression : NOT unary_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			
			$$->childlist.push_back($2);

			$$->first_line=$1->first_line;

			$$->last_line=$2->last_line;

			cout<<"unary_expression : NOT unary_expression "<<endl;
			//change
			$$->symbol=new Symbol_Info("!"+$2->symbol->getName(),"unary_expression",$2->symbol->get_data_type());



		} 
		 | factor
		 		{
			
			$$=new TreeNode(nullptr,"unary_expression : factor");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"unary_expression : factor "<<endl;
			//change none cause factor is unary expression now
			$$->symbol=$1->symbol;

		} 
		 ;
	
factor	: variable
		{
			
			$$=new TreeNode(nullptr,"factor : variable");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"factor	: variable "<<endl;

			//change
			$$->symbol=$1->symbol;
		} 
	| ID LPAREN argument_list RPAREN
			{
			
			$$=new TreeNode(nullptr,"factor : ID LPAREN argument_list RPAREN");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);

			$$->first_line=$1->first_line;

			$$->last_line=$4->last_line;

			cout<<"factor\t: ID LPAREN argument_list RPAREN  "<<endl;
			//change 
			FUNCTION_CALL($1->symbol,$3->Nodes_param_list,$$->first_line);
			string code_text=$1->symbol->getName()+"("+StringFromSymbol($3->Nodes_param_list)+")";
			$$->symbol=new Symbol_Info(code_text,"function",$1->symbol->get_return_type());






		}
	| LPAREN expression RPAREN
			{
			
			$$=new TreeNode(nullptr,"factor : LPAREN expression RPAREN");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"factor\t: LPAREN expression RPAREN   "<<endl;

			//change
			$$->symbol=new Symbol_Info("("+$2->symbol->getName()+")","factor",$2->symbol->get_data_type());


		}
	| CONST_INT 
			{
			
			$$=new TreeNode(nullptr,"factor : CONST_INT");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"factor\t: CONST_INT   "<<endl;
			//change
			$$->symbol=new Symbol_Info($1->symbol->getName(),"factor","int");

		}
	| CONST_FLOAT
			{
			
			$$=new TreeNode(nullptr,"factor : CONST_FLOAT");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"factor\t: CONST_FLOAT   "<<endl;
			//change
			$$->symbol=new Symbol_Info($1->symbol->getName(),"factor","float");

		}
	| variable INCOP
			{
			
			$$=new TreeNode(nullptr,"factor : variable INCOP");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			
			$$->childlist.push_back($2);

			$$->first_line=$1->first_line;

			$$->last_line=$2->last_line;

			cout<<"factor : variable INCOP "<<endl;
			//change
			$$->symbol=new Symbol_Info($1->symbol->getName()+"++","factor",$1->symbol->get_data_type());


		} 
	| variable DECOP
			{
			
			$$=new TreeNode(nullptr,"factor : variable DECOP");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);

			$$->first_line=$1->first_line;

			$$->last_line=$2->last_line;

			cout<<"factor : variable DECOP "<<endl;
			//change
			$$->symbol=new Symbol_Info($1->symbol->getName()+"--","factor",$1->symbol->get_data_type());

		}
	;
	
argument_list : arguments
		{
			
			$$=new TreeNode(nullptr,"argument_list : arguments");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"argument_list : arguments  "<<endl;

			//change
			$$->Nodes_param_list=$1->Nodes_param_list;
		}
			  |
			  		{
			
			// $$=new TreeNode(nullptr,"argument_list :");

			// $$->is_Terminal = false;

			// $$->childlist.push_back($1);

			// $$->first_line=$1->first_line;

			// $$->last_line=$1->last_line;

			// cout<<"argument_list :  "<<endl;
		}
			  ;
	
arguments : arguments COMMA logic_expression
		{
			
			$$=new TreeNode(nullptr,"arguments : arguments COMMA logic_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);

			$$->first_line=$1->first_line;

			$$->last_line=$3->last_line;

			cout<<"arguments : arguments COMMA logic_expression "<<endl;
			//change
			$$->Nodes_param_list=$1->Nodes_param_list;
			$$->Nodes_param_list.push_back($3->symbol);

		}
	      | logic_expression
		  		{
			
			$$=new TreeNode(nullptr,"arguments : logic_expression");

			$$->is_Terminal = false;

			$$->childlist.push_back($1);

			$$->first_line=$1->first_line;

			$$->last_line=$1->last_line;

			cout<<"arguments : logic_expression"<<endl;

			//change
			$$->Nodes_param_list=$1->Nodes_param_list;
			$$->Nodes_param_list.push_back($1->symbol);
		}
	      ;
 

%%
int main(int argc,char *argv[])
{

	// if((fp=fopen(argv[1],"r"))==NULL)
	// {
	// 	printf("Cannot Open Input File.\n");
	// 	exit(1);
	// }

	// fp2= fopen(argv[2],"w");
	// fclose(fp2);
	// fp3= fopen(argv[3],"w");
	// fclose(fp3);
	
	// fp2= fopen(argv[2],"a");
	// fp3= fopen(argv[3],"a");
	

	// yyin=fp;
	// yyparse();
	

	// fclose(fp2);
	// fclose(fp3);

	if(argc != 2){
        cout<<"Please provide input file name and try again. "<<endl;
        return 0;
    }

    FILE *fin=freopen(argv[1],"r",stdin);
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	freopen("1905027_log.txt","w",stdout);

	yyin= fin;
	yylineno=1;
    yyparse();

	fclose(yyin);
	return 0;
}

