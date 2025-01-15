%option noyywrap yylineno

%x STRING_STATE
%x SINGLE_LINE_COMMENT_STATE
%x MULTILINE_COMMENT_STATE



%{

#include<bits/stdc++.h>
#include "1905027_SymbolInfo.h"
#include "1905027_ScopeTable.h"
#include "1905027_SymbolTable.h"
#include "y.tab.h"

using namespace std;

int line_count=1;
int lexeme_start_line=0; 
int errors=0;
string current_lexeme;
string str_token;
bool single_line_string=true;

// extern ofstream logout;

extern ofstream errorout;

//needed for parser

extern YYSTYPE yylval;
extern int error_count;



// int bucket=10;
// Symbol_Table symbolTable(bucket);

string Uppercase(string temp)
{
	for(auto &t:temp)
	{t=toupper(t);}
	return temp;
}


char Lexeme_To_Char(const char* temp)
{	
	if(strlen(temp)==3)return temp[1];
	else if(temp[2]=='n')return '\n';
	else if(temp[2]=='a')return '\a';
	else if(temp[2]=='t')return '\t';
	else if(temp[2]=='\\')return '\\';
	else if(temp[2]=='r')return '\r';
	else if(temp[2]=='b')return '\b';
	else if(temp[2]=='0')return '\0';
	else if(temp[2]=='v')return '\v';
	else if(temp[2]=='\"')return '\"';
	else if(temp[2]=='f')return '\f';

	return '\a';
}

// FILE *logout;
// FILE *tokenout;



void Print_log(int l,string t, string lex)
{
	cout<<"Line# "<<l<<": Token <"<<t<<"> Lexeme "<<lex<<" found\n";
}


// void Print_token(string t,string l)
// {
// 	tokenout<<"<"<<t<<", "<<l<<">\n";
// }


void Print_error(int l, string s,string msg)
{
	cout<<"Error at line# "<<l<<": "<<msg<<" "<<s<<"\n";
	error_count++;
}

string ESC_IN_STRING(string temp)
{
	// cout<<"In escape processor\n";
	if(temp[1]=='n')return "\n";
	else if(temp[1]=='a')return "\a";
	else if(temp[1]=='t')return "\t";
	else if(temp[1]=='\\')return "\\";
	else if(temp[1]=='\'')return "\'";
	else if(temp[1]=='r')return "\r";
	else if(temp[1]=='b')return "\b";
	else if(temp[1]=='0')return "\0";
	else if(temp[1]=='v')return "\v";
	else if(temp[1]=='\"')return "\"";
	else if(temp[1]=='f')return "\f";

	return "z";	
}



%}
CONST_CHAR \'[^\\\n\r']\'
WHITESPACE [ \t\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE (\r)?\n

EXPONENT [eE][+-]?{DIGIT}+
CONST_INT [0-9]+
CONST_FLOAT {DIGIT}+(\.{DIGIT}+)?{EXPONENT}?
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*
CONST_ESC_CHAR \'\\[ntafrb0\\']\'
ESCAPE \\0|\\v|\\b|\\r|\\f|\\\"|\\\'|\\\\|\\a|\\t|\\n

%%
{WHITESPACE} {}
{NEWLINE} {line_count++;}

"for" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
	// //delete tn;
	return FOR;
//	cout<<tn->output_text<<endl;
}


"do" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;	
	tn->output_text+=(to_string(tn->first_line)+">");

	yylval.treeNode=tn;
	// //delete tn;
	return DO;
//	cout<<tn->output_text<<endl;

}


"while" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
// //delete tn;
	return WHILE;
//	cout<<tn->output_text<<endl;

}

"if" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");

	yylval.treeNode=tn;
//delete tn;
	return IF;
//	cout<<tn->output_text<<endl;

}

"else" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");

	yylval.treeNode=tn;
//delete tn;
	return ELSE;
//	cout<<tn->output_text<<endl;

}

"switch" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");

	yylval.treeNode=tn;
//delete tn;
	return SWITCH;
//	cout<<tn->output_text<<endl;

}

"case" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;		
	tn->output_text+=(to_string(tn->first_line)+">");

	yylval.treeNode=tn;
//delete tn;
	return CASE;
//	cout<<tn->output_text<<endl;

}

"break" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return BREAK;
//	cout<<tn->output_text<<endl;

}


"default" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return DEFAULT;
//	cout<<tn->output_text<<endl;

}

"continue" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return CONTINUE;
//	cout<<tn->output_text<<endl;

}

"return" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return RETURN;
//	cout<<tn->output_text<<endl;

}

"void" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return VOID;
//	cout<<tn->output_text<<endl;

}

"char" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return CHAR;
//	cout<<tn->output_text<<endl;

}

"int" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return INT;
//	cout<<tn->output_text<<endl;

}

"float" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return FLOAT;
//	cout<<tn->output_text<<endl;

}

"double" {
	Print_log(line_count,Uppercase(yytext),yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,""+Uppercase(yytext)),Uppercase(yytext)+" : "+yytext+"\t"+"<Line: ");
	tn->first_line= tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return DOUBLE;
//	cout<<tn->output_text<<endl;

}


{CONST_INT} {
	// Print_token("CONST_INT",yytext);
	Print_log(line_count,"CONST_INT",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"CONST_INT"),"CONST_INT : " + string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return CONST_INT;
//	cout<<tn->output_text<<endl;


}

{CONST_FLOAT} {
	// Print_token("CONST_FLOAT",yytext);
	Print_log(line_count,"CONST_FLOAT",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"CONST_FLOAT"),"CONST_FLOAT : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return CONST_FLOAT;
//	cout<<tn->output_text<<endl;

}

{IDENTIFIER} {
	// Print_token("ID",yytext);
	Print_log(line_count,"ID",yytext);
	// if(symbolTable.Insert(yytext,"ID"))symbolTable.PrintAllScope();
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"ID"),"ID : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return ID;
//	cout<<tn->output_text<<endl;



}

{CONST_CHAR}|{CONST_ESC_CHAR} {
	// Print_log(line_count,"CONST_CHAR",Lexeme_To_Char(yytext));
	cout<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<Lexeme_To_Char(yytext)<<" found\n";
	// tokenout << "<CONST_CHAR, " << Lexeme_To_Char(yytext) << ">\n";
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"CONST_CHAR"),"CONST_CHAR : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return CONST_CHAR;
//	cout<<tn->output_text<<endl;


}
	/*operator*/

"+"|"-" {
    // Print_token("ADDOP",yytext);
	Print_log(line_count,"ADDOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"ADDOP"),"ADDOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return ADDOP;
//	cout<<tn->output_text<<endl;

}

"*"|"/"|"%"  {
	// Print_token("MULOP",yytext);
	Print_log(line_count,"MULOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"MULOP"),"MULOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return MULOP;
//	cout<<tn->output_text<<endl;

}

"++" {
	// Print_token("INCOP",yytext);
	Print_log(line_count,"INCOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"INCOP"),"INCOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return INCOP;
//	cout<<tn->output_text<<endl;

}

"--" {
	
	Print_log(line_count,"DECOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"DECOP"),"DECOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return DECOP;
//	cout<<tn->output_text<<endl;

}


"<"|"<="|">"|">="|"=="|"!="  {   
	// Print_token("RELOP",yytext);
	Print_log(line_count,"RELOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"RELOP"),"RELOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return RELOP;
//	cout<<tn->output_text<<endl;



}

"&"|"|"|"^"|"<<"|">>" {
	// Print_token("BITOP",yytext);
	Print_log(line_count,"BITOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"BITOP"),"BITOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return BITOP;
//	cout<<tn->output_text<<endl;

}


"="  {
	// Print_token("ASSIGNOP",yytext);
	Print_log(line_count,"ASSIGNOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"ASSIGNOP"),"ASSIGNOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return ASSIGNOP;
//	cout<<tn->output_text<<endl;

}

"&&"|"||"  {
	// Print_token("LOGICOP",yytext);
	Print_log(line_count,"LOGICOP",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"LOGICOP"),"LOGICOP : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return LOGICOP;
//	cout<<tn->output_text<<endl;

}

"!"  {
	// Print_token("NOT",yytext);
	Print_log(line_count,"NOT",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"NOT"),"NOT : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return NOT;
//	cout<<tn->output_text<<endl;

}

"("  {
	// Print_token("LPAREN",yytext);
	Print_log(line_count,"LPAREN",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"LPAREN"),"LPAREN : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return LPAREN;
//	cout<<tn->output_text<<endl;

}

")"  {
	// Print_token("RPAREN",yytext);
	Print_log(line_count,"RPAREN",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"RAREN"),"RPAREN : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return RPAREN;
//	cout<<tn->output_text<<endl;


}

"{"  {
	// Print_token("LCURL",yytext);
	Print_log(line_count,"LCURL",yytext);
    // symbolTable.Enter_Scope();
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"LCURL"),"LCURL : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return LCURL;
//	cout<<tn->output_text<<endl;

}

"}"  {
	// Print_token("RCURL",yytext);
	Print_log(line_count,"RCURL",yytext);
    // symbolTable.Exit_Scope();
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"RCURL"),"RCURL : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return RCURL;
//	cout<<tn->output_text<<endl;

	
}

"["  {
	// Print_token("LTHIRD",yytext);
	Print_log(line_count,"LSQUARE",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"LSQUARE"),"LSQUARE : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return LTHIRD;
//	cout<<tn->output_text<<endl;

}
"]"  {
	// Print_token("RTHIRD",yytext);
	Print_log(line_count,"RSQUARE",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"RSQUARE"),"RSQUARE : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return RTHIRD;
//	cout<<tn->output_text<<endl;


}

","  {
	// Print_token("COMMA",yytext);
	Print_log(line_count,"COMMA",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"COMMA"),"COMMA : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return COMMA;
//	cout<<tn->output_text<<endl;

}

";"  {
	// Print_token("SEMICOLON",yytext);
	Print_log(line_count,"SEMICOLON",yytext);
	TreeNode *tn=new TreeNode(new Symbol_Info(yytext,"SEMICOLON"),"SEMICOLON : "+ string(yytext)+"\t<Line: ");
	tn->first_line=tn->last_line=yylineno;
	tn->is_Terminal=true;
	tn->output_text+=(to_string(tn->first_line)+">");
	yylval.treeNode=tn;
//delete tn;
	return SEMICOLON;
//	cout<<tn->output_text<<endl;

}

"//" {
	lexeme_start_line=line_count;
	current_lexeme=yytext;
	// cout<<"Comment Start\n";
	BEGIN SINGLE_LINE_COMMENT_STATE;
	
}

<SINGLE_LINE_COMMENT_STATE>. {
	current_lexeme+=yytext;
}

<SINGLE_LINE_COMMENT_STATE>\\{NEWLINE} {
	current_lexeme+=yytext;line_count++;
	// cout<<"new line in comment\n";
}

<SINGLE_LINE_COMMENT_STATE>{NEWLINE} {
	line_count++;
	// cout<<"Comment End\n";
	Print_log(lexeme_start_line,"SINGLE LINE COMMENT",current_lexeme);
	BEGIN INITIAL;
}

<SINGLE_LINE_COMMENT_STATE><<EOF>> {
	line_count++;
	// cout<<"Comment End\n";
	Print_log(lexeme_start_line,"SINGLE LINE COMMENT",current_lexeme);
	// symbolTable.PrintAllScope();
	// logout<<"Total lines: "<<line_count<<"\n";
	// logout<<"Total errors: "<<errors<<"\n";
	// return 0;
}

"/*" {
	current_lexeme=yytext;
	lexeme_start_line=line_count;
	BEGIN MULTILINE_COMMENT_STATE;
}

<MULTILINE_COMMENT_STATE>. {
	current_lexeme+=yytext;
}
<MULTILINE_COMMENT_STATE>{NEWLINE} {
	line_count++;current_lexeme+=yytext;
}

<MULTILINE_COMMENT_STATE>"*/" {
	current_lexeme+=yytext;
	Print_log(lexeme_start_line,"MULTI LINE COMMENT",current_lexeme);
	BEGIN INITIAL;
}

<MULTILINE_COMMENT_STATE><<EOF>> {
	Print_error(line_count,current_lexeme,"UNFINISHED_COMMENT");
	errors++;
	// line_count--;
	// symbolTable.PrintAllScope();
	// logout<<"Total lines: "<<line_count<<"\n";
	// logout<<"Total errors: "<<errors<<"\n";
	// return 0;
}


\" {
	str_token="";
	single_line_string=true;
	current_lexeme=yytext;
	lexeme_start_line=line_count;
	BEGIN STRING_STATE;
}

<STRING_STATE>\" {
	current_lexeme+=yytext;
	if(single_line_string){
		Print_log(lexeme_start_line,"SINGLE LINE STRING",current_lexeme);
		// Print_token("SINGLE LINE STRING",str_token);
	}
	else{
		Print_log(lexeme_start_line,"MULTI LINE STRING",current_lexeme);
		// Print_token("MULTI LINE STRING",str_token);
	}
	
	BEGIN INITIAL;
}

<STRING_STATE>\\\" {
	current_lexeme+=yytext;
	str_token+="\"";
}

<STRING_STATE>{ESCAPE} {
	// cout<<"Found escape char\n";
	str_token+=ESC_IN_STRING(yytext);
	current_lexeme+=yytext;
}

<STRING_STATE>\\{NEWLINE} {
	current_lexeme+=yytext;
	line_count++;
	single_line_string=false;
}

<STRING_STATE>{NEWLINE} {
	errors++;
	Print_error(line_count++,current_lexeme,"UNFINISHED_STRING");
	BEGIN INITIAL;
}

<STRING_STATE><<EOF>> {
	line_count--;errors++;
	Print_error(line_count,current_lexeme,"UNFINISHED_STRING");
	// symbolTable.PrintAllScope();
	// logout<<"Total lines: "<<line_count<<"\n";
	// logout<<"Total errors: "<<errors<<"\n";
	// return 0;
}

<STRING_STATE>. {
	current_lexeme+=yytext;
	str_token+=yytext;
}

{DIGIT}*(\.{DIGIT}*)+(\.{DIGIT}*)+{EXPONENT}? {
	Print_error(line_count,yytext,"TOO_MANY_DECIMAL_POINTS");
	errors++;
}

{DIGIT}*[eE][+-]?{DIGIT}*(\.{DIGIT}*)+ {
	Print_error(line_count,yytext,"ILLFORMED_NUMBER");
	errors++;
}

\'.[^\'\r\n]+\' {
	Print_error(line_count,yytext,"MULTICHAR_CONST_CHAR");
	errors++;
}

{CONST_FLOAT}+{IDENTIFIER}+ {
	Print_error(line_count,yytext,"INVALID_ID_SUFFIX_NUM_PREFIX");
	errors++;
}

\'\' {
	Print_error(line_count,yytext,"EMPTY_CONST_CHAR");
	errors++;
}

\'(\\\')?[^\'\n\r] {
	Print_error(line_count,yytext,"UNFINISHED_CONST_CHAR");
	errors++;
}



<<EOF>> {
	// symbolTable.PrintAllScope();
	// logout<<"Total lines: "<<line_count<<"\n";
	// logout<<"Total errors: "<<errors<<"\n";
	return 0;
}


. {
	Print_error(line_count,yytext,"UNRECOGNIZED_CHAR");
	errors++;
}







			

%%

// int main(int argc, char** argv) {
// 	if(argc!=2){
// 		printf("Please provide input file name and try again\n");
// 		return 0;
// 	}
	
// 	FILE *fin=fopen(argv[1],"r");
// 	if(fin==NULL){
// 		printf("Cannot open specified file\n");
// 		return 0;
// 	}
	
// 	// tokenout.open("1905027_token.txt");
// 	logout.open("1905027_log.txt");
// 	// freopen("rough1.txt","w",stdout);



// 	// freopen("1905027_log.txt","w",stdout);

// 	yyin= fin;
// 	yylex();
// 	fclose(yyin);
	
// 	return 0;
// }
